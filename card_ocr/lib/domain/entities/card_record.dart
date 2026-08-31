enum CardNetwork { visa, mastercard, amex, unknown }

class CardExpiry {
  final int month;
  final int year;

  const CardExpiry({required this.month, required this.year});
}

class CardRecord {
  final int? id;
  final String label;
  final String cardholderName;
  final String pan;
  final CardExpiry expiry;
  final CardNetwork network;
  final DateTime savedAt;

  CardRecord({
    this.id,
    required this.label,
    required this.cardholderName,
    required this.pan,
    required this.expiry,
    required this.network,
    required this.savedAt,
  });
}
