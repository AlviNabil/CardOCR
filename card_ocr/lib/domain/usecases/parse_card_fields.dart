import '../entities/card_record.dart';
import '../entities/ocr_result.dart';

class ParseCardFields {
  CardRecord call(OcrResult ocrResult) {
    final lines = ocrResult.lines.map((l) => l.text).toList();

    final pan = _findPan(lines);
    final expiry = _findExpiry(lines);
    final name = _findCardholderName(lines);

    return CardRecord(
      label: 'New Card',
      cardholderName: name ?? 'UNKNOWN',
      pan: pan ?? '',
      expiry: expiry ?? const CardExpiry(month: 1, year: 2000),
      network: _detectNetwork(pan ?? ''),
      savedAt: DateTime.now(),
    );
  }

  String? _findPan(List<String> lines) {
    for (final line in lines) {
      final digits = line.replaceAll(RegExp(r'\D'), '');
      if (digits.length >= 13 && digits.length <= 19 && _isValidLuhn(digits)) {
        return digits;
      }
    }

    var buffer = '';
    for (final line in lines) {
      final digits = line.replaceAll(RegExp(r'\D'), '');
      if (digits.isEmpty) {
        buffer = '';
        continue;
      }
      buffer += digits;
      if (buffer.length >= 13 && buffer.length <= 19 && _isValidLuhn(buffer)) {
        return buffer;
      }
      if (buffer.length > 19) {
        buffer = digits;
      }
    }
    return null;
  }

  CardExpiry? _findExpiry(List<String> lines) {
    final pattern = RegExp(r'(0[1-9]|1[0-2])\s*/\s*(\d{2})');
    for (final line in lines) {
      final match = pattern.firstMatch(line);
      if (match != null) {
        return CardExpiry(month: int.parse(match.group(1)!), year: 2000 + int.parse(match.group(2)!));
      }
    }
    return null;
  }

  String? _findCardholderName(List<String> lines) {
    final namePattern = RegExp(r'^[A-Z][A-Z\s.]+[A-Z]$');
    String? best;
    for (final line in lines) {
      final trimmed = line.trim();
      if (namePattern.hasMatch(trimmed) && trimmed.contains(' ')) {
        if (best == null || trimmed.length > best.length) best = trimmed;
      }
    }
    return best;
  }

  CardNetwork _detectNetwork(String pan) {
    if (pan.startsWith('4')) return CardNetwork.visa;
    if (RegExp(r'^5[1-5]').hasMatch(pan) || RegExp(r'^2(2[2-9]|[3-6]\d|7[01])').hasMatch(pan)) {
      return CardNetwork.mastercard;
    }
    if (RegExp(r'^3[47]').hasMatch(pan)) return CardNetwork.amex;
    return CardNetwork.unknown;
  }

  bool _isValidLuhn(String digits) {
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
}
