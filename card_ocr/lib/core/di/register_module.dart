import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:card_ocr/domain/domain.dart';

@module
abstract class UseCaseModule {
  @lazySingleton
  ScanCard scanCard(OcrRepository ocrRepository) => ScanCard(ocrRepository: ocrRepository);

  @lazySingleton
  SaveCard saveCard(CardRepository cardRepository) => SaveCard(cardRepository: cardRepository);

  @lazySingleton
  GetSaveCards getSaveCards(CardRepository cardRepository) => GetSaveCards(cardRepository: cardRepository);

  @lazySingleton
  DeleteCard deleteCard(CardRepository cardRepository) => DeleteCard(cardRepository: cardRepository);

  @lazySingleton
  ParseCardFields parseCardFields() => ParseCardFields();
}

const _defaultBaseUrl = String.fromEnvironment('OCR_BASE_URL', defaultValue: 'https://localhost:8000');

@module
abstract class ExternalModule {
  @preResolve
  @lazySingleton
  Future<Dio> dio() async {
    final dio = Dio(BaseOptions(baseUrl: _defaultBaseUrl));
    final certBytes = await rootBundle.load('assets/certs/rootCA.pem');
    final securityContext = SecurityContext(withTrustedRoots: true)
      ..setTrustedCertificatesBytes(certBytes.buffer.asUint8List());
    dio.httpClientAdapter = IOHttpClientAdapter(createHttpClient: () => HttpClient(context: securityContext));

    return dio;
  }

  @lazySingleton
  FlutterSecureStorage get secureStorage => const FlutterSecureStorage();
}
