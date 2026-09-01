part of 'scan_cubit.dart';

sealed class ScanState {
  const ScanState();
}

class ScanIdle extends ScanState {
  const ScanIdle();
}

class ScanCapturing extends ScanState {
  const ScanCapturing();
}

class ScanUploading extends ScanState {
  const ScanUploading();
}

class ScanParsed extends ScanState {
  final Uint8List imageBytes;
  final OcrResult ocrResult;
  final CardRecord draft;

  const ScanParsed({required this.imageBytes, required this.ocrResult, required this.draft});
}

class ScanSaved extends ScanState {
  const ScanSaved();
}

class ScanError extends ScanState {
  final String errorMessage;

  const ScanError(this.errorMessage);
}
