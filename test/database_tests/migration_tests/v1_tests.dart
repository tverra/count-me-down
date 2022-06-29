import 'package:flutter_test/flutter_test.dart';
import 'package:count_me_down/database/db_utils.dart';
import 'package:count_me_down/database/db_utils.dart' as db_utils;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:uuid/uuid.dart';

import '../../test_utils.dart' as test_utils;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  if (useSqfLiteDb) {
    sqfliteFfiInit();
  }

  group('v1 in-memory db tests', () {
    setUp(() async {
      await test_utils.closeDb();
      await test_utils.loadTestDb(version: 1);
    });

    tearDown(() async {
      await test_utils.closeDb();
    });

    test('database is created', () async {
      final Map<String, dynamic> drink =
          getDrinkWithValues(<String, dynamic>{'id': 10, 'chain_id': 100});

      final Map<String, dynamic> profile =
          getProfileWithValues(<String, dynamic>{
        'id': 20,
        'drink_id': drink['id'] as int,
      });

      final Map<String, dynamic> session =
          getSessionWithValues(<String, dynamic>{
        'id': 30,
        'profile_id': profile['id'] as int,
        'drink_id': drink['id'] as int
      });

      await db_utils.insertInto('drink', drink, drink['id']);
      await db_utils.insertInto('profile', profile, profile['id']);
      await db_utils.insertInto('session', session, session['id']);

      final Map<String, dynamic> insertedDrink =
          (await db_utils.queryFrom('drink')).single;
      final Map<String, dynamic> insertedProfile =
          (await db_utils.queryFrom('profile')).single;
      final Map<String, dynamic> insertedSession =
          (await db_utils.queryFrom('session')).single;

      expect(drink, insertedDrink);
      expect(profile, insertedProfile);
      expect(session, insertedSession);
    });

    test('only required values inserted', () async {
      final Map<String, dynamic> drink = getDrink();
      final Map<String, dynamic> profile = getProfile();
      final Map<String, dynamic> session = getSession();

      final int? drinkId =
          await db_utils.insertInto('drink', drink, drink['id']) as int?;
      final int? profileId =
          await db_utils.insertInto('profile', profile, profile['id']) as int?;
      final int? sessionId =
          await db_utils.insertInto('session', session, session['id']) as int?;

      final Map<String, dynamic> insertedDrink =
          (await db_utils.queryFrom('drink')).single;
      final Map<String, dynamic> insertedProfile =
          (await db_utils.queryFrom('profile')).single;
      final Map<String, dynamic> insertedSession =
          (await db_utils.queryFrom('session')).single;

      if (useSqfLiteDb) {
        drink['id'] = drinkId;
        profile['id'] = profileId;
        session['id'] = sessionId;
      }

      expect(insertedDrink, drink, reason: 'failed: drink');
      expect(insertedProfile, profile, reason: 'failed: profile');
      expect(insertedSession, session, reason: 'failed: session');
    });

    test('drink id is unique', () async {
      // Not supported on indexed db
      if (!useSqfLiteDb) return;

      final Map<String, dynamic> drink =
          getDrink(<String, dynamic>{'id': 1, 'name_id': const Uuid().v1()});

      await db_utils.insertInto('drink', drink, drink['id']);

      expect(
        () async => db_utils.insertInto('drink', drink, drink['id']),
        throwsA(isA<DatabaseException>()),
      );
    });

    test('drink name_id is unique', () async {
      // Not supported on indexed db
      if (!useSqfLiteDb) return;

      final Map<String, dynamic> drink =
          getDrink(<String, dynamic>{'name_id': 'name_id'});

      await db_utils.insertInto('drink', drink, drink['id']);

      expect(
        () async => db_utils.insertInto('drink', drink, drink['id']),
        throwsA(isA<DatabaseException>()),
      );
    });

    test('profile id is unique', () async {
      // Not supported on indexed db
      if (!useSqfLiteDb) return;

      final Map<String, dynamic> profile =
          getProfile(<String, dynamic>{'id': 1, 'name_id': const Uuid().v1()});

      await db_utils.insertInto('profile', profile, profile['id']);

      expect(
        () async => db_utils.insertInto('profile', profile, profile['id']),
        throwsA(isA<DatabaseException>()),
      );
    });

    test('profile name_id is unique', () async {
      // Not supported on indexed db
      if (!useSqfLiteDb) return;

      final Map<String, dynamic> profile =
          getProfile(<String, dynamic>{'name_id': 'name_id'});

      await db_utils.insertInto('profile', profile, profile['id']);

      expect(
        () async => db_utils.insertInto('profile', profile, profile['id']),
        throwsA(isA<DatabaseException>()),
      );
    });

    test('drink is referenced in profile', () async {
      // Not supported on indexed db
      if (!useSqfLiteDb) return;

      final Map<String, dynamic> drink = getDrink();
      final Map<String, dynamic> profile = getProfile();

      final int? drinkId =
          await db_utils.insertInto('drink', drink, drink['id']) as int?;
      profile['drink_id'] = drinkId! + 1;

      expect(
        () async => db_utils.insertInto('profile', profile, profile['id']),
        throwsA(isA<DatabaseException>()),
      );
    });

    test('profile is deleted if drink is deleted', () async {
      // Not supported on indexed db
      if (!useSqfLiteDb) return;

      final Map<String, dynamic> drink = getDrink();
      final Map<String, dynamic> profile = getProfile();

      final int? drinkId =
          await db_utils.insertInto('drink', drink, drink['id']) as int?;
      profile['drink_id'] = drinkId;
      await db_utils.insertInto('profile', profile, profile['id']);

      List<Map<String, dynamic>> profiles = await db_utils.queryFrom('profile');
      expect(profiles.length, 1);

      await db_utils.deleteFrom('drink', drinkId);
      profiles = await db_utils.queryFrom('profile');
      expect(profiles.length, 0);
    });

    test('profile belonging to drink can be deleted', () async {
      final Map<String, dynamic> drink = getDrink();
      final Map<String, dynamic> profile = getProfile();

      final int? drinkId =
          await db_utils.insertInto('drink', drink, drink['id']) as int?;
      profile['drink_id'] = drinkId;
      final int? profileId =
          await db_utils.insertInto('profile', profile, profile['id']) as int?;

      final int res = await db_utils.deleteFrom('profile', profileId);

      expect(res, 1);
    });

    test('session id is unique', () async {
      // Not supported on indexed db
      if (!useSqfLiteDb) return;

      final Map<String, dynamic> session =
          getSession(<String, dynamic>{'id': 1});

      await db_utils.insertInto('session', session, session['id']);

      expect(
        () async => db_utils.insertInto('session', session, session['id']),
        throwsA(isA<DatabaseException>()),
      );
    });
  });
}

