import 'package:count_me_down/models/profile.dart';
import 'package:count_me_down/models/session.dart';
import 'package:count_me_down/utils/mass.dart';
import 'package:count_me_down/utils/percent.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_utils.dart' as test_utils;

void main() {
  /*test('this is a test', () {
    final int actual = 42;
    final int expected = 69;
    expect(actual, expected);
  });*/

  group('fromMap', () {
    late Map<String, dynamic> _profileMap;

    setUp(() {
      _profileMap = {
        'id': 1,
        'name': 'Profile',
        'body_weight': 75,
        'body_water_percentage': 0.6,
        'absorption_time': 3600000,
        'per_mil_metabolized_per_hour': 0.15,
        'sessions': [
          {
            'id': 1,
            'profile_id': 1,
            'name': 'Session',
            'volume': 500,
            'started_at': '2021-01-30T11:55:49.291Z',
            'ended_at': '2021-01-30T12:55:49.291Z',
          },
          {
            'id': 2,
            'profile_id': 1,
            'name': 'Session',
            'volume': 500,
            'started_at': '2021-01-30T11:55:49.291Z',
            'ended_at': '2021-01-30T12:55:49.291Z',
          },
        ],
      };
    });

    test('profile is parsed from map', () {
      final Profile profile = Profile.fromMap(_profileMap);

      expect(profile.id, _profileMap['id']);
      expect(profile.name, _profileMap['name']);
      expect(profile.bodyWeight, Mass(_profileMap['body_weight']));
      expect(profile.bodyWaterPercentage,
          Percent(_profileMap['body_water_percentage']));
      expect(profile.absorptionTime,
          Duration(milliseconds: _profileMap['absorption_time']));
      expect(profile.perMilMetabolizedPerHour,
          _profileMap['per_mil_metabolized_per_hour']);
      expect(profile.sessions?.length, 2);
    });

    test('profile is parsed if values are null', () {
      final Map<String, dynamic> profileMap = {
        'id': null,
        'profile_id': null,
        'name': null,
        'volume': null,
        'started_at': null,
        'ended_at': null,
        'profile': null,
        'drinks': null,
      };

      final Profile profile = Profile.fromMap(profileMap);

      expect(profile.id, null);
      expect(profile.name, null);
      expect(profile.bodyWeight, null);
      expect(profile.bodyWaterPercentage, null);
      expect(profile.absorptionTime, null);
      expect(profile.perMilMetabolizedPerHour, null);
      expect(profile.sessions, null);
    });
  });

  group('toMap', () {
    late Profile _profile;

    setUp(() {
      _profile = Profile(
        name: 'Profile',
        bodyWeight: Mass(75000),
        bodyWaterPercentage: Percent(0.6),
        absorptionTime: Duration(hours: 1),
        perMilMetabolizedPerHour: 0.15,
      )..id = 1;

      _profile.sessions = <Session>[
        Session(
          profileId: 1,
          name: 'Session',
          startedAt: test_utils.getDateTime(),
          endedAt: test_utils.getDateTime(),
        )..id = 1,
        Session(
          profileId: 1,
          name: 'Session',
          startedAt: test_utils.getDateTime(),
          endedAt: test_utils.getDateTime(),
        )..id = 2
      ];
    });

    test('profile is parsed from map', () {
      final Map<String, dynamic> profileMap = _profile.toMap();

      expect(profileMap['id'], _profile.id);
      expect(profileMap['name'], _profile.name);
      expect(profileMap['body_weight'], _profile.bodyWeight?.grams);
      expect(profileMap['body_water_percentage'],
          _profile.bodyWaterPercentage?.fraction);
      expect(profileMap['absorption_time'],
          _profile.absorptionTime?.inMilliseconds);
      expect(profileMap['sessions'].length, 2);
    });

    test('profile is parsed if values are null', () {
      final Map<String, dynamic> profileMap = Profile().toMap();

      expect(profileMap['id'], null);
      expect(profileMap['name'], null);
      expect(profileMap['body_weight'], null);
      expect(profileMap['body_water_percentage'], null);
      expect(profileMap['absorption_time'], null);
      expect(profileMap['sessions'], null);
    });

    test('relations are not parsed if forQuery', () {
      final Map<String, dynamic> profileMap = _profile.toMap(forQuery: true);

      expect(profileMap['sessions'], null);
    });
  });

  group('compare', () {
    late Profile _profile;

    setUp(() {
      _profile = Profile(
        name: 'Profile',
        bodyWeight: Mass(75),
        bodyWaterPercentage: Percent(0.6),
        absorptionTime: Duration(hours: 1),
        perMilMetabolizedPerHour: 0.15,
      )..id = 1;

      _profile.sessions = <Session>[
        Session(
          profileId: 1,
          name: 'Session',
          startedAt: test_utils.getDateTime(),
          endedAt: test_utils.getDateTime(),
        )..id = 1,
        Session(
          profileId: 1,
          name: 'Session',
          startedAt: test_utils.getDateTime(),
          endedAt: test_utils.getDateTime(),
        )..id = 2
      ];
    });

    test('objects are equal if parameters are equal', () {
      final Profile profile = _profile.copy();

      expect(_profile, profile);
    });

    test('objects are not equal if parameters are equal', () {
      final Profile profile = _profile.copy();
      profile.id = profile.id! + 1;

      expect(false, _profile == profile);
    });
  });
}
