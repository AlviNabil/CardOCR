import 'package:card_ocr/domain/entities/ocr_line.dart';

class OcrResult {
  final List<OcrLine> lines;
  final int imageWidth;
  final int imageHeight;

  OcrResult({
    required this.lines,
    required this.imageWidth,
    required this.imageHeight,
  });
}