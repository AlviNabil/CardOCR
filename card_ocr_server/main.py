from fastapi import FastAPI, Request, HTTPException
import ocr_engine

app = FastAPI()


@app.get("/health")
def health():
    return {"status": "ok"}


@app.post("/ocr")
async def ocr(request: Request):
    imagebytes = await request.body()
    if not imagebytes:
        raise HTTPException(status_code=400, detail="No image data provided")
    try:
        result = ocr_engine.run_ocr(imagebytes)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=f"Could Not Decode Image: {str(e)}")
    return result
