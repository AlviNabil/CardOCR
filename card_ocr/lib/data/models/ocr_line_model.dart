part of 'models.dart';

@JsonSerializable(createToJson: false)
class OcrLineModel {
  final String text;
  final double confidence;
  final List<List<double>> box;

  OcrLineModel({required this.text, required this.confidence, required this.box});

  factory OcrLineModel.fromJson(Map<String, dynamic> json) => _$OcrLineModelFromJson(json);

  OcrLine toEntity() {
    final points = box.map((point) => CardPoint(x: point[0], y: point[1])).toList();
    return OcrLine(text: text, confidence: confidence, points: points);
  }
}
