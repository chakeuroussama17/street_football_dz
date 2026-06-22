/// Normalises an Algerian phone number to E.164 (+213XXXXXXXXX), or returns
/// null if it isn't a valid Algerian mobile number.
///
/// Accepts inputs like "0555 12 34 56", "555123456", "+213555123456",
/// "213555123456". Algerian mobiles start with 5, 6 or 7 (9 digits).
String? normalizeDzPhone(String input) {
  var digits = input.replaceAll(RegExp(r'\D'), '');
  if (digits.startsWith('213')) digits = digits.substring(3);
  if (digits.startsWith('0')) digits = digits.substring(1);
  if (digits.length != 9) return null;
  if (!RegExp(r'^[567]').hasMatch(digits)) return null;
  return '+213$digits';
}

/// Pretty form for display: +213 5XX XX XX XX.
String prettyDzPhone(String e164) {
  final m = RegExp(r'^\+213(\d)(\d{2})(\d{2})(\d{2})(\d{2})$').firstMatch(e164);
  if (m == null) return e164;
  return '+213 ${m[1]}${m[2]} ${m[3]} ${m[4]} ${m[5]}';
}
