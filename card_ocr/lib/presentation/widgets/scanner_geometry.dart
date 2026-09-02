import 'dart:ui';

class ScannerGeometry {
  const ScannerGeometry._();

  static const double cardAspectRatio = 1.586;

  static const double widthFraction = 0.85;

  static const double cornerRadius = 12;

  static Rect cutoutRect(Size viewport) {
    final width = viewport.width * widthFraction;
    final height = width / cardAspectRatio;
    return Rect.fromLTWH((viewport.width - width) / 2, (viewport.height - height) / 2, width, height);
  }

  static RRect cutoutRRect(Size viewport) =>
      RRect.fromRectAndRadius(cutoutRect(viewport), const Radius.circular(cornerRadius));
}
