// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OcrLineModel _$OcrLineModelFromJson(Map<String, dynamic> json) => OcrLineModel(
  text: json['text'] as String,
  confidence: (json['confidence'] as num).toDouble(),
  box: (json['box'] as List<dynamic>)
      .map(
        (e) => (e as List<dynamic>).map((e) => (e as num).toDouble()).toList(),
      )
      .toList(),
);

OcrResultModel _$OcrResultModelFromJson(Map<String, dynamic> json) =>
    OcrResultModel(
      lines: (json['lines'] as List<dynamic>)
          .map((e) => OcrLineModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      imageWidth: (json['image_width'] as num).toInt(),
      imageHeight: (json['image_height'] as num).toInt(),
    );

CardRecordModel _$CardRecordModelFromJson(Map<String, dynamic> json) =>
    CardRecordModel(
      id: (json['id'] as num?)?.toInt(),
      label: json['label'] as String,
      cardholderName: json['cardholder_name'] as String,
      pan: json['pan'] as String,
      expiryMonth: (json['expiry_month'] as num).toInt(),
      expiryYear: (json['expiry_year'] as num).toInt(),
      network: json['network'] as String,
      savedAt: DateTime.parse(json['saved_at'] as String),
    );

Map<String, dynamic> _$CardRecordModelToJson(CardRecordModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'label': instance.label,
      'cardholder_name': instance.cardholderName,
      'pan': instance.pan,
      'expiry_month': instance.expiryMonth,
      'expiry_year': instance.expiryYear,
      'network': instance.network,
      'saved_at': instance.savedAt.toIso8601String(),
    };
