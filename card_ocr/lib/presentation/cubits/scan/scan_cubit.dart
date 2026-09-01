import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:card_ocr/domain/domain.dart';

part 'scan_state.dart';

@injectable
class ScanCubit extends Cubit<ScanState> {
  final ScanCard scanCard;
  final ParseCardFields parseCardFields;
  final SaveCard saveCard;

  ScanCubit({required this.scanCard, required this.parseCardFields, required this.saveCard}) : super(const ScanIdle());

  void startCapture() => emit(const ScanCapturing());

  Future<void> processImage(Uint8List imageBytes) async {
    emit(ScanUploading(imageBytes: imageBytes));
    try {
      final ocrResult = await scanCard(imageBytes);
      final draft = parseCardFields(ocrResult);
      emit(ScanParsed(imageBytes: imageBytes, ocrResult: ocrResult, draft: draft));
    } catch (e) {
      emit(ScanError(e.toString()));
    }
  }

  Future<void> save(CardRecord record) async {
    try {
      await saveCard(record);
      emit(const ScanSaved());
    } catch (e) {
      emit(ScanError(e.toString()));
    }
  }

  void reset() => emit(const ScanIdle());
}
