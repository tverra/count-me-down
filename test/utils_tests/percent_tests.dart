import 'package:count_me_down/utils/percent.dart';
import 'package:flutter_test/flutter_test.dart';

main() {
  /*test('test ', () {
    final int actual = 42;
    final int expected = 69;
    expect(actual, expected);
  });*/

  group('constructor', () {
    test('returns correct percent as fraction', () {
      final Percent percent = Percent(0.5);

      expect(percent.fraction, 0.5);
    });

    test('returns zero as percent as fraction', () {
      final Percent percent = Percent(0);

      expect(percent.fraction, 0.0);
    });

    test('returns high number as fraction', () {
      final Percent percent = Percent(1e+100);

      expect(percent.fraction, 1e+100);
    });

    test('returns low number as fraction', () {
      final Percent percent = Percent(0.0000000000000042);

      expect(percent.fraction, 0.0000000000000042);
    });

    test('returns 16 decimal points as fraction', () {
      final Percent percent = Percent(1.0 / 3);

      expect(percent.fraction, 0.3333333333333333);
    });

    test('returns negative fraction', () {
      final Percent percent = Percent(-0.5);

      expect(percent.fraction, -0.5);
    });

    test('returns correct percent', () {
      final Percent percent = Percent(0.5);
      
      expect(percent.percent, 50);
    });

    test('returns zero as percent', () {
      final Percent percent = Percent(0);

      expect(percent.percent, 0);
    });

    test('returns high number as percent', () {
      final Percent percent = Percent(1e+100);

      expect(percent.percent, 1e+102);
    });

    test('returns low number as percent', () {
      final Percent percent = Percent(0.0000000000000042);

      expect(percent.percent, 0.00000000000042);
    });

    test('returns 16 decimal points as percent', () {
      final Percent percent = Percent(1.0 / 3);

      expect(percent.percent, 33.33333333333333);
    });

    test('returns negative percent', () {
      final Percent percent = Percent(-0.5);

      expect(percent.percent, -50);
    });

    test('returns correct per mil', () {
      final Percent percent = Percent(0.5);

      expect(percent.perMil, 500);
    });

    test('returns zero as per mil', () {
      final Percent percent = Percent(0);

      expect(percent.perMil, 0);
    });

    test('returns high number as per mil', () {
      final Percent percent = Percent(1e+100);

      expect(percent.perMil, 1e+103);
    });

    test('returns low number as per mil', () {
      final Percent percent = Percent(0.0000000000000042);

      expect(percent.perMil, 0.0000000000042);
    });

    test('returns 16 decimal points as per mil', () {
      final Percent percent = Percent(1.0 / 3);

      expect(percent.perMil, 333.3333333333333333);
    });

    test('returns negative per mil', () {
      final Percent percent = Percent(-0.5);

      expect(percent.perMil, -500);
    });
  });

  group('fromPercent', () {
    test('returns correct percent as fraction', () {
      final Percent percent = Percent.fromPercent(50);

      expect(percent.fraction, 0.5);
    });

    test('returns zero as percent as fraction', () {
      final Percent percent = Percent.fromPercent(0);

      expect(percent.fraction, 0.0);
    });

    test('returns high number as fraction', () {
      final Percent percent = Percent.fromPercent(1e+100);

      expect(percent.fraction, 1e+98);
    });

    test('returns low number as fraction', () {
      final Percent percent = Percent.fromPercent(0.00000000000042);

      expect(percent.fraction, 0.0000000000000042);
    });

    test('returns 16 decimal points as fraction', () {
      final Percent percent = Percent.fromPercent(10.0 / 3);

      expect(percent.fraction, 0.03333333333333333);
    });

    test('returns negative fraction', () {
      final Percent percent = Percent.fromPercent(-50);

      expect(percent.fraction, -0.5);
    });

    test('returns correct percent', () {
      final Percent percent = Percent.fromPercent(50);

      expect(percent.percent, 50);
    });

    test('returns zero as percent', () {
      final Percent percent = Percent.fromPercent(0);

      expect(percent.percent, 0);
    });

    test('returns high number as percent', () {
      final Percent percent = Percent.fromPercent(1e+100);

      expect(percent.percent, 1e+100);
    });

    test('returns low number as percent', () {
      final Percent percent = Percent.fromPercent(0.00000000000042);

      expect(percent.percent, 0.00000000000042);
    });

    test('returns 16 decimal points as percent', () {
      final Percent percent = Percent.fromPercent(10.0 / 3);

      expect(percent.percent, 3.3333333333333335);
    });

    test('returns negative percent', () {
      final Percent percent = Percent.fromPercent(-50);

      expect(percent.percent, -50);
    });

    test('returns correct per mil', () {
      final Percent percent = Percent.fromPercent(50);

      expect(percent.perMil, 500);
    });

    test('returns zero as per mil', () {
      final Percent percent = Percent.fromPercent(0);

      expect(percent.perMil, 0);
    });

    test('returns high number as per mil', () {
      final Percent percent = Percent.fromPercent(1e+100);

      expect(percent.perMil, 1e+101);
    });

    test('returns low number as per mil', () {
      final Percent percent = Percent.fromPercent(0.00000000000042);

      expect(percent.perMil, 0.0000000000042);
    });

    test('returns 16 decimal points as per mil', () {
      final Percent percent = Percent.fromPercent(10.0 / 3);

      expect(percent.perMil, 33.333333333333336);
    });

    test('returns negative per mil', () {
      final Percent percent = Percent.fromPercent(-50);

      expect(percent.perMil, -500);
    });
  });

  group('toString', () {
    test('returns percent', () {
      final Percent percent = Percent(0.1);

      expect(percent.toString(), '10%');
    });

    test('returns high number as percent', () {
      final Percent percent = Percent(10000);

      expect(percent.toString(), '1000000%');
    });

    test('returns zero as percent', () {
      final Percent percent = Percent(0);

      expect(percent.toString(), '0%');
    });

    test('returns one percent', () {
      final Percent percent = Percent(0.01);

      expect(percent.toString(), '1%');
    });

    test('returns negative percent', () {
      final Percent percent = Percent(-0.1);

      expect(percent.toString(), '-10%');
    });

    test('returns per mil if less than one percent', () {
      final Percent percent = Percent(0.009);

      expect(percent.toString(), '9‰');
    });

    test('returns negative per mil', () {
      final Percent percent = Percent(-0.001);

      expect(percent.toString(), '-1‰');
    });
  });
}