Map<String, dynamic> getDrinkDefaultValues() {
  return <String, dynamic>{
    'id': 1,
    'chain_id': 1,
    'name': 'Drink name',
    'name_id': 'drink_name_id',
    'logo': 'drink_logo',
    'background_color': 'drink_background_color',
  };
}

Map<String, dynamic> getDrink([Map<String, dynamic>? values]) {
  return <String, dynamic>{
    'id': values?['id'],
    'chain_id': values?['chain_id'],
    'name': values?['name'],
    'name_id': values?['name_id'],
    'logo': values?['logo'],
    'background_color': values?['background_color'],
  };
}

Map<String, dynamic> getDrinkWithValues([Map<String, dynamic>? values]) {
  return getDrink(values).map(
    (String key, dynamic value) => value != null
        ? MapEntry<String, dynamic>(key, value)
        : MapEntry<String, dynamic>(key, getDrinkDefaultValues()[key]),
  );
}

Map<String, dynamic> getProfileDefaultValues() {
  return <String, dynamic>{
    'id': 1,
    'drink_id': 1,
    'name': 'Profile name',
    'name_id': 'profile_name_id',
    'logo': 'profile_logo',
    'color': 'profile_color',
    'background_color': 'profile_background_color',
  };
}

Map<String, dynamic> getProfile([Map<String, dynamic>? values]) {
  final Map<String, dynamic> profile = <String, dynamic>{
    'id': values?['id'],
    'drink_id': values?['drink_id'],
    'name': values?['name'],
    'name_id': values?['name_id'],
    'logo': values?['logo'],
    'color': values?['color'],
    'background_color': values?['background_color'],
  };

  if (values?['drink'] != null) {
    profile.putIfAbsent('drink', () => values?['drink']);
  }

  return profile;
}

Map<String, dynamic> getProfileWithValues([Map<String, dynamic>? values]) {
  return getProfile(values).map(
    (String key, dynamic value) => value != null
        ? MapEntry<String, dynamic>(key, value)
        : MapEntry<String, dynamic>(key, getProfileDefaultValues()[key]),
  );
}

Map<String, dynamic> getSessionDefaultValues() {
  return <String, dynamic>{
    'id': 1,
    'profile_id': 1,
    'drink_id': 1,
    'filename': 'session_filename',
    'description': 'Session description',
    'type': 'instructor',
  };
}

Map<String, dynamic> getSession([Map<String, dynamic>? values]) {
  final Map<String, dynamic> session = <String, dynamic>{
    'id': values?['id'],
    'profile_id': values?['profile_id'],
    'drink_id': values?['drink_id'],
    'filename': values?['filename'],
    'description': values?['description'],
    'type': values?['type'],
  };

  if (values?['profile'] != null) {
    session.putIfAbsent('profile', () => values?['profile']);
  }
  if (values?['drink'] != null) {
    session.putIfAbsent('drink', () => values?['drink']);
  }

  return session;
}

Map<String, dynamic> getSessionWithValues([Map<String, dynamic>? values]) {
  return getSession(values).map(
    (String key, dynamic value) => value != null
        ? MapEntry<String, dynamic>(key, value)
        : MapEntry<String, dynamic>(key, getSessionDefaultValues()[key]),
  );
}
