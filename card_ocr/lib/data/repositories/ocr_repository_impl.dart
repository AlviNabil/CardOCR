import 'dart:typed_data';

import 'package:injectable/injectable.dart';
import 'package:card_ocr/data/data_sources/ocr_remote_data_sources.dart';
import 'package:card_ocr/domain/domain.dart';

@LazySingleton(as: OcrRepository)
class OcrRepositoryImpl implements OcrRepository {
  final OcrRemoteDataSource remoteDataSource;

  OcrRepositoryImpl({required this.remoteDataSource});

  @override
  Future<OcrResult> scanCard(Uint8List imageBytes) async {
    final responseModel = await remoteDataSource.scanCard(imageBytes);
    return responseModel.toEntity();
  }
}
