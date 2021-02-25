import 'package:count_me_down/utils/mass.dart';
import 'package:flutter_test/flutter_test.dart';

main() {
  /*test('test ', () {
    final int actual = 42;
    final int expected = 69;
    expect(actual, expected);
  });*/

  group('constructor with high value', () {
    Mass _mass;

    setUp(() {
      _mass = Mass(100000);
    });

    test('returns correct mass in grams', () {
      final int actual = _mass.grams;
      final int expected = 100000;

      expect(actual, expected);
    });

    test('returns correct mass in kilos', () {
      final double actual = _mass.kilos;
      final double expected = 100.0;

      expect(actual, expected);
    });
  });

  group('constructor with low value', () {
    Mass _mass;

    setUp(() {
      _mass = Mass(1);
    });

    test('returns correct mass in grams', () {
      final int actual = _mass.grams;
      final int expected = 1;

      expect(actual, expected);
    });

    test('returns correct mass in kilos', () {
      final double actual = _mass.kilos;
      final double expected = 0.001;

      expect(actual, expected);
    });
  });

  group('constructor with negative value', () {
    Mass _mass;

    setUp(() {
      _mass = Mass(-10);
    });

    test('returns correct mass in grams', () {
      final int actual = _mass.grams;
      final int expected = -10;

      expect(actual, expected);
    });

    test('returns correct mass in kilos', () {
      final double actual = _mass.kilos;
      final double expected = -0.01;

      expect(actual, expected);
    });
  });

  group('units constructor', () {
    test('kilos is added', () {
      final Mass mass = Mass.units(kilos: 560);
      final int actual = mass.grams;
      final int expected = 560000;

      expect(actual, expected);
    });

    test('grams is added', () {
      final Mass mass = Mass.units(grams: 560);
      final int actual = mass.grams;
      final int expected = 560;

      expect(actual, expected);
    });

    test('different units are added', () {
      final Mass mass = Mass.units(kilos: 560, grams: 560);
      final int actual = mass.grams;
      final int expected = 560560;

      expect(actual, expected);
    });

    test('negative value is added', () {
      final Mass mass = Mass.units(kilos: -560, grams: -560);
      final int actual = mass.grams;
      final int expected = -560560;

      expect(actual, expected);
    });
  });

  group('toString', () {
    test('returns zero grams', () {
      final Mass mass = Mass(0);

      expect(mass.toString(), '0 g');
    });

    test('returns grams if under one kilo', () {
      final Mass mass = Mass(420);

      expect(mass.toString(), '420 g');
    });

    test('returns grams if negative', () {
      final Mass mass = Mass(-420);

      expect(mass.toString(), '-420 g');
    });

    test('returns one kilo if exactly one kilo', () {
      final Mass mass = Mass(1000);

      expect(mass.toString(), '1 kg');
    });

    test('returns kilos if more than one kilo', () {
      final Mass mass = Mass(420000);

      expect(mass.toString(), '420 kg');
    });

    test('rounds up if not exactly one kilo', () {
      final Mass mass = Mass(2500);

      expect(mass.toString(), '3 kg');
    });

    test('rounds down if not exactly one kilo', () {
      final Mass mass = Mass(2499);

      expect(mass.toString(), '2 kg');
    });

    test('returns kilos if negative', () {
      final Mass mass = Mass(-420000);

      expect(mass.toString(), '-420 kg');
    });
  });
}
