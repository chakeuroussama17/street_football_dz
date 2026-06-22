// Smoke test for pure constants/config. Real logic suites are added in Phase 6.

import 'package:flutter_test/flutter_test.dart';
import 'package:street_football_dz/core/constants/algeria.dart';

void main() {
  test('Algeria has all 58 wilayas with sequential codes', () {
    expect(Algeria.wilayas.length, 58);
    expect(Algeria.wilayas.first.fr, 'Adrar');
    expect(Algeria.wilayas.last.fr, 'El Meniaa');
    for (var i = 0; i < Algeria.wilayas.length; i++) {
      expect(Algeria.wilayas[i].code, i + 1);
    }
  });

  test('wilaya label switches by locale', () {
    final alger = Algeria.wilayas[15]; // code 16
    expect(alger.fr, 'Alger');
    expect(alger.label('ar'), 'الجزائر');
    expect(alger.label('fr'), 'Alger');
  });

  test('game formats are the four a-side options', () {
    expect(kGameFormats, ['5', '7', '9', '11']);
  });
}
