import 'package:card_ocr/domain/entities/ocr_result.dart';
import 'package:flutter/material.dart';

class OcrBoxPainter extends CustomPainter {
  final OcrResult ocrResult;

  OcrBoxPainter({required this.ocrResult});

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / ocrResult.imageWidth;
    final scaleY = size.height / ocrResult.imageHeight;

    for (final line in ocrResult.lines) {
      if (line.points.length < 3) continue;
      final path = Path()..moveTo(line.points.first.x * scaleX, line.points.first.y * scaleY);
      for (final point in line.points.skip(1)) {
        path.lineTo(point.x * scaleX, point.y * scaleY);
      }
      path.close();

      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..color = line.confidence >= 0.9
            ? Colors.greenAccent
            : line.confidence >= 0.7
            ? Colors.amberAccent
            : Colors.redAccent;
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant OcrBoxPainter oldDelegate) {
    return oldDelegate.ocrResult != ocrResult;
  }
}
