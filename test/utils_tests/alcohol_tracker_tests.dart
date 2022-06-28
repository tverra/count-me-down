import 'package:count_me_down/extensions.dart';
import 'package:count_me_down/models/drink.dart';
import 'package:count_me_down/models/profile.dart';
import 'package:count_me_down/utils/alcohol_tracker.dart';
import 'package:count_me_down/utils/mass.dart';
import 'package:count_me_down/utils/percent.dart';
import 'package:count_me_down/utils/volume.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  /*test('test ', () {
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

  group('BAC increases when adding drinks', () {
    final Profile _profile = Profile(
      bodyWeight: Mass.units(kilos: 75),
      bodyWaterPercentage: Percent.fromPercent(60),
      absorptionTime: Duration(minutes: 30),
      perMilMetabolizedPerHour: 0,
    );
    AlcoholTracker _alcoholTracker;
    DateTime _whenAbsorbed;

    setUp(() {
      _alcoholTracker = AlcoholTracker(profile: _profile);
      _whenAbsorbed = MockableDateTime.current.add(_profile.absorptionTime);
    });

    test('BAC is initially zero', () {
      final double actual =
          _alcoholTracker.getBloodAlcoholContent(MockableDateTime.current);
      final double expected = 0;

      expect(actual, expected);
    });

    test('BAC is still zero after duration', () {
      final double actual =
          _alcoholTracker.getBloodAlcoholContent(_whenAbsorbed);
      final double expected = 0;

      expect(actual, expected);
    });

    test('BAC is correct after one drink', () {
      _alcoholTracker.addDrink(Drink(
        volume: Volume.exact(centilitres: 4),
        alcoholConcentration: Percent.fromPercent(40.0),
        timestamp: MockableDateTime.current.subtract(_profile.absorptionTime),
      ));

      final double actual =
          _alcoholTracker.getBloodAlcoholContent(_whenAbsorbed);
      final double expected = 0.2844444444444445;

      expect(actual, expected);
    });

    test('BAC is correct after two drinks', () {
      for (int i = 0; i < 2; i++) {
        _alcoholTracker.addDrink(Drink(
          volume: Volume.exact(centilitres: 4),
          alcoholConcentration: Percent.fromPercent(40.0),
          timestamp: MockableDateTime.current.subtract(_profile.absorptionTime),
        ));
      }

      final double actual =
          _alcoholTracker.getBloodAlcoholContent(_whenAbsorbed);
      final double expected = 0.568888888888889;

      expect(actual, expected);
    });

    test('BAC is correct after adding 10 drinks', () {
      for (int i = 0; i < 10; i++) {
        _alcoholTracker.addDrink(Drink(
          volume: Volume.exact(centilitres: 4),
          alcoholConcentration: Percent.fromPercent(40.0),
          timestamp: MockableDateTime.current.subtract(_profile.absorptionTime),
        ));
      }

      final double actual =
          _alcoholTracker.getBloodAlcoholContent(_whenAbsorbed);
      final double expected = 2.844444444444444;

      expect(actual, expected);
    });
  });

  group('BAC is not increased before after absorbing drinks', () {
    final Profile _profile = Profile(
      bodyWeight: Mass.units(kilos: 75),
      bodyWaterPercentage: Percent.fromPercent(60),
      absorptionTime: Duration(minutes: 30),
      perMilMetabolizedPerHour: 0,
    );
    AlcoholTracker _alcoholTracker;

    setUp(() {
      _alcoholTracker = AlcoholTracker(profile: _profile);
    });

    test('BAC is zero after zero duration', () {
      _alcoholTracker.addDrink(Drink(
        volume: Volume.exact(centilitres: 4),
        alcoholConcentration: Percent.fromPercent(40.0),
        timestamp: MockableDateTime.current,
      ));

      final double actual =
          _alcoholTracker.getBloodAlcoholContent(MockableDateTime.current);
      final double expected = 0;

      expect(actual, expected);
    });

    test('BAC is zero after zero duration with 10 drinks', () {
      for (int i = 0; i < 10; i++) {
        _alcoholTracker.addDrink(Drink(
          volume: Volume.exact(centilitres: 4),
          alcoholConcentration: Percent.fromPercent(40.0),
          timestamp: MockableDateTime.current,
        ));
      }

      final double actual =
          _alcoholTracker.getBloodAlcoholContent(MockableDateTime.current);
      final double expected = 0;

      expect(actual, expected);
    });

    test('BAC is half after half the duration', () {
      final Duration halfDuration =
          Duration(seconds: _profile.absorptionTime.inSeconds ~/ 2);

      _alcoholTracker.addDrink(Drink(
        volume: Volume.exact(centilitres: 4),
        alcoholConcentration: Percent.fromPercent(40.0),
        timestamp: MockableDateTime.current.subtract(halfDuration),
      ));

      final double actual =
          _alcoholTracker.getBloodAlcoholContent(MockableDateTime.current);
      final double expected = 0.14222222222222225;

      expect(actual, expected);
    });

    test('BAC is half after half the duration with 10 drinks', () {
      final Duration halfDuration =
          Duration(seconds: _profile.absorptionTime.inSeconds ~/ 2);

      for (int i = 0; i < 10; i++) {
        _alcoholTracker.addDrink(Drink(
          volume: Volume.exact(centilitres: 4),
          alcoholConcentration: Percent.fromPercent(40.0),
          timestamp: MockableDateTime.current.subtract(halfDuration),
        ));
      }

      final double actual =
          _alcoholTracker.getBloodAlcoholContent(MockableDateTime.current);
      final double expected = 1.422222222222222;

      expect(actual, expected);
    });

    test('BAC is halved if absorption time is doubled', () {
      final Profile slowAbsorptionProfile = _profile.copyWith(
        absorptionTime:
            Duration(minutes: _profile.absorptionTime.inMinutes * 2),
      );
      _alcoholTracker = AlcoholTracker(profile: slowAbsorptionProfile);

      _alcoholTracker.addDrink(Drink(
        volume: Volume.exact(centilitres: 4),
        alcoholConcentration: Percent.fromPercent(40.0),
        timestamp: MockableDateTime.current.subtract(_profile.absorptionTime),
      ));

      final double actual =
          _alcoholTracker.getBloodAlcoholContent(MockableDateTime.current);
      final double expected = 0.14222222222222225;

      expect(actual, expected);
    });
  });

  group('BAC decreases when metabolized', () {
    final Profile _profile = Profile(
      bodyWeight: Mass.units(kilos: 75),
      bodyWaterPercentage: Percent.fromPercent(60),
      absorptionTime: Duration.zero,
      perMilMetabolizedPerHour: 0.15,
    );
    AlcoholTracker _alcoholTracker;

    setUp(() {
      _alcoholTracker = AlcoholTracker(profile: _profile);
    });

    test('BAC has not decreased after zero duration', () {
      _alcoholTracker.addDrink(Drink(
        volume: Volume.exact(centilitres: 4),
        alcoholConcentration: Percent.fromPercent(40.0),
        timestamp: MockableDateTime.current,
      ));

      final double actual =
          _alcoholTracker.getBloodAlcoholContent(MockableDateTime.current);
      final double expected = 0.2844444444444445;

      expect(actual, expected);
    });

    test('BAC has not decreased after zero duration with 10 drinks', () {
      for (int i = 0; i < 10; i++) {
        _alcoholTracker.addDrink(Drink(
          volume: Volume.exact(centilitres: 4),
          alcoholConcentration: Percent.fromPercent(40.0),
          timestamp: MockableDateTime.current,
        ));
      }

      final double actual =
          _alcoholTracker.getBloodAlcoholContent(MockableDateTime.current);
      final double expected = 2.844444444444444;

      expect(actual, expected);
    });

    test('BAC decreases with time', () {
      _alcoholTracker.addDrink(Drink(
        volume: Volume.exact(centilitres: 4),
        alcoholConcentration: Percent.fromPercent(40.0),
        timestamp: MockableDateTime.current.subtract(Duration(hours: 1)),
      ));

      final double actual =
          _alcoholTracker.getBloodAlcoholContent(MockableDateTime.current);
      final double expected = 0.1344444444444445;

      expect(actual, expected);
    });

    test('BAC decreases with time with 10 drinks', () {
      for (int i = 0; i < 10; i++) {
        _alcoholTracker.addDrink(Drink(
          volume: Volume.exact(centilitres: 4),
          alcoholConcentration: Percent.fromPercent(40.0),
          timestamp: MockableDateTime.current.subtract(Duration(hours: 1)),
        ));
      }

      final double actual =
          _alcoholTracker.getBloodAlcoholContent(MockableDateTime.current);
      final double expected = 2.694444444444444;

      expect(actual, expected);
    });

    test('BAC decrease is doubled if metabolization rate is doubled', () {
      final Profile fastMetabolizingProfile = _profile.copyWith(
        perMilMetabolizedPerHour: 0.30,
      );
      _alcoholTracker = AlcoholTracker(profile: fastMetabolizingProfile);

      for (int i = 0; i < 10; i++) {
        _alcoholTracker.addDrink(Drink(
          volume: Volume.exact(centilitres: 4),
          alcoholConcentration: Percent.fromPercent(40.0),
          timestamp: MockableDateTime.current.subtract(Duration(hours: 1)),
        ));
      }

      final double actual =
          _alcoholTracker.getBloodAlcoholContent(MockableDateTime.current);
      final double expected = 2.5444444444444443;

      expect(actual, expected);
    });

    test('BAC decrease is doubled if time is doubled', () {
      for (int i = 0; i < 10; i++) {
        _alcoholTracker.addDrink(Drink(
          volume: Volume.exact(centilitres: 4),
          alcoholConcentration: Percent.fromPercent(40.0),
          timestamp: MockableDateTime.current.subtract(Duration(hours: 2)),
        ));
      }

      final double actual =
          _alcoholTracker.getBloodAlcoholContent(MockableDateTime.current);
      final double expected = 2.5444444444444443;

      expect(actual, expected);
    });

    test('BAC reaches zero with time', () {
      _alcoholTracker.addDrink(Drink(
        volume: Volume.exact(centilitres: 4),
        alcoholConcentration: Percent.fromPercent(40.0),
        timestamp: MockableDateTime.current.subtract(Duration(hours: 2)),
      ));

      final double actual =
          _alcoholTracker.getBloodAlcoholContent(MockableDateTime.current);
      final double expected = 0;

      expect(actual, expected);
    });
  });
}
