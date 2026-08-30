import 'package:dio/dio.dart';
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

@module
abstract class ExternalModule {
  @lazySingleton
  Dio get dio => Dio(BaseOptions(baseUrl: 'https://192.168.68.50:8000'));

  @lazySingleton
  FlutterSecureStorage get secureStorage => const FlutterSecureStorage();
}
