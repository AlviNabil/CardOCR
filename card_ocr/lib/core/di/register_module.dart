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
