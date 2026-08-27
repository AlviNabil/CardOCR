class CardPoint {
  final double x;
  final double y;

  CardPoint({required this.x, required this.y});
}

class OcrLine {
  final String text;
  final double confidence;
  final List<CardPoint> points;

  OcrLine({
    required this.text,
    required this.confidence,
    required this.points,
  });
}
