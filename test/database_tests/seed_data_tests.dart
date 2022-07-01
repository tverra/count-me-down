import 'package:count_me_down/database/db_repos.dart';
import 'package:count_me_down/database/db_utils.dart';
import 'package:count_me_down/models/drink.dart';
import 'package:count_me_down/models/preferences.dart';
import 'package:count_me_down/models/profile.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../test_utils.dart' as test_utils;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  if (useSqfLiteDb) {
    sqfliteFfiInit();
  }

  group('seed data is inserted', () {
    setUp(() async {
      await test_utils.loadTestDb(seed: true);
    });

    test('dummy profile is inserted', () async {
      final List<Profile> profiles = await getProfiles();

      expect(profiles.length, 1);
    });

    test('example drinks are inserted', () async {
      final List<Drink> drinks = await getDrinks();

      expect(drinks.length, 3);
    });

    test('preferences is inserted and contains dummy profile', () async {
      final Preferences preferences = await getPreferences();
      final List<Profile> profiles = await getProfiles();

      expect(preferences.activeProfileId, profiles[0].id);
    });
  });
}
