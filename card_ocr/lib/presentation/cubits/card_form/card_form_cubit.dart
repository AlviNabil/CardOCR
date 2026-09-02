import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:card_ocr/domain/domain.dart';

part 'card_form_state.dart';

class CardFormCubit extends Cubit<CardFormState> {
  final CardRecord _draft;

  final TextEditingController labelController;
  final TextEditingController nameController;
  final TextEditingController panController;
  final TextEditingController expiryController;

  CardFormCubit({required CardRecord draft})
    : _draft = draft,
      labelController = TextEditingController(text: draft.label),
      nameController = TextEditingController(text: draft.cardholderName),
      panController = TextEditingController(text: draft.pan),
      expiryController = TextEditingController(text: CardRules.formatExpiry(draft.expiry)),
      super(CardFormState(network: draft.network, isPanValid: CardRules.isValidPan(draft.pan), isExpiryValid: true)) {
    panController.addListener(_revalidate);
    expiryController.addListener(_revalidate);
  }

  void _revalidate() {
    emit(
      CardFormState(
        network: CardRules.detectNetwork(panController.text),
        isPanValid: CardRules.isValidPan(panController.text),
        isExpiryValid: CardRules.parseExpiry(expiryController.text) != null,
      ),
    );
  }

  CardRecord buildRecord() {
    final label = labelController.text.trim();
    return CardRecord(
      id: _draft.id,
      label: label.isEmpty ? 'Card' : label,
      cardholderName: nameController.text.trim(),
      pan: CardRules.digitsOnly(panController.text),
      expiry: CardRules.parseExpiry(expiryController.text)!,
      network: CardRules.detectNetwork(panController.text),
      savedAt: DateTime.now(),
    );
  }

  @override
  Future<void> close() {
    labelController.dispose();
    nameController.dispose();
    panController.dispose();
    expiryController.dispose();
    return super.close();
  }
}
