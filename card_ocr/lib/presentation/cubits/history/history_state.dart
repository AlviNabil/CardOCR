part of 'history_cubit.dart';

sealed class HistoryState {
  const HistoryState();
}

class HistoryLoading extends HistoryState {
  const HistoryLoading();
}

class HistoryLoaded extends HistoryState {
  final List<CardRecord> cards;
  final int? revealedId;

  const HistoryLoaded({required this.cards, this.revealedId});
}

class HistoryError extends HistoryState {
  final String errorMessage;

  const HistoryError(this.errorMessage);
}
