import 'package:card_ocr/domain/entities/entities.dart';

abstract interface class CardRepository {
  Future<void> save(CardRecord record);
  Future<List<CardRecord>> getAll();
  Future<void> delete(int id);
}
