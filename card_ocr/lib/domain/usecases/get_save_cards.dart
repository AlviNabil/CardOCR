import 'package:card_ocr/domain/entities/card_record.dart';
import 'package:card_ocr/domain/repositories/card_repository.dart';

class GetSaveCards {
  final CardRepository cardRepository;

  GetSaveCards({required this.cardRepository});

  Future<List<CardRecord>> call() => cardRepository.getAll();
}
