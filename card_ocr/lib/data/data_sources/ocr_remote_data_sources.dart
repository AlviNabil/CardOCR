import 'dart:typed_data';

import 'package:injectable/injectable.dart';
import 'package:card_ocr/data/models/models.dart';
import 'package:dio/dio.dart';

@injectable
class OcrRemoteDataSource {
  final Dio dio;
  OcrRemoteDataSource({required this.dio});

  Future<OcrResultModel> scanCard(Uint8List imageBytes) async {
    try {
      final response = await dio.post(
        '/ocr',
        data: imageBytes,
        options: Options(headers: {'Content-Type': 'application/octet-stream'}, responseType: ResponseType.json),
      );
      return OcrResultModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception('OCR request failed: ${e.response?.statusCode} ${e.response?.data}');
    }
  }
}
