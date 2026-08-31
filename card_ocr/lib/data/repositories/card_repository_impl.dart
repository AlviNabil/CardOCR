import 'package:card_ocr/data/data_sources/card_local_data_sources.dart';
import 'package:card_ocr/data/models/models.dart';
import 'package:card_ocr/domain/entities/card_record.dart';
import 'package:card_ocr/domain/repositories/card_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: CardRepository)
class CardRepositoryImpl implements CardRepository {
  final CardLocalDataSource cardLocalDataSource;

  CardRepositoryImpl({required this.cardLocalDataSource});

  @override
  Future<void> save(CardRecord record) {
    return cardLocalDataSource.save(CardRecordModel.fromEntity(record));
  }

  @override
  Future<void> delete(int id) {
    return cardLocalDataSource.delete(id);
  }

  @override
  Future<List<CardRecord>> getAll() async {
    final models = await cardLocalDataSource.getAll();
    return models.map((m) => m.toEntity()).toList();
  }
}
