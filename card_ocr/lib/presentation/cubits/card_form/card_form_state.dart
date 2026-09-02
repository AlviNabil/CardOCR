part of 'card_form_cubit.dart';

class CardFormState {
  final CardNetwork network;
  final bool isPanValid;
  final bool isExpiryValid;

  const CardFormState({
    required this.network,
    required this.isPanValid,
    required this.isExpiryValid,
  });

  bool get canSave => isPanValid && isExpiryValid;
}
