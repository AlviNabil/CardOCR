part of 'models.dart';

@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
class OcrResultModel {
  final List<OcrLineModel> lines;
  final int imageWidth;
  final int imageHeight;

  OcrResultModel({required this.lines, required this.imageWidth, required this.imageHeight});

  factory OcrResultModel.fromJson(Map<String, dynamic> json) => _$OcrResultModelFromJson(json);

  OcrResult toEntity() {
    final entityLines = lines.map((line) => line.toEntity()).toList();
    return OcrResult(lines: entityLines, imageWidth: imageWidth, imageHeight: imageHeight);
  }
}
