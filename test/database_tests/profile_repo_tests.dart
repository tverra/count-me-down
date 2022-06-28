import 'package:count_me_down/database/database.dart';
import 'package:count_me_down/database/db_repo.dart';
import 'package:count_me_down/models/profile.dart';
import 'package:count_me_down/models/session.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_ffi_test/sqflite_ffi_test.dart';

import '../data_generator.dart';
import '../test_utils.dart';

main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiTestInit();
  Database _db;
  DataGenerator _generator;

  setUp(() async {
    _db = await DBProvider.db.getDatabase(inMemory: true, seed: false);
    _generator = DataGenerator(_db);
  });

  tearDown(() async {
    await TestUtils.clearDb(_db);
  });

  group('getProfile', () {
    Profile _profile;

    setUp(() async {
      _profile = await _generator.insertProfile();
    });

    test('rows are inserted in setup', () async {
      final List<Map<String, dynamic>> res = await _db.query(Profile.tableName);
      final Profile profile = res.map((p) => Profile.fromMap(p)).single;

      expect(profile, _profile);
    });

    test('returns row on given id', () async {
      final Profile profile = await ProfileRepo.getProfile(_profile.id);
      expect(profile, _profile);
    });

    test('return null if no rows exists', () async {
      await TestUtils.clearDb(_db);

      final Profile profile = await ProfileRepo.getProfile(_profile.id);
      expect(profile, null);
    });

    test('preloading sessions returns null if no profiles exists', () async {
      await TestUtils.clearDb(_db);

      final Profile profile = await ProfileRepo.getProfile(_profile.id);
      expect(profile, null);
    });

    test('returns null if id is invalid', () async {
      final Profile profile = await ProfileRepo.getProfile(-1);
      expect(profile, null);
    });

    test('sessions are null if not preloaded', () async {
      await _generator.insertSession();

      for (int i = 0; i < 5; i++) {
        await _generator.insertSession(profileId: _profile.id);
      }

      final Profile profile = await ProfileRepo.getProfile(_profile.id);
      expect(profile.sessions, null);
    });

    test('preloading sessions returns list of sessions', () async {
      final List<Session> sessions = <Session>[];
      await _generator.insertSession();

      for (int i = 0; i < 5; i++) {
        sessions.add(await _generator.insertSession(profileId: _profile.id));
      }

      final Profile profile = await ProfileRepo.getProfile(_profile.id,
          preloadArgs: [Profile.relSessions]);
      expect(profile.sessions, sessions);
    });

    test('preloading sessions returns empty list if no sessions', () async {
      final Profile profile = await ProfileRepo.getProfile(_profile.id,
          preloadArgs: [Profile.relSessions]);
      expect(profile.sessions, []);
    });
  });

  group('getProfiles', () {
    List<Profile> _profiles;

    setUp(() async {
      _profiles = <Profile>[];

      for (int i = 0; i < 10; i++) {
        _profiles.add(await _generator.insertProfile());
      }
    });

    test('rows are inserted in setup', () async {
      final List<Map<String, dynamic>> res = await _db.query(Profile.tableName);
      final List<Profile> profiles =
          res.map((p) => Profile.fromMap(p)).toList();

      expect(profiles, _profiles);
    });

    test('returns all rows', () async {
      final List<Profile> profiles = await ProfileRepo.getProfiles();
      expect(profiles, _profiles);
    });

    test('returns empty list if no rows', () async {
      await TestUtils.clearDb(_db);

      final List<Profile> profiles = await ProfileRepo.getProfiles();
      expect(profiles, []);
    });

    test('preloading children on empty row returns empty list', () async {
      await TestUtils.clearDb(_db);

      final List<Profile> profiles =
          await ProfileRepo.getProfiles(preloadArgs: [Profile.relSessions]);

      expect(profiles, []);
    });

    test('sessions are null if not preloaded', () async {
      final List<Profile> profiles = await ProfileRepo.getProfiles();

      for (int i = 0; i < profiles.length; i++) {
        expect(profiles[i].sessions, null);
      }
    });

    test('sessions are empty list if no sessions exists', () async {
      final List<Profile> profiles =
          await ProfileRepo.getProfiles(preloadArgs: [Profile.relSessions]);

      for (int i = 0; i < profiles.length; i++) {
        expect(profiles[i].sessions, []);
      }
    });

    test('preloading children on empty row returns empty list', () async {
      await TestUtils.clearDb(_db);

      final List<Profile> profiles =
          await ProfileRepo.getProfiles(preloadArgs: [Profile.relSessions]);

      profiles.forEach((profile) => expect(profile, []));
    });

    test('preloading sessions returns list of sessions', () async {
      final List<Session> sessions = <Session>[];
      await _generator.insertSession(profileId: 0);

      for (Profile profile in _profiles) {
        for (int i = 0; i < 5; i++) {
          sessions.add(await _generator.insertSession(profileId: profile.id));
        }
      }
      final List<Profile> profiles =
          await ProfileRepo.getProfiles(preloadArgs: [Profile.relSessions]);

      for (int i = 0; i < profiles.length; i++) {
        expect(profiles[i].sessions,
            sessions.getRange(i * 5, (i + 1) * 5).toList());
      }
    });
  });

  group('insertProfile', () {
    Profile _profile;

    setUp(() {
      _profile = _generator.getProfile();
    });

    test('no rows are inserted in setup', () async {
      final List<Map<String, dynamic>> res = await _db.query(Profile.tableName);
      expect(res, []);
    });

    test('inserts row into table', () async {
      await ProfileRepo.insertProfile(_profile);

      final Profile profile = await ProfileRepo.getProfile(_profile.id);
      expect(profile, _profile);
    });

    test('id is auto-incremented', () async {
      final Profile profile = _generator.getProfile();
      profile.id = null;
      final int id = await ProfileRepo.insertProfile(profile);
      final Profile insertedProfile = await ProfileRepo.getProfile(null);

      expect(id == null, false);
      expect(insertedProfile, null);
    });

    test('correct id is returned after insertion', () async {
      _profile.id = 10;
      final int actual = await ProfileRepo.insertProfile(_profile);
      final Profile insertedProfile = await ProfileRepo.getProfile(_profile.id);
      final int expected = insertedProfile.id;

      expect(actual, expected);
    });

    test('inserting on existing id replaces previous data', () async {
      await ProfileRepo.insertProfile(_profile);
      _profile.name = 'test';
      await ProfileRepo.insertProfile(_profile);

      final Profile profile = await ProfileRepo.getProfile(_profile.id);
      expect(profile, _profile);
    });
  });

  group('insertProfiles', () {
    List<Profile> _profiles;

    setUp(() {
      _profiles = <Profile>[];

      for (int i = 0; i < 10; i++) {
        _profiles.add(_generator.getProfile());
      }
    });

    test('no rows are inserted in setup', () async {
      final List<Map<String, dynamic>> res = await _db.query(Profile.tableName);
      expect(res, []);
    });

    test('rows are inserted', () async {
      await ProfileRepo.insertProfiles(_profiles);

      final List<Profile> profiles = await ProfileRepo.getProfiles();
      expect(profiles, _profiles);
    });

    test('inserts no row if empty list is given', () async {
      await ProfileRepo.insertProfiles([]);

      final List<Profile> profiles = await ProfileRepo.getProfiles();
      expect(profiles, []);
    });

    test('correct ids are returned after inserting', () async {
      for (int i = 0; i < _profiles.length; i++) {
        _profiles[i].id = i + 10;
      }
      final List actual = await ProfileRepo.insertProfiles(_profiles);

      final List<Profile> profiles = await ProfileRepo.getProfiles();
      final List expected = profiles.map((p) => p.id).toList();

      expect(actual, expected);
    });

    test('inserting on existing id replaces previous data', () async {
      final List<int> result = await ProfileRepo.insertProfiles(_profiles);

      for (int i = 0; i < result.length; i++) {
        _profiles[i].name = 'test';
      }
      await ProfileRepo.insertProfiles(_profiles);

      final List<Profile> profiles = await ProfileRepo.getProfiles();
      for (int i = 0; i < _profiles.length; i++) {
        expect(_profiles[i], profiles[i]);
      }
    });

    test('inserting the same row multiple times returns correct result',
        () async {
      final List<Profile> profiles = <Profile>[];
      for (int i = 0; i < 10; i++) {
        final Profile profile = _profiles[0];
        profile.id = 1;
        profiles.add(profile);
      }
      final List<int> result = await ProfileRepo.insertProfiles(profiles);

      expect(result, [1, 1, 1, 1, 1, 1, 1, 1, 1, 1]);
    });
  });

  group('updateProfile', () {
    Profile _profile;

    setUp(() async {
      _profile = await _generator.insertProfile();
    });

    test('row is inserted in setup', () async {
      final List<Map<String, dynamic>> res = await _db.query(Profile.tableName);
      final Profile profile = res.map((p) => Profile.fromMap(p)).single;

      expect(profile, _profile);
    });

    test('profiles are updated', () async {
      _profile.name = 'test';
      await ProfileRepo.updateProfile(_profile);

      final Profile profile = await ProfileRepo.getProfile(_profile.id);
      expect(profile, _profile);
    });

    test('number of updated rows are correct', () async {
      _profile.name = 'test';
      final int result = await ProfileRepo.updateProfile(_profile);

      expect(result, 1);
    });

    test('no rows are updated if id is invalid', () async {
      _profile.id = null;

      final int result = await ProfileRepo.updateProfile(_profile);
      expect(result, 0);
    });

    test('updates existing row if insertMissing is true', () async {
      _profile.name = 'test';
      await ProfileRepo.updateProfile(_profile, insertMissing: true);

      final Profile profile = await ProfileRepo.getProfile(_profile.id);
      expect(profile, _profile);
    });

    test('updating non-existing row inserts row if insertMissing is true',
        () async {
      final Profile nonInserted = _generator.getProfile();
      nonInserted.id = _profile.id + 1;
      await ProfileRepo.updateProfile(nonInserted, insertMissing: true);

      final Profile updated = await ProfileRepo.getProfile(nonInserted.id);
      expect(updated, nonInserted);
    });

    test('updating non-existing row does nothing if insertMissing is false',
        () async {
      final Profile nonInserted = _generator.getProfile();
      nonInserted.id = _profile.id + 1;
      final int result = await ProfileRepo.updateProfile(nonInserted);

      final Profile updated = await ProfileRepo.getProfile(nonInserted.id);
      expect(result, 0);
      expect(updated, null);
    });

    test('updates on the correct id', () async {
      final String initialName = _profile.name;
      _profile.id = _profile.id + 1;
      await ProfileRepo.insertProfile(_profile);
      _profile.name = 'test';
      await ProfileRepo.updateProfile(_profile);

      final List<Profile> profiles = await ProfileRepo.getProfiles();
      expect(profiles[0].name, initialName);
      expect(profiles[1].name, _profile.name);
    });
  });

  group('updateProfiles', () {
    List<Profile> _profiles;

    setUp(() async {
      _profiles = <Profile>[];

      for (int i = 0; i < 10; i++) {
        _profiles.add(await _generator.insertProfile());
      }
    });

    test('rows are inserted in setup', () async {
      final List<Map<String, dynamic>> res = await _db.query(Profile.tableName);
      final List<Profile> profiles =
          res.map((p) => Profile.fromMap(p)).toList();

      expect(profiles, _profiles);
    });

    test('profiles are updated', () async {
      for (final Profile profile in _profiles) {
        profile.name = 'test';
      }
      await ProfileRepo.updateProfiles(_profiles);
      final List<Profile> profiles = await ProfileRepo.getProfiles();

      for (int i = 0; i < _profiles.length; i++) {
        expect(profiles[i], _profiles[i]);
      }
    });

    test('updates no rows if empty list is given', () async {
      await ProfileRepo.updateProfiles([]);

      final List<Profile> profiles = await ProfileRepo.getProfiles();
      expect(profiles, _profiles);
    });

    test('updating returns correct number of rows affected', () async {
      final List<int> actual = await ProfileRepo.updateProfiles(_profiles);
      expect(actual.length, _profiles.length);
    });

    test('updating returns the ids of the affected rows', () async {
      final List<int> actual = await ProfileRepo.updateProfiles(_profiles);
      expect(actual, [1, 1, 1, 1, 1, 1, 1, 1, 1, 1]);
    });

    test('the correct row is updated', () async {
      final Profile profile = _profiles[3];
      profile.name = 'updated';
      await ProfileRepo.updateProfiles(_profiles);
      final List<Profile> profiles = await ProfileRepo.getProfiles();

      expect(profiles.length, _profiles.length);
      for (int i = 0; i < _profiles.length; i++) {
        expect(_profiles[i].name, profiles[i].name);
      }
    });

    test('updating non-existing row inserts row if insertMissing is true',
        () async {
      final Profile nonInserted = _generator.getProfile();
      _profiles.add(nonInserted);

      await ProfileRepo.updateProfiles(_profiles, insertMissing: true);

      final List<Profile> profiles = await ProfileRepo.getProfiles();
      expect(profiles, _profiles);
    });

    test('updating non-existing row does nothing if insertMissing is false',
        () async {
      final Profile nonInserted = _generator.getProfile();
      final List<Profile> nonUpdatedList = List.from(_profiles);
      nonUpdatedList.add(nonInserted);
      await ProfileRepo.updateProfiles(nonUpdatedList);

      final List<Profile> profiles = await ProfileRepo.getProfiles();
      expect(profiles, _profiles);
    });

    test('updates rows in table if insertMissing is true', () async {
      for (Profile profile in _profiles) {
        profile.name = 'updated';
      }
      await ProfileRepo.updateProfiles(_profiles, insertMissing: true);
      final List<Profile> profiles = await ProfileRepo.getProfiles();

      for (int i = 0; i < _profiles.length; i++) {
        expect(profiles[i], _profiles[i]);
      }
    });

    test('removes non-existing rows if removeDeleted is true', () async {
      _profiles.removeAt(6);
      await ProfileRepo.updateProfiles(_profiles, removeDeleted: true);

      final List<Profile> profiles = await ProfileRepo.getProfiles();
      expect(profiles, _profiles);
    });

    test('does not change non-existing rows if removeDeleted is false',
        () async {
      final List<Profile> updatedProfiles = <Profile>[];
      for (int i = 0; i < _profiles.length; i++) {
        if (i != 6) updatedProfiles.add(_profiles[i]);
      }
      await ProfileRepo.updateProfiles(_profiles, removeDeleted: false);

      final List<Profile> profiles = await ProfileRepo.getProfiles();
      expect(profiles, _profiles);
    });

    test('updates rows in table when removeDeleted is true', () async {
      for (Profile profile in _profiles) {
        profile.name = 'updated';
      }
      await ProfileRepo.updateProfiles(_profiles, removeDeleted: true);
      final List<Profile> profiles = await ProfileRepo.getProfiles();

      for (int i = 0; i < _profiles.length; i++) {
        expect(profiles[i], _profiles[i]);
      }
    });

    test('updating both inserts and removes rows', () async {
      final Profile nonInserted = _generator.getProfile();
      nonInserted.id = _profiles.last.id + 1;
      _profiles.removeAt(6);
      _profiles.add(nonInserted);

      await ProfileRepo.updateProfiles(_profiles,
          insertMissing: true, removeDeleted: true);

      final List<Profile> profiles = await ProfileRepo.getProfiles();
      expect(profiles, _profiles);
    });
  });

  group('deleteProfile', () {
    Profile _profile;

    setUp(() async {
      _profile = await _generator.insertProfile();
    });

    test('row is inserted in setup', () async {
      final List<Map<String, dynamic>> res = await _db.query(Profile.tableName);
      final Profile profile = res.map((p) => Profile.fromMap(p)).single;

      expect(profile, _profile);
    });

    test('row is deleted', () async {
      await ProfileRepo.deleteProfile(_profile);
      final List<Profile> profiles = await ProfileRepo.getProfiles();
      expect(profiles, []);
    });

    test('deletes only given row', () async {
      final Profile profile = _generator.getProfile();
      await ProfileRepo.insertProfile(profile);
      await ProfileRepo.deleteProfile(_profile);

      final List<Profile> profiles = await ProfileRepo.getProfiles();
      expect(profiles, [profile]);
    });

    test('returns number of rows affected', () async {
      _profile.id = _profile.id + 10;
      await ProfileRepo.insertProfile(_profile);

      final int result = await ProfileRepo.deleteProfile(_profile);
      expect(result, 1);
    });
  });

  group('deleteProfiles', () {
    List<Profile> _profiles;

    setUp(() async {
      _profiles = <Profile>[];

      for (int i = 0; i < 10; i++) {
        _profiles.add(await _generator.insertProfile());
      }
    });

    test('rows are inserted in setup', () async {
      final List<Map<String, dynamic>> res = await _db.query(Profile.tableName);
      final List<Profile> profiles =
          res.map((p) => Profile.fromMap(p)).toList();

      expect(profiles, _profiles);
    });

    test('profiles are deleted', () async {
      await ProfileRepo.deleteProfiles();
      final List<Profile> profiles = await ProfileRepo.getProfiles();
      expect(profiles, []);
    });

    test('returns number of rows affected', () async {
      final int actual = await ProfileRepo.deleteProfiles();
      expect(actual, _profiles.length);
    });

    test('deleting on empty table returns number of rows affected', () async {
      await TestUtils.clearDb(_db);
      final int actual = await ProfileRepo.deleteProfiles();

      expect(actual, 0);
    });
  });
}
