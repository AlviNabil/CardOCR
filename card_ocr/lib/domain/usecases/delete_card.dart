import '../repositories/card_repository.dart';

class DeleteCard {
  final CardRepository cardRepository;

  DeleteCard({required this.cardRepository});

  Future<void> call(int id) => cardRepository.delete(id);
}
