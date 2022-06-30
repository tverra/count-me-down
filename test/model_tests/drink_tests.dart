import 'dart:ui';

import 'package:count_me_down/extensions.dart';
import 'package:count_me_down/models/drink.dart';
import 'package:count_me_down/models/session.dart';
import 'package:count_me_down/utils/percent.dart';
import 'package:count_me_down/utils/volume.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_utils.dart' as test_utils;

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

  group('fromMap', () {
    late Map<String, dynamic> _drinkMap;

    setUp(() {
      _drinkMap = <String, dynamic>{
        'id': 1,
        'session_id': 1,
        'name': 'Drink',
        'volume': 500,
        'alcohol_concentration': 0.05,
        'timestamp': '2021-01-30T11:55:49.291Z',
        'color': 4283215696,
        'drink_type': 'beer',
        'session': <String, dynamic>{
          'id': 1,
          'profile_id': 1,
          'name': 'Session',
          'started_at': '2021-01-30T12:55:49.291Z',
          'ended_at': '2021-01-30T13:55:49.291Z',
        },
      };
    });

    test('drink is parsed from map', () {
      final Drink drink = Drink.fromMap(_drinkMap);

      expect(drink.id, _drinkMap['id']);
      expect(drink.sessionId, _drinkMap['session_id']);
      expect(drink.name, _drinkMap['name']);
      expect(drink.volume, Volume(_drinkMap['volume'] as int));
      expect(
        drink.alcoholConcentration,
        Percent(_drinkMap['alcohol_concentration'] as double),
      );
      expect(drink.timestamp, DateTime.parse(_drinkMap['timestamp'] as String));
      expect(drink.color, Color(_drinkMap['color'] as int));
      expect(drink.drinkType, DrinkTypes.beer);
      expect(
        drink.session?.id,
        (_drinkMap['session'] as Map<String, dynamic>)['id'],
      );
    });

    test('date times can be integers', () {
      _drinkMap['timestamp'] = 1612008911888;
      final Drink drink = Drink.fromMap(_drinkMap);

      final DateTime timestamp = DateTime.fromMillisecondsSinceEpoch(
        _drinkMap['timestamp'] as int,
        isUtc: true,
      );

      expect(drink.timestamp, timestamp);
    });

    test('date times can be integer strings', () {
      _drinkMap['timestamp'] = '1612008911888';
      final Drink drink = Drink.fromMap(_drinkMap);

      final DateTime timestamp = DateTime.fromMillisecondsSinceEpoch(
        int.parse(_drinkMap['timestamp'] as String),
        isUtc: true,
      );

      expect(drink.timestamp, timestamp);
    });

    test('date times is null if invalid', () {
      _drinkMap['timestamp'] = 'not valid';
      final Drink drink = Drink.fromMap(_drinkMap);

      expect(drink.timestamp, null);
    });

    test('drink type is null if invalid', () {
      _drinkMap['drink_type'] = 'not valid';
      final Drink drink = Drink.fromMap(_drinkMap);

      expect(drink.drinkType, null);
    });

    test('drink is parsed if values are null', () {
      final Map<String, dynamic> drinkMap = <String, dynamic>{
        'id': null,
        'session_id': null,
        'name': null,
        'volume': null,
        'alcohol_concentration': null,
        'timestamp': null,
        'color': null,
        'drink_type': null,
        'session': null,
      };

      final Drink drink = Drink.fromMap(drinkMap);

      expect(drink.id, null);
      expect(drink.sessionId, null);
      expect(drink.name, null);
      expect(drink.volume, null);
      expect(drink.alcoholConcentration, null);
      expect(drink.timestamp, null);
      expect(drink.color, null);
      expect(drink.drinkType, null);
      expect(drink.session, null);
    });
  });

  group('toMap', () {
    late Drink _drink;

    setUp(() {
      _drink = Drink(
        sessionId: 1,
        name: 'Drink',
        volume: Volume(500),
        alcoholConcentration: Percent(0.05),
        timestamp: test_utils.getDateTime(),
        color: const Color(0xff4caf50),
        drinkType: DrinkTypes.beer,
      )..id = 1;

      _drink.session = Session(
        profileId: 1,
        name: 'Session',
        startedAt: test_utils.getDateTime(),
        endedAt: test_utils.getDateTime(),
      )..id = 1;
    });

    test('drink is parsed from map', () {
      final Map<String, dynamic> drinkMap = _drink.toMap();

      expect(drinkMap['id'], _drink.id);
      expect(drinkMap['session_id'], _drink.sessionId);
      expect(drinkMap['name'], _drink.name);
      expect(drinkMap['volume'], _drink.volume?.millilitres);
      expect(
        drinkMap['alcohol_concentration'],
        _drink.alcoholConcentration?.fraction,
      );
      expect(drinkMap['timestamp'], _drink.timestamp?.toIso8601String());
      expect(drinkMap['color'], _drink.color?.value);
      expect(drinkMap['drink_type'], 'beer');
      expect(
        (drinkMap['session'] as Map<String, dynamic>)['id'],
        _drink.session?.id,
      );
    });

    test('date times is integers if forQuery', () {
      final Map<String, dynamic> drinkMap = _drink.toMap(forQuery: true);

      expect(drinkMap['timestamp'], _drink.timestamp?.millisecondsSinceEpoch);
    });

    test('drink is parsed if values are null', () {
      final Map<String, dynamic> drinkMap = Drink().toMap();

      expect(drinkMap['id'], null);
      expect(drinkMap['session_id'], null);
      expect(drinkMap['name'], null);
      expect(drinkMap['volume'], null);
      expect(drinkMap['alcohol_concentration'], null);
      expect(drinkMap['timestamp'], null);
      expect(drinkMap['color'], null);
      expect(drinkMap['drink_type'], null);
      expect(drinkMap['session'], null);
    });

    test('relations are not parsed if forQuery', () {
      final Map<String, dynamic> drinkMap = _drink.toMap(forQuery: true);

      expect(drinkMap['session'], null);
    });
  });

  group('compare', () {
    late Drink _drink;

    setUp(() {
      _drink = Drink(
        sessionId: 1,
        name: 'Drink',
        volume: Volume(500),
        alcoholConcentration: Percent(0.05),
        timestamp: test_utils.getDateTime(),
        color: const Color(0xff4caf50),
        drinkType: DrinkTypes.beer,
      )..id = 1;

      _drink.session = Session(
        profileId: 1,
        name: 'Session',
        startedAt: test_utils.getDateTime(),
        endedAt: test_utils.getDateTime(),
      )..id = 1;
    });

    test('objects are equal if parameters are equal', () {
      final Drink drink = _drink.copy();

      expect(_drink, drink);
    });

    test('objects are not equal if parameters are equal', () {
      final Drink drink = _drink.copy();
      drink.id = drink.id! + 1;

      expect(false, _drink == drink);
    });
  });

  group('alcoholContentInGrams', () {
    test('drink returns correct alcohol content in grams', () {
      final Drink drink = Drink(
        volume: Volume.exact(litres: 1),
        alcoholConcentration: Percent.fromPercent(40.0),
        timestamp: MockableDateTime.current,
      );

      final double actual = drink.alcoholContentInGrams;
      const double expected = 320.0;

      expect(actual, expected);
    });
  });

  group('getAbsorbedAlcohol', () {
    test('drink returns zero grams after zero duration', () {
      final Drink drink = Drink(
        volume: Volume.exact(litres: 1),
        alcoholConcentration: Percent.fromPercent(40.0),
        timestamp: MockableDateTime.current,
      );

      final double actual =
          drink.currentlyAbsorbedAlcohol(const Duration(minutes: 30));

      expect(actual >= 0 && actual < 1, true);
    });

    test('drink returns halve the total after half duration', () {
      final Drink drink = Drink(
        volume: Volume.exact(litres: 1),
        alcoholConcentration: Percent.fromPercent(40.0),
        timestamp:
            MockableDateTime.current.subtract(const Duration(minutes: 15)),
      );

      final double actual =
          drink.currentlyAbsorbedAlcohol(const Duration(minutes: 30));
      const double expected = 160;

      expect(actual, expected);
    });

    test('drink returns the whole content after full duration', () {
      final Drink drink = Drink(
        volume: Volume.exact(litres: 1),
        alcoholConcentration: Percent.fromPercent(40.0),
        timestamp:
            MockableDateTime.current.subtract(const Duration(minutes: 30)),
      );

      final double actual =
          drink.currentlyAbsorbedAlcohol(const Duration(minutes: 30));
      const double expected = 320;

      expect(actual, expected);
    });

    test('drink returns the whole content after more than full duration', () {
      final Drink drink = Drink(
        volume: Volume.exact(litres: 1),
        alcoholConcentration: Percent.fromPercent(40.0),
        timestamp:
            MockableDateTime.current.subtract(const Duration(minutes: 60)),
      );

      final double actual =
          drink.currentlyAbsorbedAlcohol(const Duration(minutes: 30));
      const double expected = 320.0;

      expect(actual, expected);
    });

    test('drink returns zero grams if drink is dated in the future', () {
      final Drink drink = Drink(
        volume: Volume.exact(litres: 1),
        alcoholConcentration: Percent.fromPercent(40.0),
        timestamp: MockableDateTime.current.add(const Duration(minutes: 15)),
      );

      final double actual =
          drink.currentlyAbsorbedAlcohol(const Duration(minutes: 30));
      const double expected = 0;

      expect(actual, expected);
    });

    test('drink returns the whole content if absorption time is zero', () {
      final Drink drink = Drink(
        volume: Volume.exact(litres: 1),
        alcoholConcentration: Percent.fromPercent(40.0),
        timestamp: MockableDateTime.current,
      );

      final double actual = drink.currentlyAbsorbedAlcohol(Duration.zero);
      const double expected = 320.0;

      expect(actual, expected);
    });
  });
}
