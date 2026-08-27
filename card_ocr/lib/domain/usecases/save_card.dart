import 'package:card_ocr/domain/entities/card_record.dart';
import 'package:card_ocr/domain/repositories/card_repository.dart';

class SaveCard {
  final CardRepository cardRepository;

  SaveCard({required this.cardRepository});

  Future<void> call(CardRecord record) => cardRepository.save(record);
}
