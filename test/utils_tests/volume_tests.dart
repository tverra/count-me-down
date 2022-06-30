import 'package:count_me_down/utils/volume.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  /*test('test ', () {
    final int actual = 42;
    final int expected = 69;
    expect(actual, expected);
  });*/

  group('constructor with high value', () {
    late Volume _volume;

    setUp(() {
      _volume = Volume(1000);
    });

    test('returns correct volume in millilitres', () {
      final int actual = _volume.millilitres;
      const int expected = 1000;

      expect(actual, expected);
    });

    test('returns correct volume in centilitres', () {
      final double actual = _volume.centilitres;
      const double expected = 100.0;

      expect(actual, expected);
    });

    test('returns correct volume in decilitres', () {
      final double actual = _volume.decilitres;
      const double expected = 10.0;

      expect(actual, expected);
    });

    test('returns correct volume in litres', () {
      final double actual = _volume.litres;
      const double expected = 1.0;

      expect(actual, expected);
    });
  });

  group('constructor with low value', () {
    late Volume _volume;

    setUp(() {
      _volume = Volume(1);
    });

    test('returns correct volume in millilitres', () {
      final int actual = _volume.millilitres;
      const int expected = 1;

      expect(actual, expected);
    });

    test('returns correct volume in centilitres', () {
      final double actual = _volume.centilitres;
      const double expected = 0.1;

      expect(actual, expected);
    });

    test('returns correct volume in decilitres', () {
      final double actual = _volume.decilitres;
      const double expected = 0.01;

      expect(actual, expected);
    });

    test('returns correct volume in litres', () {
      final double actual = _volume.litres;
      const double expected = 0.001;

      expect(actual, expected);
    });
  });

  group('constructor with negative value', () {
    late Volume _volume;

    setUp(() {
      _volume = Volume(-1);
    });

    test('returns correct volume in millilitres', () {
      final int actual = _volume.millilitres;
      const int expected = -1;

      expect(actual, expected);
    });

    test('returns correct volume in centilitres', () {
      final double actual = _volume.centilitres;
      const double expected = -0.1;

      expect(actual, expected);
    });

    test('returns correct volume in decilitres', () {
      final double actual = _volume.decilitres;
      const double expected = -0.01;

      expect(actual, expected);
    });

    test('returns correct volume in litres', () {
      final double actual = _volume.litres;
      const double expected = -0.001;

      expect(actual, expected);
    });
  });

  group('exact volume', () {
    test('litres is added', () {
      final Volume volume = Volume.exact(litres: 560);
      final int actual = volume.millilitres;
      const int expected = 560000;

      expect(actual, expected);
    });

    test('decilitres is added', () {
      final Volume volume = Volume.exact(decilitres: 560);
      final int actual = volume.millilitres;
      const int expected = 56000;

      expect(actual, expected);
    });

    test('centilitres is added', () {
      final Volume volume = Volume.exact(centilitres: 560);
      final int actual = volume.millilitres;
      const int expected = 5600;

      expect(actual, expected);
    });

    test('millilitres is added', () {
      final Volume volume = Volume.exact(millilitres: 560);
      final int actual = volume.millilitres;
      const int expected = 560;

      expect(actual, expected);
    });

    test('different units are added', () {
      final Volume volume = Volume.exact(
        litres: 560,
        decilitres: 560,
        centilitres: 560,
        millilitres: 560,
      );
      final int actual = volume.millilitres;
      const int expected = 622160;

      expect(actual, expected);
    });

    test('negative values are added', () {
      final Volume volume = Volume.exact(
        litres: -560,
        decilitres: -560,
        centilitres: -560,
        millilitres: -560,
      );
      final int actual = volume.millilitres;
      const int expected = -622160;

      expect(actual, expected);
    });
  });

  group('toString', () {
    test('returns zero millilitres', () {
      final Volume volume = Volume(0);

      expect(volume.toString(), '0 mL');
    });

    test('returns millilitres', () {
      final Volume volume = Volume(6);

      expect(volume.toString(), '6 mL');
    });

    test('returns negative millilitres', () {
      final Volume volume = Volume(-6);

      expect(volume.toString(), '−6 mL');
    });

    test('returns centilitres if exactly 10 millilitres', () {
      final Volume volume = Volume(10);

      expect(volume.toString(), '1 cL');
    });

    test('returns centilitres', () {
      final Volume volume = Volume(60);

      expect(volume.toString(), '6 cL');
    });

    test('returns negative centilitres', () {
      final Volume volume = Volume(-60);

      expect(volume.toString(), '−6 cL');
    });

    test('returns decilitres if exactly 100 millilitres', () {
      final Volume volume = Volume(100);

      expect(volume.toString(), '1 dL');
    });

    test('returns decilitres', () {
      final Volume volume = Volume(600);

      expect(volume.toString(), '6 dL');
    });

    test('returns negative decilitres', () {
      final Volume volume = Volume(-600);

      expect(volume.toString(), '−6 dL');
    });

    test('returns litres if exactly 1000 millilitres', () {
      final Volume volume = Volume(1000);

      expect(volume.toString(), '1 L');
    });

    test('returns litres', () {
      final Volume volume = Volume(6000);

      expect(volume.toString(), '6 L');
    });

    test('returns negative litres', () {
      final Volume volume = Volume(-6000);

      expect(volume.toString(), '−6 L');
    });
  });
}
