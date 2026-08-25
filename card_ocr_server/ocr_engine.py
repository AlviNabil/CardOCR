import cv2
import numpy as np
from paddleocr import PaddleOCR

_ocr = PaddleOCR(
    lang="en",
    use_doc_orientation_classify=False,
    use_doc_unwarping=False,
    use_textline_orientation=True,
)


def run_ocr(imagebytes: bytes) -> dict:
    file_bytes = np.frombuffer(imagebytes, dtype=np.uint8)
    image = cv2.imdecode(file_bytes, cv2.IMREAD_COLOR)
    if image is None:
        raise ValueError("Could not decode image from bytes")

    result = _ocr.predict(image)
    ### check the full result what are the total values returned by the ocr engine
    print(f"👉👉👉👉👉👉{result}")

    res = result[0]
    zippedResult = zip(res["rec_texts"], res["rec_scores"], res["rec_polys"])
    lines = []
    for text, score, box in zippedResult:
        lines.append(
            {
                "text": text,
                "confidence": float(score),
                "box": box.tolist(),
            }
        )
    height, width, _ = image.shape
    return {"lines": lines, "image_height": height, "image_width": width}

