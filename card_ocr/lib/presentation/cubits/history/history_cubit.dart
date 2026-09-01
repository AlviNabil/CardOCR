import 'package:card_ocr/domain/entities/card_record.dart';
import 'package:card_ocr/domain/usecases/delete_card.dart';
import 'package:card_ocr/domain/usecases/get_save_cards.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

part 'history_state.dart';

@injectable
class HistoryCubit extends Cubit<HistoryState> {
  final GetSaveCards getSaveCards;
  final DeleteCard deleteCard;

  HistoryCubit({required this.getSaveCards, required this.deleteCard}) : super(const HistoryLoading());

  Future<void> load() async {
    emit(const HistoryLoading());
    try {
      final cards = await getSaveCards();
      emit(HistoryLoaded(cards: cards));
    } catch (e) {
      emit(HistoryError(e.toString()));
    }
  }

  Future<void> delete(int id) async {
    try {
      await deleteCard(id);
      await load();
    } catch (e) {
      emit(HistoryError(e.toString()));
    }
  }

  void toggleReveal(int? id) {
    final current = state;
    if (current is! HistoryLoaded) return;
    emit(HistoryLoaded(cards: current.cards, revealedId: current.revealedId == id ? null : id));
  }
}
