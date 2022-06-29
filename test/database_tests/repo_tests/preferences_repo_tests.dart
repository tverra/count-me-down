import 'package:count_me_down/database/db_repos.dart';
import 'package:count_me_down/database/db_utils.dart';
import 'package:count_me_down/models/preferences.dart';
import 'package:count_me_down/models/session.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_utils.dart' as test_utils;

import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../data_generator.dart' as generator;
import '../../test_db_utils.dart' as db_utils;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  if (useSqfLiteDb) {
    sqfliteFfiInit();
  }

  setUp(() async {
    await test_utils.loadTestDb();
  });

  tearDown(() async {
    await test_utils.clearDb();
  });

  group('getPreferences', () {
    late Preferences _preferences;

    setUp(() async {
      _preferences = await generator.insertPreferences();
    });

    test('rows are inserted in setup', () async {
      final Preferences preferences = (await db_utils.getPreferences()).single;

      expect(preferences, _preferences);
    });

    test('returns single row', () async {
      final Preferences preferences = await getPreferences();
      expect(preferences, _preferences);
    });

    test('returns latest row if multiple exists', () async {
      final List<Preferences> inserted = <Preferences>[];

      for (int i = 0; i < 5; i++) {
        inserted.add(
          await generator.insertPreferences(),
        );
      }

      final Preferences preferences = await getPreferences();
      expect(preferences, inserted.last);
    });

    test('return empty preferences if no rows exists', () async {
      await test_utils.clearDb();

      final Preferences preferences = await getPreferences();
      expect(preferences, Preferences());
    });

    test('preloading session includes session', () async {
      final Preferences preferences = await getPreferences(
        preloadArgs: <String>[Preferences.relActiveSession],
      );

      expect(preferences.activeSession, _preferences.activeSession);
    });

    test('preloading profile includes profile', () async {
      final Preferences preferences = await getPreferences(
        preloadArgs: <String>[Preferences.relActiveProfile],
      );

      expect(preferences.activeProfile, _preferences.activeProfile);
    });

    test('preloading non-existing session returns null', () async {
      await generator.insertPreferences(activeSessionId: -1);

      final Preferences insertedPreferences = await getPreferences(
        preloadArgs: <String>[Preferences.relActiveSession],
      );

      expect(insertedPreferences.activeSession, null);
    });

    test('preloading non-existing profile returns null', () async {
      await generator.insertPreferences(activeProfileId: -1);

      final Preferences insertedPreferences = await getPreferences(
        preloadArgs: <String>[Preferences.relActiveProfile],
      );

      expect(insertedPreferences.activeProfile, null);
    });

    test('invalid preload returns no preloads', () async {
      final Preferences preferences = await getPreferences(
        preloadArgs: <String>['invalid'],
      );

      expect(preferences.activeSession, null);
      expect(preferences.activeProfile, null);
    });

    test('preloading empty row returns empty preferences', () async {
      await test_utils.clearDb();

      final Preferences preferences = await getPreferences(
        preloadArgs: <String>[
          Preferences.relActiveSession,
          Preferences.relActiveProfile,
        ],
      );
      expect(preferences, Preferences());
    });
  });

  group('updatePreferences', () {
    late Preferences _preferences;

    setUp(() async {
      _preferences = await generator.insertPreferences();
    });

    test('row is inserted in setup', () async {
      final Preferences preferences = (await db_utils.getPreferences()).single;

      expect(preferences, _preferences);
    });

    test('preferences is updated', () async {
      final Session session = await generator.insertSession();
      _preferences.activeSessionId = session.id;
      await updatePreferences(_preferences);

      final Preferences preferences = await getPreferences();
      expect(preferences, _preferences);
    });

    test('returns the updated row', () async {
      final Session session = await generator.insertSession();
      _preferences.activeSessionId = session.id;
      final Preferences? result = await updatePreferences(_preferences);

      expect(result, _preferences);
    });

    test('updating non-existing row inserts row', () async {
      await test_utils.clearDb();
      final Preferences nonInserted = generator.getPreferences();
      await updatePreferences(nonInserted);

      final Preferences updated = await getPreferences();
      expect(updated, nonInserted);
    });

    test('updating replaces previous data', () async {
      final Session session = await generator.insertSession();
      await generator.insertPreferences();

      final Preferences toBeUpdated = _preferences;
      _preferences.activeSessionId = session.id;
      await updatePreferences(toBeUpdated);
      final Preferences preferences = await getPreferences();

      expect(preferences, toBeUpdated);
    });

    test('updating deletes previous rows', () async {
      for (int i = 0; i < 5; i++) {
        await generator.insertPreferences();
      }

      await updatePreferences(_preferences);

      final List<Preferences> preferences = await db_utils.getPreferences();

      expect(preferences.length, 1);
      expect(preferences[0].activeSessionId, _preferences.activeSessionId);
    });
  });
}
