import 'dart:typed_data';

import 'package:card_ocr/domain/entities/ocr_result.dart';
import 'package:card_ocr/domain/repositories/ocr_repository.dart';

class ScanCard {
  final OcrRepository ocrRepository;

  ScanCard({required this.ocrRepository});

  Future<OcrResult> call(Uint8List imageBytes) => ocrRepository.scanCard(imageBytes);
}
