import 'package:flutter_test/flutter_test.dart';
import 'package:healthmate/core/validators.dart';

void main() {
  group('date', () {
    test('valid', () => expect(Validators.date('2026-10-01'), isNull));
    test('empty', () => expect(Validators.date(''), isNotNull));
    test('malformed', () => expect(Validators.date('01/10/2026'), isNotNull));
    test('impossible date', () => expect(Validators.date('2026-02-31'), isNotNull));
    test('future', () => expect(Validators.date('2999-01-01'), isNotNull));
  });
  group('counts', () {
    test('valid', () => expect(Validators.steps('7850'), isNull));
    test('zero allowed', () => expect(Validators.water('0'), isNull));
    test('empty', () => expect(Validators.steps(''), isNotNull));
    test('negative', () => expect(Validators.calories('-5'), isNotNull));
    test('decimal', () => expect(Validators.steps('1.5'), isNotNull));
    test('letters', () => expect(Validators.steps('abc'), isNotNull));
    test('over limit', () => expect(Validators.water('${Validators.maxWater + 1}'), isNotNull));
  });
}