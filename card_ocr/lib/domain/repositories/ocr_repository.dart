

import 'dart:typed_data' show Uint8List;

import 'package:card_ocr/domain/entities/ocr_result.dart';

abstract interface class OcrRepository {
  Future<OcrResult> scanCard(Uint8List imageBytes);
}