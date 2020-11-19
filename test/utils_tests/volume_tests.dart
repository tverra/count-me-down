import 'package:count_me_down/utils/volume.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  /*test('test ', () {
    final int actual = 42;
    final int expected = 69;
    expect(actual, expected);
  });*/

  group('constructor with high value', () {
    Volume _volume;

    setUp(() {
      _volume = Volume(1000);
    });

    test('returns correct volume in millilitres', () {
      final int actual = _volume.millilitres;
      final int expected = 1000;

      expect(actual, expected);
    });

    test('returns correct volume in centilitres', () {
      final double actual = _volume.centilitres;
      final double expected = 100.0;

      expect(actual, expected);
    });

    test('returns correct volume in decilitres', () {
      final double actual = _volume.decilitres;
      final double expected = 10.0;

      expect(actual, expected);
    });

    test('returns correct volume in litres', () {
      final double actual = _volume.litres;
      final double expected = 1.0;

      expect(actual, expected);
    });
  });

  group('constructor with low value', () {
    Volume _volume;

    setUp(() {
      _volume = Volume(1);
    });

    test('returns correct volume in millilitres', () {
      final int actual = _volume.millilitres;
      final int expected = 1;

      expect(actual, expected);
    });

    test('returns correct volume in centilitres', () {
      final double actual = _volume.centilitres;
      final double expected = 0.1;

      expect(actual, expected);
    });

    test('returns correct volume in decilitres', () {
      final double actual = _volume.decilitres;
      final double expected = 0.01;

      expect(actual, expected);
    });

    test('returns correct volume in litres', () {
      final double actual = _volume.litres;
      final double expected = 0.001;

      expect(actual, expected);
    });
  });

  group('exact volume', () {
    test('litres is added', () {
      final Volume volume = Volume.exact(litres: 560);
      final int actual = volume.millilitres;
      final int expected = 560000;

      expect(actual, expected);
    });

    test('decilitres is added', () {
      final Volume volume = Volume.exact(decilitres: 560);
      final int actual = volume.millilitres;
      final int expected = 56000;

      expect(actual, expected);
    });

    test('centilitres is added', () {
      final Volume volume = Volume.exact(centilitres: 560);
      final int actual = volume.millilitres;
      final int expected = 5600;

      expect(actual, expected);
    });

    test('millilitres is added', () {
      final Volume volume = Volume.exact(millilitres: 560);
      final int actual = volume.millilitres;
      final int expected = 560;

      expect(actual, expected);
    });

    test('different units are added', () {
      final Volume volume = Volume.exact(
          litres: 560, decilitres: 560, centilitres: 560, millilitres: 560);
      final int actual = volume.millilitres;
      final int expected = 622160;

      expect(actual, expected);
    });
  });
}
