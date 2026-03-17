import 'package:flutter_test/flutter_test.dart';
import 'package:cargo_rent_app/utils/validators.dart';

void main() {

  // ── Validator unit tests ────────────────────────────
  group('Validators', () {

    test('email validator rejects empty string', () {
      expect(Validators.email(''), isNotNull);
    });

    test('email validator rejects invalid email', () {
      expect(Validators.email('notanemail'), isNotNull);
    });

    test('email validator accepts valid email', () {
      expect(Validators.email('test@gmail.com'), isNull);
    });

    test('password validator rejects short password', () {
      expect(Validators.password('123'), isNotNull);
    });

    test('password validator accepts valid password', () {
      expect(Validators.password('password123'), isNull);
    });

    test('name validator rejects empty name', () {
      expect(Validators.name(''), isNotNull);
    });

    test('name validator accepts valid name', () {
      expect(Validators.name('Suprabha'), isNull);
    });

    test('phone validator rejects invalid phone', () {
      expect(Validators.phone('123'), isNotNull);
    });

    test('phone validator accepts valid phone', () {
      expect(Validators.phone('9876543210'), isNull);
    });

    test('price validator rejects zero price', () {
      expect(Validators.price('0'), isNotNull);
    });

    test('price validator accepts valid price', () {
      expect(Validators.price('1500'), isNull);
    });

    test('required validator rejects empty field', () {
      expect(Validators.required(''), isNotNull);
    });

    test('required validator accepts non-empty field', () {
      expect(Validators.required('some value'), isNull);
    });

    test('license validator rejects short license', () {
      expect(Validators.licenseNumber('AB12'), isNotNull);
    });

    test('license validator accepts valid license', () {
      expect(Validators.licenseNumber('MH12-20240001234'), isNull);
    });

  });

}