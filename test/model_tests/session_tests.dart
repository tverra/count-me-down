import 'dart:ui';

import 'package:count_me_down/models/drink.dart';
import 'package:count_me_down/models/profile.dart';
import 'package:count_me_down/models/session.dart';
import 'package:count_me_down/utils/mass.dart';
import 'package:count_me_down/utils/percentage.dart';
import 'package:count_me_down/utils/volume.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_utils.dart';

void main() {
  /*test('this is a test', () {
    final int actual = 42;
    final int expected = 69;
    expect(actual, expected);
  });*/

  group('fromMap', () {
    Map<String, dynamic> _sessionMap;

    setUp(() {
      _sessionMap = {
        'id': 1,
        'profile_id': 1,
        'name': 'Session',
        'volume': 500,
        'started_at': '2021-01-30T11:55:49.291Z',
        'ended_at': '2021-01-30T12:55:49.291Z',
        'profile': {
          'id': 1,
          'name': 'Profile',
          'body_weight': 75,
          'body_water_percentage': 0.6,
          'absorption_time': 3600000,
          'per_mil_metabolized_per_hour': 0.15,
        },
        'drinks': [
          {
            'id': 1,
            'session_id': 1,
            'name': 'Drink',
            'volume': 500,
            'alcohol_concentration': 0.05,
            'timestamp': '2021-01-30T11:55:49.291Z',
            'color': 4283215696,
            'drink_type': 'beer',
          },
          {
            'id': 2,
            'session_id': 1,
            'name': 'Drink',
            'volume': 500,
            'alcohol_concentration': 0.05,
            'timestamp': '2021-01-30T11:55:49.291Z',
            'color': 4283215696,
            'drink_type': 'beer',
          },
        ],
      };
    });

    test('session is parsed from map', () {
      final Session session = Session.fromMap(_sessionMap);

      expect(session.id, _sessionMap['id']);
      expect(session.profileId, _sessionMap['profile_id']);
      expect(session.name, _sessionMap['name']);
      expect(session.startedAt, DateTime.parse(_sessionMap['started_at']));
      expect(session.endedAt, DateTime.parse(_sessionMap['ended_at']));
      expect(session.profile.id, _sessionMap['profile']['id']);
      expect(session.drinks.length, 2);
    });

    test('date times can be integers', () {
      _sessionMap['started_at'] = 1612008911888;
      _sessionMap['ended_at'] = 1612008971888;
      final Session session = Session.fromMap(_sessionMap);

      final DateTime startedAt = DateTime.fromMillisecondsSinceEpoch(
        _sessionMap['started_at'],
        isUtc: true,
      );
      final DateTime endedAt = DateTime.fromMillisecondsSinceEpoch(
        _sessionMap['ended_at'],
        isUtc: true,
      );

      expect(session.startedAt, startedAt);
      expect(session.endedAt, endedAt);
    });

    test('date times can be integer strings', () {
      _sessionMap['started_at'] = '1612008911888';
      _sessionMap['ended_at'] = '1612008971888';
      final Session session = Session.fromMap(_sessionMap);

      final DateTime startedAt = DateTime.fromMillisecondsSinceEpoch(
        int.parse(_sessionMap['started_at']),
        isUtc: true,
      );
      final DateTime endedAt = DateTime.fromMillisecondsSinceEpoch(
        int.parse(_sessionMap['ended_at']),
        isUtc: true,
      );

      expect(session.startedAt, startedAt);
      expect(session.endedAt, endedAt);
    });

    test('date times is null if invalid', () {
      _sessionMap['started_at'] = 'not valid';
      _sessionMap['ended_at'] = 'not valid';
      final Session session = Session.fromMap(_sessionMap);

      expect(session.startedAt, null);
      expect(session.endedAt, null);
    });

    test('session is parsed if values are null', () {
      final Map<String, dynamic> sessionMap = {
        'id': null,
        'profile_id': null,
        'name': null,
        'volume': null,
        'started_at': null,
        'ended_at': null,
        'profile': null,
        'drinks': null,
      };

      final Session session = Session.fromMap(sessionMap);

      expect(session.id, null);
      expect(session.profileId, null);
      expect(session.name, null);
      expect(session.startedAt, null);
      expect(session.endedAt, null);
      expect(session.profile, null);
      expect(session.drinks, null);
    });
  });

  group('toMap', () {
    Session _session;

    setUp(() {
      _session = Session(
        profileId: 1,
        name: 'Session',
        startedAt: TestUtils.getDateTime(),
        endedAt: TestUtils.getDateTime(),
      )..id = 1;

      _session.profile = Profile(
        name: 'Profile',
        bodyWeight: Mass(75),
        bodyWaterPercentage: Percentage(0.6),
        absorptionTime: Duration(hours: 1),
        perMilMetabolizedPerHour: 0.15,
      )..id = 1;
      _session.drinks = <Drink>[
        Drink(
          sessionId: 1,
          name: 'Drink',
          volume: Volume(500),
          alcoholConcentration: Percentage(0.05),
          timestamp: TestUtils.getDateTime(),
          color: Color(4283215696),
          drinkType: DrinkTypes.beer,
        )..id = 1,
        Drink(
          sessionId: 1,
          name: 'Drink',
          volume: Volume(500),
          alcoholConcentration: Percentage(0.05),
          timestamp: TestUtils.getDateTime(),
          color: Color(4283215696),
          drinkType: DrinkTypes.beer,
        )..id = 2,
      ];
    });

    test('session is parsed from map', () {
      final Map<String, dynamic> sessionMap = _session.toMap();

      expect(sessionMap['id'], _session.id);
      expect(sessionMap['profile_id'], _session.profileId);
      expect(sessionMap['name'], _session.name);
      expect(sessionMap['started_at'], _session.startedAt.toIso8601String());
      expect(sessionMap['ended_at'], _session.endedAt.toIso8601String());
      expect(sessionMap['profile']['id'], _session.profile.id);
      expect(sessionMap['drinks'].length, 2);
    });

    test('date times is integers if forQuery', () {
      final Map<String, dynamic> sessionMap = _session.toMap(forQuery: true);

      expect(
          sessionMap['started_at'], _session.startedAt.millisecondsSinceEpoch);
      expect(sessionMap['ended_at'], _session.endedAt.millisecondsSinceEpoch);
    });

    test('session is parsed if values are null', () {
      final Map<String, dynamic> sessionMap = Session().toMap();

      expect(sessionMap['id'], null);
      expect(sessionMap['profile_id'], null);
      expect(sessionMap['name'], null);
      expect(sessionMap['started_at'], null);
      expect(sessionMap['ended_at'], null);
      expect(sessionMap['profile'], null);
      expect(sessionMap['drinks'], null);
    });

    test('relations are not parsed if forQuery', () {
      final Map<String, dynamic> sessionMap = _session.toMap(forQuery: true);

      expect(sessionMap['profile'], null);
      expect(sessionMap['drinks'], null);
    });
  });

  group('compare', () {
    Session _session;

    setUp(() {
      _session = Session(
        profileId: 1,
        name: 'Session',
        startedAt: TestUtils.getDateTime(),
        endedAt: TestUtils.getDateTime(),
      )..id = 1;

      _session.profile = Profile(
        name: 'Profile',
        bodyWeight: Mass(75),
        bodyWaterPercentage: Percentage(0.6),
        absorptionTime: Duration(hours: 1),
        perMilMetabolizedPerHour: 0.15,
      )..id = 1;
      _session.drinks = <Drink>[
        Drink(
          sessionId: 1,
          name: 'Drink',
          volume: Volume(500),
          alcoholConcentration: Percentage(0.05),
          timestamp: TestUtils.getDateTime(),
          color: Color(4283215696),
          drinkType: DrinkTypes.beer,
        )..id = 1,
        Drink(
          sessionId: 1,
          name: 'Drink',
          volume: Volume(500),
          alcoholConcentration: Percentage(0.05),
          timestamp: TestUtils.getDateTime(),
          color: Color(4283215696),
          drinkType: DrinkTypes.beer,
        )..id = 2,
      ];
    });

    test('objects are equal if parameters are equal', () {
      final Session session = _session.copy();

      expect(_session, session);
    });

    test('objects are not equal if parameters are equal', () {
      final Session session = _session.copy();
      session.id = session.id + 1;

      expect(false, _session == session);
    });
  });
}
