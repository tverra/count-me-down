import 'package:count_me_down/database/db_repos.dart';
import 'package:count_me_down/database/db_utils.dart';
import 'package:count_me_down/models/profile.dart';
import 'package:count_me_down/models/session.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../data_generator.dart' as generator;
import '../../test_db_utils.dart' as db_utils;
import '../../test_utils.dart' as test_utils;

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

  group('getLatestProfile', () {
    // ToDo: test
  });

  group('getProfile', () {
    late Profile _profile;

    setUp(() async {
      _profile = await generator.insertProfile();
    });

    test('rows are inserted in setup', () async {
      final Profile profile = (await db_utils.getProfiles()).single;

      expect(profile, _profile);
    });

    test('id is auto-incremented', () async {
      final Profile profile = generator.getProfile();
      profile.id = null;
      final int? id = (await insertProfile(profile)).id;
      final List<Profile> insertedProfiles = await getProfiles();
      expect(id == null, false);
      expect(insertedProfiles.last.id, id);
    });

    test('returns row on given id', () async {
      final Profile profile = (await getProfile(_profile.id!))!;
      expect(profile, _profile);
    });

    test('return null if no rows exists', () async {
      await test_utils.clearDb();

      final Profile? profile = await getProfile(_profile.id!);
      expect(profile, null);
    });

    test('preloading sessions returns null if no profiles exists', () async {
      await test_utils.clearDb();

      final Profile? profile = await getProfile(
        _profile.id!,
        preloadArgs: <String>[Profile.relSessions],
      );
      expect(profile, null);
    });

    test('returns null if id is invalid', () async {
      final Profile? profile = await getProfile(-1);
      expect(profile, null);
    });

    test('invalid preload returns no preloads', () async {
      final Profile profile = (await getProfile(
        _profile.id!,
        preloadArgs: <String>['invalid'],
      ))!;

      expect(profile.sessions, null);
    });

    test('sessions are null if not preloaded', () async {
      await generator.insertSession();

      for (int i = 0; i < 5; i++) {
        await generator.insertSession(profileId: _profile.id);
      }

      final Profile profile = (await getProfile(_profile.id!))!;
      expect(profile.sessions, null);
    });

    test('preloading sessions returns list of sessions', () async {
      final List<Session> sessions = <Session>[];
      await generator.insertSession();

      for (int i = 0; i < 5; i++) {
        sessions.add(await generator.insertSession(profileId: _profile.id));
      }

      final Profile profile = (await getProfile(
        _profile.id!,
        preloadArgs: <String>[Profile.relSessions],
      ))!;

      expect(profile.sessions, sessions);
    });

    test('preloading sessions returns empty list if no sessions', () async {
      final Profile profile = (await getProfile(
        _profile.id!,
        preloadArgs: <String>[Profile.relSessions],
      ))!;
      expect(profile.sessions, <Session>[]);
    });
  });

  group('getProfiles', () {
    late List<Profile> _profiles;

    setUp(() async {
      _profiles = <Profile>[];

      for (int i = 0; i < 10; i++) {
        _profiles.add(await generator.insertProfile());
      }
    });

    test('rows are inserted in setup', () async {
      final List<Profile> profiles = await db_utils.getProfiles();

      expect(profiles, _profiles);
    });

    test('returns all rows', () async {
      final List<Profile> profiles = await getProfiles();
      expect(profiles, _profiles);
    });

    test('returns empty list if no rows', () async {
      await test_utils.clearDb();

      final List<Profile> profiles = await getProfiles();
      expect(profiles, <Profile>[]);
    });

    test('preloading children on empty row returns empty list', () async {
      await test_utils.clearDb();

      final List<Profile> profiles = await getProfiles(
        preloadArgs: <String>[
          Profile.relSessions,
        ],
      );

      expect(profiles, <Profile>[]);
    });

    test('sessions are null if not preloaded', () async {
      final List<Profile> profiles = await getProfiles();

      for (int i = 0; i < profiles.length; i++) {
        expect(profiles[i].sessions, null);
      }
    });

    test('sessions are empty list if no sessions exists', () async {
      final List<Profile> profiles =
          await getProfiles(preloadArgs: <String>[Profile.relSessions]);

      for (int i = 0; i < profiles.length; i++) {
        expect(profiles[i].sessions, <Profile>[]);
      }
    });

    test('invalid preload returns no preloads', () async {
      final List<Profile> profiles =
          await getProfiles(preloadArgs: <String>['invalid']);

      for (final Profile profile in profiles) {
        expect(profile.sessions, null);
      }
    });

    test('preloading children on empty row returns empty list', () async {
      await test_utils.clearDb();

      final List<Profile> profiles = await getProfiles(
        preloadArgs: <String>[Profile.relSessions],
      );

      for (final Profile profile in profiles) {
        expect(profile, <Profile>[]);
      }
    });

    test('preloading sessions returns list of sessions', () async {
      final List<Session> sessions = <Session>[];
      await generator.insertSession(profileId: -1);

      for (final Profile profile in _profiles) {
        for (int i = 0; i < 5; i++) {
          sessions.add(await generator.insertSession(profileId: profile.id));
        }
      }
      final List<Profile> profiles =
          await getProfiles(preloadArgs: <String>[Profile.relSessions]);

      for (int i = 0; i < profiles.length; i++) {
        expect(
          profiles[i].sessions,
          sessions.getRange(i * 5, (i + 1) * 5).toList(),
        );
      }
    });
  });

  group('insertProfile', () {
    late Profile _profile;

    setUp(() async {
      _profile = generator.getProfile();
    });

    test('no rows are inserted in setup', () async {
      final List<Profile> res = await db_utils.getProfiles();
      expect(res.length, 0);
    });

    test('inserts row into table', () async {
      await insertProfile(_profile);

      final Profile profile = (await getProfile(_profile.id!))!;
      expect(profile, _profile);
    });

    test('correct id is returned after insertion', () async {
      _profile.id = 1000;
      final Profile updated = await insertProfile(_profile);
      final Profile inserted = (await getProfile(_profile.id!))!;

      expect(updated.id, 1000);
      expect(inserted.id, 1000);
    });

    test('inserting on existing id replaces previous data', () async {
      await insertProfile(_profile);
      _profile.name = 'test';
      await insertProfile(_profile);

      final Profile profile = (await getProfile(_profile.id!))!;
      expect(profile, _profile);
    });
  });

  group('insertProfiles', () {
    late List<Profile> _profiles;

    setUp(() async {
      _profiles = <Profile>[];

      for (int i = 0; i < 10; i++) {
        _profiles.add(generator.getProfile());
      }
    });

    test('no rows are inserted in setup', () async {
      final List<Profile> profiles = await db_utils.getProfiles();
      expect(profiles.length, 0);
    });

    test('rows are inserted', () async {
      await insertProfiles(_profiles);

      final List<Profile> profiles = await getProfiles();
      expect(profiles, _profiles);
    });

    test('inserts no row if empty list is given', () async {
      await insertProfiles(<Profile>[]);

      final List<Profile> profiles = await getProfiles();
      expect(profiles, <Profile>[]);
    });

    test('correct ids are returned after inserting', () async {
      final List<int> expected = <int>[];

      for (int i = 0; i < _profiles.length; i++) {
        _profiles[i].id = 1000 + i;
        expected.add(1000 + i);
      }
      final List<Profile> updated = await insertProfiles(_profiles);

      final List<int> actual = updated.map((Profile s) => s.id!).toList();

      expect(actual, expected);
    });

    test('inserting on existing id replaces previous data', () async {
      final List<Profile> result = await insertProfiles(_profiles);

      for (int i = 0; i < result.length; i++) {
        _profiles[i].name = 'test';
      }

      await insertProfiles(_profiles);

      final List<Profile> profiles = await getProfiles();
      for (int i = 0; i < _profiles.length; i++) {
        expect(_profiles[i], profiles[i]);
      }
    });

    test('inserting the same row multiple times returns correct result',
        () async {
      final List<Profile> profiles = <Profile>[];
      for (int i = 0; i < 10; i++) {
        final Profile copy = _profiles[i].copy();
        copy.id = 1;
        profiles.add(copy);
      }
      final List<Profile> result = await insertProfiles(profiles);

      expect(result, profiles);
    });
  });

  group('updateProfile', () {
    late Profile _profile;

    setUp(() async {
      _profile = await generator.insertProfile();
    });

    test('row is inserted in setup', () async {
      final Profile profile = (await db_utils.getProfiles()).single;

      expect(profile, _profile);
    });

    test('profiles are updated', () async {
      _profile.name = 'test';
      await updateProfile(_profile);

      final Profile profile = (await getProfile(_profile.id!))!;
      expect(profile, _profile);
    });

    test('returns the updated row', () async {
      _profile.name = 'test';
      final Profile? result = await updateProfile(_profile);

      expect(result, _profile);
    });

    test('no rows are updated if id is invalid', () async {
      _profile.id = -1;

      final Profile? result = await updateProfile(_profile);

      expect(result, null);
    });

    test('updates existing row if insertMissing is true', () async {
      _profile.name = 'test';
      await updateProfile(_profile, insertMissing: true);

      final Profile? profile = await getProfile(_profile.id!);
      expect(profile, _profile);
    });

    test('updating non-existing row inserts row if insertMissing is true',
        () async {
      final Profile nonInserted = generator.getProfile();
      final Profile? updated =
          await updateProfile(nonInserted, insertMissing: true);

      final Profile? inserted = await getProfile(updated!.id!);
      expect(inserted, nonInserted);
    });

    test('updating non-existing row does nothing if insertMissing is false',
        () async {
      final Profile nonInserted = generator.getProfile(id: 1000);
      final Profile? result = await updateProfile(nonInserted);

      final Profile? updated = await getProfile(1000);
      expect(result, null);
      expect(updated, null);
    });

    test('updates on the correct id', () async {
      final String initialName = _profile.name!;
      _profile.id = _profile.id! + 1;
      _profile.name = 'profile_name_id${_profile.id! + 1}';
      await insertProfile(_profile);

      _profile.name = 'test';
      await updateProfile(_profile);

      final List<Profile> profiles = await getProfiles();

      expect(profiles[0].name, initialName);
      expect(profiles[1].name, _profile.name);
    });
  });

  group('updateProfiles', () {
    late List<Profile> _profiles;

    setUp(() async {
      _profiles = <Profile>[];

      for (int i = 0; i < 10; i++) {
        _profiles.add(await generator.insertProfile());
      }
    });

    test('rows are inserted in setup', () async {
      final List<Profile> profiles = await db_utils.getProfiles();

      expect(profiles, _profiles);
    });

    test('profiles are updated', () async {
      final List<Profile> toBeUpdated = <Profile>[];

      for (final Profile profile in _profiles) {
        final Profile copy = profile.copy();
        copy.name = 'test';
        toBeUpdated.add(copy);
      }
      await updateProfiles(toBeUpdated);
      final List<Profile> profiles = await getProfiles();

      for (int i = 0; i < _profiles.length; i++) {
        expect(profiles[i], toBeUpdated[i]);
      }
    });

    test('updates no rows if empty list is given', () async {
      await updateProfiles(<Profile>[]);

      final List<Profile> profiles = await getProfiles();
      expect(profiles, _profiles);
    });

    test('updating returns the affected rows', () async {
      final List<Profile> result = await updateProfiles(_profiles);
      expect(result, _profiles);
    });

    test('updating does not return unaffected rows', () async {
      _profiles[2].id = -1;
      final List<Profile> result = await updateProfiles(_profiles);

      final List<Profile> expected = List<Profile>.from(_profiles);
      expected.removeAt(2);

      expect(result, expected);
    });

    test('the correct row is updated', () async {
      _profiles[3].name = 'updated';
      await updateProfiles(_profiles);
      final List<Profile> profiles = await getProfiles();

      expect(profiles.length, _profiles.length);
      for (int i = 0; i < _profiles.length; i++) {
        expect(_profiles[i].name, profiles[i].name);
      }
    });

    test('updating non-existing row inserts row if insertMissing is true',
        () async {
      final Profile nonInserted = generator.getProfile();
      _profiles.add(nonInserted);

      final List<Profile> updated =
          await updateProfiles(_profiles, insertMissing: true);

      _profiles.last.id = updated.last.id;

      final List<Profile> profiles = await getProfiles();
      expect(profiles, _profiles);
    });

    test('updating non-existing row does nothing if insertMissing is false',
        () async {
      final Profile nonInserted = generator.getProfile();
      final List<Profile> nonUpdatedList = List<Profile>.from(_profiles);
      nonUpdatedList.add(nonInserted);
      await updateProfiles(nonUpdatedList);

      final List<Profile> profiles = await getProfiles();
      expect(profiles, _profiles);
    });

    test('updates rows in table if insertMissing is true', () async {
      final List<Profile> toBeUpdated = <Profile>[];

      for (final Profile profile in _profiles) {
        final Profile copy = profile.copy();
        copy.name = 'updated';
        toBeUpdated.add(copy);
      }
      await updateProfiles(toBeUpdated, insertMissing: true);
      final List<Profile> profiles = await getProfiles();

      for (int i = 0; i < _profiles.length; i++) {
        expect(profiles[i], toBeUpdated[i]);
      }
    });

    test('removes non-existing rows if removeDeleted is true', () async {
      _profiles.removeAt(6);
      await updateProfiles(_profiles, removeDeleted: true);

      final List<Profile> profiles = await getProfiles();
      expect(profiles, _profiles);
    });

    test('does not change non-existing rows if removeDeleted is false',
        () async {
      final List<Profile> updatedProfiles = <Profile>[];
      for (int i = 0; i < _profiles.length; i++) {
        if (i != 6) updatedProfiles.add(_profiles[i]);
      }
      await updateProfiles(_profiles, removeDeleted: false);

      final List<Profile> profiles = await getProfiles();
      expect(profiles, _profiles);
    });

    test('updates rows in table when removeDeleted is true', () async {
      final List<Profile> toBeUpdated = <Profile>[];

      for (final Profile profile in _profiles) {
        final Profile copy = profile.copy();
        copy.name = 'updated';
        toBeUpdated.add(copy);
      }
      await updateProfiles(toBeUpdated, removeDeleted: true);
      final List<Profile> profiles = await getProfiles();

      for (int i = 0; i < _profiles.length; i++) {
        expect(profiles[i], toBeUpdated[i]);
      }
    });

    test('updating both inserts and removes rows', () async {
      final Profile nonInserted = generator.getProfile();
      _profiles.removeAt(6);
      _profiles.add(nonInserted);

      final Profile updated = (await updateProfiles(
        _profiles,
        insertMissing: true,
        removeDeleted: true,
      ))
          .single;

      _profiles.last.id = updated.id;

      final List<Profile> profiles = await getProfiles();
      expect(profiles, _profiles);
    });
  });

  group('deleteProfile', () {
    late Profile _profile;

    setUp(() async {
      _profile = await generator.insertProfile();
    });

    test('row is inserted in setup', () async {
      final Profile profile = (await db_utils.getProfiles()).single;

      expect(profile, _profile);
    });

    test('row is deleted', () async {
      await deleteProfile(_profile);
      final List<Profile> profiles = await getProfiles();
      expect(profiles, <Profile>[]);
    });

    test('deletes only given row', () async {
      final Profile profile = generator.getProfile();
      await insertProfile(profile);
      await deleteProfile(_profile);

      final List<Profile> profiles = await getProfiles();
      expect(profiles, <Profile>[profile]);
    });

    test('returns number of rows affected', () async {
      final int result = await deleteProfile(_profile);
      expect(result, 1);
    });

    test('returns zero if no rows are affected ', () async {
      final Profile profile = generator.getProfile();

      final int result = await deleteProfile(profile);
      expect(result, 0);
    });
  });

  group('deleteProfiles', () {
    late List<Profile> _profiles;

    setUp(() async {
      _profiles = <Profile>[];

      for (int i = 0; i < 10; i++) {
        _profiles.add(await generator.insertProfile());
      }
    });

    test('rows are inserted in setup', () async {
      final List<Profile> profiles = await db_utils.getProfiles();

      expect(profiles, _profiles);
    });

    test('profiles are deleted', () async {
      await deleteProfiles();
      final List<Profile> profiles = await getProfiles();
      expect(profiles, <Profile>[]);
    });

    test('returns number of rows affected', () async {
      final int actual = await deleteProfiles();
      expect(actual, _profiles.length);
    });

    test('deleting on empty table returns number of rows affected', () async {
      await test_utils.clearDb();
      final int actual = await deleteProfiles();

      expect(actual, 0);
    });
  });
}
