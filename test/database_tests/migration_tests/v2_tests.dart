import 'package:flutter_test/flutter_test.dart';
import 'package:count_me_down/database/db_utils.dart';
import 'package:count_me_down/database/db_utils.dart' as db_utils;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../test_utils.dart' as test_utils;
import 'v1_tests.dart' as v1;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  if (useSqfLiteDb) {
    sqfliteFfiInit();
  }

  group('v2 in-memory db tests', () {
    setUp(() async {
      await test_utils.closeDb();
      await test_utils.loadTestDb(version: 1);
    });

    tearDown(() async {
      await test_utils.closeDb();
    });

    test('database is created', () async {
      final Map<String, dynamic> profile =
          v1.getProfileWithValues(<String, dynamic>{'id': 10, 'chain_id': 100});

      final Map<String, dynamic> session =
          v1.getSessionWithValues(<String, dynamic>{
        'id': 40,
        'profile_id': profile['id'] as int,
      });

      final Map<String, dynamic> preferences =
          getPreferencesWithValues(<String, dynamic>{
        'current_session_id': session['id'] as int,
        'current_profile_id': profile['id'] as int,
      });

      await db_utils.insertInto('profile', profile, profile['id']);
      await db_utils.insertInto('session', session, session['id']);
      await db_utils.insertInto('preferences', preferences, 'preferences');

      final Map<String, dynamic> insertedProfile =
          (await db_utils.queryFrom('profile')).single;
      final Map<String, dynamic> insertedSession =
          (await db_utils.queryFrom('session')).single;
      final Map<String, dynamic> insertedPreferences =
          (await db_utils.queryFrom('preferences')).single;

      expect(profile, insertedProfile);
      expect(session, insertedSession);
      expect(preferences, insertedPreferences);
    });

    test('only required values inserted', () async {
      final Map<String, dynamic> profile = v1.getProfile();
      final Map<String, dynamic> session = v1.getSession();
      final Map<String, dynamic> preferences = getPreferences();

      final int? profileId =
          await db_utils.insertInto('profile', profile, profile['id']) as int?;
      final int? sessionId =
          await db_utils.insertInto('session', session, session['id']) as int?;
      await db_utils.insertInto('preferences', preferences, 'preferences');

      final Map<String, dynamic> insertedProfile =
          (await db_utils.queryFrom('profile')).single;
      final Map<String, dynamic> insertedSession =
          (await db_utils.queryFrom('session')).single;
      final Map<String, dynamic> insertedPreferences =
          (await db_utils.queryFrom('preferences')).single;

      if (useSqfLiteDb) {
        profile['id'] = profileId;
        session['id'] = sessionId;
      }

      expect(insertedProfile, profile, reason: 'failed: profile');
      expect(insertedSession, session, reason: 'failed: session');
      expect(insertedPreferences, preferences, reason: 'failed: preferences');
    });

    test('session is referenced in preferences', () async {
      // Not supported on indexed db
      if (!useSqfLiteDb) return;

      final Map<String, dynamic> preferences = getPreferences();
      final Map<String, dynamic> session = v1.getSession();

      final int? sessionId =
          await db_utils.insertInto('session', session, session['id']) as int?;
      preferences['current_session_id'] = sessionId! + 1;

      expect(
        () async =>
            db_utils.insertInto('preferences', preferences, 'preferences'),
        throwsA(isA<DatabaseException>()),
      );
    });

    test('profile is referenced in preferences', () async {
      // Not supported on indexed db
      if (!useSqfLiteDb) return;

      final Map<String, dynamic> preferences = getPreferences();
      final Map<String, dynamic> profile = v1.getProfile();

      final int? profileId =
          await db_utils.insertInto('profile', profile, profile['id']) as int?;
      preferences['current_profile_id'] = profileId! + 1;

      expect(
        () async =>
            db_utils.insertInto('preferences', preferences, 'preferences'),
        throwsA(isA<DatabaseException>()),
      );
    });

    test('preferences session_id is set to null if session is deleted',
        () async {
      // Not supported on indexed db
      if (!useSqfLiteDb) return;

      final Map<String, dynamic> preferences = getPreferences();
      final Map<String, dynamic> session = v1.getSession();

      final int? sessionId =
          await db_utils.insertInto('session', session, session['id']) as int?;
      preferences['current_session_id'] = sessionId;
      await db_utils.insertInto('preferences', preferences, 'preferences');

      List<Map<String, dynamic>> preferencesList =
          await db_utils.queryFrom('preferences');
      expect(preferencesList.single['current_session_id'], sessionId);

      await db_utils.deleteFrom('session', sessionId);
      preferencesList = await db_utils.queryFrom('preferences');
      expect(preferencesList.single['current_session_id'], null);
    });

    test('preferences profile_id is set to null if profile is deleted',
        () async {
      // Not supported on indexed db
      if (!useSqfLiteDb) return;

      final Map<String, dynamic> preferences = getPreferences();
      final Map<String, dynamic> profile = v1.getProfile();

      final int? profileId =
          await db_utils.insertInto('profile', profile, profile['id']) as int?;
      preferences['current_profile_id'] = profileId;
      await db_utils.insertInto('preferences', preferences, 'preferences');

      List<Map<String, dynamic>> preferencesList =
          await db_utils.queryFrom('preferences');
      expect(preferencesList.single['current_profile_id'], profileId);

      await db_utils.deleteFrom('profile', profileId);
      preferencesList = await db_utils.queryFrom('preferences');
      expect(preferencesList.single['current_profile_id'], null);
    });
  });
}

Map<String, dynamic> getPreferencesDefaultValues() {
  return <String, dynamic>{
    'current_session_id': 1,
    'current_profile_id': 1,
    'current_studio_id': 1,
  };
}

Map<String, dynamic> getPreferences([Map<String, dynamic>? values]) {
  final Map<String, dynamic> preferences = <String, dynamic>{
    'current_session_id': values?['current_session_id'],
    'current_profile_id': values?['current_profile_id'],
    'current_studio_id': values?['current_studio_id'],
  };

  if (values?['current_studio'] != null) {
    preferences.putIfAbsent(
      'current_studio',
      () => values?['current_studio'],
    );
  }
  if (values?['current_profile'] != null) {
    preferences.putIfAbsent(
      'current_profile',
      () => values?['current_profile'],
    );
  }
  if (values?['current_session'] != null) {
    preferences.putIfAbsent(
        'current_session', () => values?['current_session']);
  }

  return preferences;
}

Map<String, dynamic> getPreferencesWithValues([
  Map<String, dynamic>? values,
]) {
  return getPreferences(values).map(
    (String key, dynamic value) => value != null
        ? MapEntry<String, dynamic>(key, value)
        : MapEntry<String, dynamic>(
            key,
            getPreferencesDefaultValues()[key],
          ),
  );
}
