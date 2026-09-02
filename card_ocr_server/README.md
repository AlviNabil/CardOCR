# card_ocr_server

Local OCR backend for the **cardOCR** Flutter app. Receives a card photo over
HTTPS, runs PaddleOCR on it in memory, and returns the recognized text lines
with their bounding boxes as JSON.

This is a **development server meant to run on our own machine on our own LAN**.
It is not hardened for public exposure.

---

## Security rules this server follows

Card images and recognized card text are sensitive. The implementation
deliberately:

- **Never writes the uploaded image to disk.** Bytes go from the HTTP request
  body straight to `cv2.imdecode` in memory. The `/ocr` route reads the raw
  request body rather than using FastAPI's `UploadFile`, because Starlette's
  `UploadFile` spools larger uploads to a temporary file on disk.
- **Never logs image data or recognized text.** Uvicorn's access log records
  only method, path, status, and timing — never bodies. Do not add `print()` or
  logging of OCR results: that would put full card numbers into our terminal
  scrollback and any redirected log file.
- **Persists nothing.** There is no database, no cache, no output directory.
  Each request is independent and leaves no trace when it completes.
- **Serves over HTTPS only** (see below), so card photos are never readable by
  other devices on the Wi-Fi.

`test_images/` and `*.pem` are gitignored — real card photos and the TLS private
key must never be committed.

---

## Setup

Requires **Python 3.10** from python.org (`/usr/local/bin/python3.10`).

> Do **not** use Homebrew's Python here. It is ad-hoc signed, which means
> macOS's Application Firewall cannot durably trust it and will keep reverting
> its "allow incoming connections" permission — the server then becomes
> unreachable from our phone. The python.org build is signed with a real Apple
> Developer ID and does not have this problem.

```bash
cd card_ocr_server
/usr/local/bin/python3.10 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

Verify both packages import:

```bash
python -c "import paddle, paddleocr; print(paddle.__version__, paddleocr.__version__)"
```

The first run of the OCR engine downloads the PP-OCR model weights (a few
hundred MB) into `~/.paddlex/official_models/` and caches them there.

---

## TLS certificate

The cert is issued for this Mac's **Bonjour hostname** rather than its IP, so it
keeps working when DHCP reassigns the machine a new address:

```bash
brew install mkcert
mkcert -install
mkcert "$(scutil --get LocalHostName).local" localhost 127.0.0.1 "$(ipconfig getifaddr en0)"
```

This produces `<hostname>.local+3.pem` and `<hostname>.local+3-key.pem` in the
current directory. The filename is stable across IP changes because it is named
after the first SAN.

`mkcert -install` trusts the CA on **this Mac only**. The Flutter app trusts it
separately by bundling `rootCA.pem` as an asset — see the app's notes; iOS
configuration profiles do _not_ affect Flutter's HTTP stack.

---

## Running

```bash
source .venv/bin/activate
uvicorn main:app --host :: --port 8000 \
  --ssl-keyfile "$(scutil --get LocalHostName).local+3-key.pem" \
  --ssl-certfile "$(scutil --get LocalHostName).local+3.pem" \
  --reload
```

`--host ::` binds IPv6 **and** accepts IPv4-mapped connections. Do not use
`0.0.0.0`: that is IPv4-only, and a `.local` name can resolve to IPv6, in which
case the phone connects to a port nothing is listening on.

The repo's `.vscode/launch.json` has a **card_ocr_server (uvicorn HTTPS)**
configuration that runs exactly this, plus a compound that starts the server and
the app together.

---

## API

### `GET /health`

```json
{ "status": "ok" }
```

### `POST /ocr`

Request body is the **raw** JPEG/PNG bytes — not `multipart/form-data`.

```
Content-Type: application/octet-stream
```

Response:

```json
{
  "lines": [
    {
      "text": "BRAC BANK",
      "confidence": 0.978,
      "box": [[15, 13], [128, 13], [128, 30], [15, 30]]
    }
  ],
  "image_width": 300,
  "image_height": 190
}
```

`box` is four corner points in the original image's pixel coordinates, in order,
so the client can draw an overlay regardless of card rotation. The client scales
them by `displayedSize / image_width`.

Returns `400` for an empty body or an image that cannot be decoded.

---

## Testing without the app

```bash
curl --data-binary @test_images/card1.jpg \
  -H "Content-Type: application/octet-stream" \
  "https://$(scutil --get LocalHostName).local:8000/ocr"
```

Useful for checking OCR quality on a new card before involving the app at all.

---

## The OCR pipeline

`ocr_engine.py` holds one module-level `PaddleOCR` instance — loading the model
weights is slow, so it happens once at import rather than per request. Each call
to `predict()` runs:

1. **Preprocessing** — decode, resize so the long side fits the detector,
   normalize.
2. **Text detection (DB / DBNet)** — a segmentation network produces a per-pixel
   "is this text?" probability map plus a learned per-pixel threshold map;
   combining them differentiably gives crisp boundaries, and contour extraction
   turns the result into quadrilateral boxes.
3. **Crop + rectify** — each quad is perspective-warped into a flat horizontal
   strip, since a handheld card photo is never perfectly square to the lens.
4. **Text-line orientation** — a small classifier flips strips that are 180°
   off. Enabled (`use_textline_orientation=True`) because cards get photographed
   in any rotation.
5. **Recognition (SVTR + CTC)** — each strip becomes a sequence of feature
   slices; the model emits a character distribution per slice, and CTC decoding
   collapses repeats and blanks into the final string plus a confidence.

Document orientation and unwarping are disabled — they target scanned documents
and only add latency for a single handheld card.

**Expect low confidence on embossed text.** Raised metallic digits produce
specular highlights and unusual strokes that general-purpose OCR handles poorly;
in testing, flat printed text scored ~0.99 while embossed numbers and expiry
dates scored 0.4–0.75. The app surfaces these scores and colors the overlay
boxes accordingly, and lets you correct fields before saving.

---

## Troubleshooting

| Symptom                                               | Cause                                                                                                                                             |
| ----------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------- |
| `curl` works from the Mac but the phone can't connect | Bound to `0.0.0.0` instead of `::`, or the phone is on a different Wi-Fi                                                                          |
| Connection reset / no route from another device       | macOS firewall blocking the Python binary — see the python.org note above                                                                         |
| `CERTIFICATE_VERIFY_FAILED` in the Flutter app        | The app bundles `rootCA.pem` as an asset and loads it into a `SecurityContext`; an iOS configuration profile does not affect Flutter's HTTP stack |
| `flutter run` fails at `port = 5353`                  | macOS Local Network permission missing for the IDE (System Settings → Privacy & Security → Local Network)                                         |
| `No ccache found` warning at startup                  | Harmless — PaddlePaddle only needs it when JIT-compiling custom ops, which standard OCR inference never does                                      |
