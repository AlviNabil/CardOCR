import 'package:flutter/material.dart';

class ScannerOverlayPainter extends CustomPainter {
  final RRect cutout;

  ScannerOverlayPainter(this.cutout);

  @override
  void paint(Canvas canvas, Size size) {
    final full = Path()..addRect(Offset.zero & size);
    final hole = Path()..addRRect(cutout);
    final scrim = Path.combine(PathOperation.difference, full, hole);

    canvas.drawPath(scrim, Paint()..color = const Color.fromRGBO(0, 0, 0, 0.6));

    canvas.drawRRect(
      cutout,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(ScannerOverlayPainter oldDelegate) => oldDelegate.cutout != cutout;
}
