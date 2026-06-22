import 'package:domain/domain.dart';
import 'package:test/test.dart';

void main() {
  group('LocalizedString', () {
    test('resolves with fallback to en', () {
      final s = LocalizedString({'en': 'Hello'});
      expect(s.resolve('hi'), 'Hello');
      expect(s.resolve('en'), 'Hello');
      expect(s.hasLanguage('hi'), isFalse);
      expect(s.hasLanguage('en'), isTrue);
    });

    test('accepts a bare string as en shorthand', () {
      final s = LocalizedString.fromJson('Hi');
      expect(s['en'], 'Hi');
    });

    test('empty when all values are blank', () {
      expect(const LocalizedString({'en': '  '}).isEmpty, isTrue);
      expect(const LocalizedString({'en': 'x'}).isEmpty, isFalse);
    });

    test('round-trips through json', () {
      final s = LocalizedString({'en': 'A', 'hi': 'अ'});
      expect(LocalizedString.fromJson(s.toJson()), equals(s));
    });
  });
}
