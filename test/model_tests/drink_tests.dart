import 'package:count_me_down/extensions.dart';
import 'package:count_me_down/models/drink.dart';
import 'package:count_me_down/utils/percentage.dart';
import 'package:count_me_down/utils/volume.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  /*test('this is a test', () {
    final int actual = 42;
    final int expected = 69;
    expect(actual, expected);
  });*/

  setUp(() {
    MockableDateTime.mockTime = DateTime.now();
  });

  tearDown(() {
    MockableDateTime.mockTime = null;
  });

  group('alcoholContentInGrams', () {
    test('drink returns correct alcohol content in grams', () {
      final Drink drink = Drink(
        volume: Volume.exact(litres: 1),
        alcoholConcentration: Percentage.fromPercentage(40.0),
        timestamp: MockableDateTime.current,
      );

      final double actual = drink.alcoholContentInGrams;
      final double expected = 320.0;

      expect(actual, expected);
    });
  });

  group('getAbsorbedAlcohol', () {
    test('drink returns zero grams after zero duration', () {
      final Drink drink = Drink(
        volume: Volume.exact(litres: 1),
        alcoholConcentration: Percentage.fromPercentage(40.0),
        timestamp: MockableDateTime.current,
      );

      final double actual =
          drink.currentlyAbsorbedAlcohol(Duration(minutes: 30));

      expect(actual >= 0 && actual < 1, true);
    });

    test('drink returns halve the total after half duration', () {
      final Drink drink = Drink(
        volume: Volume.exact(litres: 1),
        alcoholConcentration: Percentage.fromPercentage(40.0),
        timestamp: MockableDateTime.current.subtract(Duration(minutes: 15)),
      );

      final double actual =
          drink.currentlyAbsorbedAlcohol(Duration(minutes: 30));
      final double expected = 160;

      expect(actual, expected);
    });

    test('drink returns the whole content after full duration', () {
      final Drink drink = Drink(
        volume: Volume.exact(litres: 1),
        alcoholConcentration: Percentage.fromPercentage(40.0),
        timestamp: MockableDateTime.current.subtract(Duration(minutes: 30)),
      );

      final double actual =
          drink.currentlyAbsorbedAlcohol(Duration(minutes: 30));
      final double expected = 320;

      expect(actual, expected);
    });

    test('drink returns the whole content after more than full duration', () {
      final Drink drink = Drink(
        volume: Volume.exact(litres: 1),
        alcoholConcentration: Percentage.fromPercentage(40.0),
        timestamp: MockableDateTime.current.subtract(Duration(minutes: 60)),
      );

      final double actual =
          drink.currentlyAbsorbedAlcohol(Duration(minutes: 30));
      final double expected = 320.0;

      expect(actual, expected);
    });

    test('drink returns zero grams if drink is dated in the future', () {
      final Drink drink = Drink(
        volume: Volume.exact(litres: 1),
        alcoholConcentration: Percentage.fromPercentage(40.0),
        timestamp: MockableDateTime.current.add(Duration(minutes: 15)),
      );

      final double actual =
          drink.currentlyAbsorbedAlcohol(Duration(minutes: 30));
      final double expected = 0;

      expect(actual, expected);
    });

    test('drink returns the whole content if absorption time is zero', () {
      final Drink drink = Drink(
        volume: Volume.exact(litres: 1),
        alcoholConcentration: Percentage.fromPercentage(40.0),
        timestamp: MockableDateTime.current,
      );

      final double actual = drink.currentlyAbsorbedAlcohol(Duration.zero);
      final double expected = 320.0;

      expect(actual, expected);
    });
  });
}
