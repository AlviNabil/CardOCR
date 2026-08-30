part of 'models.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class CardRecordModel {
  final int? id;
  final String label;
  final String cardholderName;
  final String pan;
  final int expiryMonth;
  final int expiryYear;
  final String network;
  final DateTime savedAt;

  CardRecordModel({
    this.id,
    required this.label,
    required this.cardholderName,
    required this.pan,
    required this.expiryMonth,
    required this.expiryYear,
    required this.network,
    required this.savedAt,
  });

  factory CardRecordModel.fromJson(Map<String, dynamic> json) => _$CardRecordModelFromJson(json);

  Map<String, dynamic> toJson() => _$CardRecordModelToJson(this);

  CardRecord toEntity() => CardRecord(
    id: id,
    label: label,
    cardholderName: cardholderName,
    pan: pan,
    expiry: CardExpiry(month: expiryMonth, year: expiryYear),
    network: CardNetwork.values.firstWhere((n) => n.name == network, orElse: () => CardNetwork.unknown),
    savedAt: savedAt,
  );

  factory CardRecordModel.fromEntity(CardRecord entity) => CardRecordModel(
    id: entity.id,
    label: entity.label,
    cardholderName: entity.cardholderName,
    pan: entity.pan,
    expiryMonth: entity.expiry.month,
    expiryYear: entity.expiry.year,
    network: entity.network.name,
    savedAt: entity.savedAt,
  );
}
