import '../entities/card_record.dart';
import '../entities/ocr_result.dart';
import '../rules/card_rules.dart';

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
      network: CardRules.detectNetwork(pan ?? ''),
      savedAt: DateTime.now(),
    );
  }

  String? _findPan(List<String> lines) {
    for (final line in lines) {
      final digits = CardRules.digitsOnly(line);
      if (CardRules.isValidPan(digits)) return digits;
    }

    var buffer = '';
    for (final line in lines) {
      final digits = CardRules.digitsOnly(line);
      if (digits.isEmpty) {
        buffer = '';
        continue;
      }
      buffer += digits;
      if (CardRules.isValidPan(buffer)) return buffer;
      if (buffer.length > 19) buffer = digits;
    }
    return null;
  }

  CardExpiry? _findExpiry(List<String> lines) {
    final candidates = <CardExpiry>[for (final line in lines) ...CardRules.findExpiries(line)];
    if (candidates.isEmpty) return null;
    candidates.sort((a, b) => (a.year * 12 + a.month).compareTo(b.year * 12 + b.month));
    return candidates.last;
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
}
