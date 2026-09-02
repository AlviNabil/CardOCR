import '../entities/card_record.dart';

class CardRules {
  const CardRules._();

  static final RegExp _nonDigits = RegExp(r'\D');
  static final RegExp _mastercard = RegExp(r'^5[1-5]');
  static final RegExp _mastercard2Series = RegExp(r'^2(2[2-9]|[3-6]\d|7[01])');
  static final RegExp _amex = RegExp(r'^3[47]');

  static final RegExp _expiryLoose = RegExp(r'(0[1-9]|1[0-2])\s*/\s*(\d{2})');

  static final RegExp _expiryStrict = RegExp(r'^(0[1-9]|1[0-2])\s*/\s*(\d{2})$');

  static String digitsOnly(String text) => text.replaceAll(_nonDigits, '');

  static bool isValidLuhn(String digits) {
    if (digits.isEmpty) return false;
    var sum = 0;
    var alternate = false;
    for (var i = digits.length - 1; i >= 0; i--) {
      var n = int.parse(digits[i]);
      if (alternate) {
        n *= 2;
        if (n > 9) n -= 9;
      }
      sum += n;
      alternate = !alternate;
    }
    return sum % 10 == 0;
  }

  static bool isValidPan(String pan) {
    final digits = digitsOnly(pan);
    return digits.length >= 13 && digits.length <= 19 && isValidLuhn(digits);
  }

  static CardNetwork detectNetwork(String pan) {
    final digits = digitsOnly(pan);
    if (digits.startsWith('4')) return CardNetwork.visa;
    if (_mastercard.hasMatch(digits) || _mastercard2Series.hasMatch(digits)) {
      return CardNetwork.mastercard;
    }
    if (_amex.hasMatch(digits)) return CardNetwork.amex;
    return CardNetwork.unknown;
  }

  static List<CardExpiry> findExpiries(String text) => _expiryLoose
      .allMatches(text)
      .map((m) => CardExpiry(month: int.parse(m.group(1)!), year: 2000 + int.parse(m.group(2)!)))
      .toList();

  static CardExpiry? parseExpiry(String text) {
    final match = _expiryStrict.firstMatch(text.trim());
    if (match == null) return null;
    return CardExpiry(month: int.parse(match.group(1)!), year: 2000 + int.parse(match.group(2)!));
  }

  static String formatExpiry(CardExpiry expiry) {
    final mm = expiry.month.toString().padLeft(2, '0');
    final yy = (expiry.year % 100).toString().padLeft(2, '0');
    return '$mm/$yy';
  }
}
