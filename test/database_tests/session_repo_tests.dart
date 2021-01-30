import 'package:count_me_down/database/database.dart';
import 'package:count_me_down/database/db_repo.dart';
import 'package:count_me_down/models/drink.dart';
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

  group('getSession', () {
    Session _session;

    setUp(() async {
      _session = await _generator.insertSession();
    });

    test('rows are inserted in setup', () async {
      final List<Map<String, dynamic>> res = await _db.query(Session.tableName);
      final Session session = res.map((p) => Session.fromMap(p)).single;

      expect(session, _session);
    });

    test('returns row on given id', () async {
      final Session session = await SessionRepo.getSession(_session.id);
      expect(session, _session);
    });

    test('return null if no rows exists', () async {
      await TestUtils.clearDb(_db);

      final Session session = await SessionRepo.getSession(_session.id);
      expect(session, null);
    });

    test('preloading drinks returns null if no sessions exists', () async {
      await TestUtils.clearDb(_db);

      final Session session = await SessionRepo.getSession(_session.id);
      expect(session, null);
    });

    test('returns null if id is invalid', () async {
      final Session session = await SessionRepo.getSession(-1);
      expect(session, null);
    });

    test('preloading profile includes profile', () async {
      final Session session = await SessionRepo.getSession(_session.id,
          preloadArgs: [Session.relProfile]);

      expect(session.profile, _session.profile);
    });

    test('preloading non-existing profile returns null', () async {
      final Session session = _generator.getSession();
      session.profileId = null;
      await SessionRepo.insertSession(session);

      final Session insertedSession = await SessionRepo.getSession(session.id,
          preloadArgs: [Session.relProfile]);

      expect(insertedSession.profile, null);
    });

    test('preloading empty row returns null', () async {
      final Session session = await SessionRepo.getSession(_session.id + 1,
          preloadArgs: [Session.relProfile]);
      expect(session, null);
    });

    test('drinks are null if not preloaded', () async {
      await _generator.insertDrink();

      for (int i = 0; i < 5; i++) {
        await _generator.insertDrink(sessionId: _session.id);
      }

      final Session session = await SessionRepo.getSession(_session.id);
      expect(session.drinks, null);
    });

    test('preloading drinks returns list of drinks', () async {
      final List<Drink> drinks = <Drink>[];
      await _generator.insertDrink();

      for (int i = 0; i < 5; i++) {
        drinks.add(await _generator.insertDrink(sessionId: _session.id));
      }

      final Session session = await SessionRepo.getSession(_session.id,
          preloadArgs: [Session.relDrinks]);

      expect(session.drinks, drinks);
    });

    test('preloading drinks returns empty list if no drinks', () async {
      final Session session = await SessionRepo.getSession(_session.id,
          preloadArgs: [Session.relDrinks]);
      expect(session.drinks, []);
    });
  });

  group('getSessions', () {
    List<Session> _sessions;

    setUp(() async {
      _sessions = <Session>[];

      for (int i = 0; i < 10; i++) {
        _sessions.add(await _generator.insertSession());
      }
    });

    test('rows are inserted in setup', () async {
      final List<Map<String, dynamic>> res = await _db.query(Session.tableName);
      final List<Session> sessions =
          res.map((p) => Session.fromMap(p)).toList();

      expect(sessions, _sessions);
    });

    test('returns all rows', () async {
      final List<Session> sessions = await SessionRepo.getSessions();
      expect(sessions, _sessions);
    });

    test('returns all rows on profile id', () async {
      final List<Session> sessions = <Session>[];
      sessions.add(_sessions[2]);

      for (int i = 0; i < 3; i++) {
        final Session session = _generator.getSession();
        session.profileId = _sessions[2].profileId;
        sessions.add(session);
      }
      await SessionRepo.insertSessions(sessions);

      final List<Session> insertedSessions =
          await SessionRepo.getSessions(profileId: _sessions[2].profileId);
      expect(insertedSessions, sessions);
    });

    test('returns empty list if no rows', () async {
      await TestUtils.clearDb(_db);

      final List<Session> sessions = await SessionRepo.getSessions();
      expect(sessions, []);
    });

    test('preloading children on empty row returns empty list', () async {
      await TestUtils.clearDb(_db);

      final List<Session> sessions =
          await SessionRepo.getSessions(preloadArgs: [Session.relDrinks]);

      expect(sessions, []);
    });

    test('drinks are null if not preloaded', () async {
      final List<Session> sessions = await SessionRepo.getSessions();

      for (int i = 0; i < sessions.length; i++) {
        expect(sessions[i].drinks, null);
      }
    });

    test('drinks are empty list if no drinks exists', () async {
      final List<Session> sessions =
          await SessionRepo.getSessions(preloadArgs: [Session.relDrinks]);

      for (int i = 0; i < sessions.length; i++) {
        expect(sessions[i].drinks, []);
      }
    });

    test('preloading profile includes profile', () async {
      final List<Session> sessions =
          await SessionRepo.getSessions(preloadArgs: [Session.relProfile]);

      for (int i = 0; i < _sessions.length; i++) {
        expect(sessions[i].profile, _sessions[i].profile);
      }
    });

    test('preloading parent on profile id includes profile', () async {
      final List<Session> sessions = await SessionRepo.getSessions(
          profileId: _sessions[4].profileId, preloadArgs: [Session.relProfile]);

      expect(sessions[0].profile, _sessions[4].profile);
    });

    test('preloading non-existing parent returns null', () async {
      await TestUtils.clearDb(_db);
      final List<Session> sessions = <Session>[];

      for (int i = 0; i < 5; i++) {
        final Session session = _generator.getSession();
        session.profileId = null;
        sessions.add(session);
      }
      await SessionRepo.insertSessions(sessions);

      final List<Session> insertedSessions =
          await SessionRepo.getSessions(preloadArgs: [Session.relProfile]);

      insertedSessions.forEach((session) => expect(session.profile, null));
    });

    test('preloading parent on empty row returns empty list', () async {
      await TestUtils.clearDb(_db);

      final List<Session> sessions =
          await SessionRepo.getSessions(preloadArgs: [Session.relProfile]);

      sessions.forEach((session) => expect(session, []));
    });

    test('preloading children on empty row returns empty list', () async {
      await TestUtils.clearDb(_db);

      final List<Session> sessions =
          await SessionRepo.getSessions(preloadArgs: [Session.relDrinks]);

      sessions.forEach((session) => expect(session, []));
    });

    test('preloading drinks returns list of drinks', () async {
      final List<Drink> drinks = <Drink>[];
      await _generator.insertDrink(sessionId: 0);

      for (Session session in _sessions) {
        for (int i = 0; i < 5; i++) {
          drinks.add(await _generator.insertDrink(sessionId: session.id));
        }
      }
      final List<Session> sessions =
          await SessionRepo.getSessions(preloadArgs: [Session.relDrinks]);

      for (int i = 0; i < sessions.length; i++) {
        expect(
            sessions[i].drinks, drinks.getRange(i * 5, (i + 1) * 5).toList());
      }
    });
  });

  group('insertSession', () {
    Session _session;

    setUp(() {
      _session = _generator.getSession();
    });

    test('no rows are inserted in setup', () async {
      final List<Map<String, dynamic>> res = await _db.query(Session.tableName);
      expect(res, []);
    });

    test('inserts row into table', () async {
      await SessionRepo.insertSession(_session);

      final Session session = await SessionRepo.getSession(_session.id);
      expect(session, _session);
    });

    test('id is auto-incremented', () async {
      final Session session = _generator.getSession();
      session.id = null;
      final int id = await SessionRepo.insertSession(session);
      final Session insertedSession = await SessionRepo.getSession(null);

      expect(id == null, false);
      expect(insertedSession, null);
    });

    test('correct id is returned after insertion', () async {
      _session.id = 10;
      final int actual = await SessionRepo.insertSession(_session);
      final Session insertedSession = await SessionRepo.getSession(_session.id);
      final int expected = insertedSession.id;

      expect(actual, expected);
    });

    test('inserting on existing id replaces previous data', () async {
      await SessionRepo.insertSession(_session);
      _session.name = 'test';
      await SessionRepo.insertSession(_session);

      final Session session = await SessionRepo.getSession(_session.id);
      expect(session, _session);
    });
  });

  group('insertSessions', () {
    List<Session> _sessions;

    setUp(() {
      _sessions = <Session>[];

      for (int i = 0; i < 10; i++) {
        _sessions.add(_generator.getSession());
      }
    });

    test('no rows are inserted in setup', () async {
      final List<Map<String, dynamic>> res = await _db.query(Session.tableName);
      expect(res, []);
    });

    test('rows are inserted', () async {
      await SessionRepo.insertSessions(_sessions);

      final List<Session> sessions = await SessionRepo.getSessions();
      expect(sessions, _sessions);
    });

    test('inserts no row if empty list is given', () async {
      await SessionRepo.insertSessions([]);

      final List<Session> sessions = await SessionRepo.getSessions();
      expect(sessions, []);
    });

    test('correct ids are returned after inserting', () async {
      for (int i = 0; i < _sessions.length; i++) {
        _sessions[i].id = i + 10;
      }
      final List actual = await SessionRepo.insertSessions(_sessions);

      final List<Session> sessions = await SessionRepo.getSessions();
      final List expected = sessions.map((p) => p.id).toList();

      expect(actual, expected);
    });

    test('inserting on existing id replaces previous data', () async {
      final List<int> result = await SessionRepo.insertSessions(_sessions);

      for (int i = 0; i < result.length; i++) {
        _sessions[i].name = 'test';
      }
      await SessionRepo.insertSessions(_sessions);

      final List<Session> sessions = await SessionRepo.getSessions();
      for (int i = 0; i < _sessions.length; i++) {
        expect(_sessions[i], sessions[i]);
      }
    });

    test('inserting the same row multiple times returns correct result',
        () async {
      final List<Session> sessions = <Session>[];
      for (int i = 0; i < 10; i++) {
        final Session session = _sessions[0];
        session.id = 1;
        sessions.add(session);
      }
      final List<int> result = await SessionRepo.insertSessions(sessions);

      expect(result, [1, 1, 1, 1, 1, 1, 1, 1, 1, 1]);
    });
  });

  group('updateSession', () {
    Session _session;

    setUp(() async {
      _session = await _generator.insertSession();
    });

    test('row is inserted in setup', () async {
      final List<Map<String, dynamic>> res = await _db.query(Session.tableName);
      final Session session = res.map((p) => Session.fromMap(p)).single;

      expect(session, _session);
    });

    test('sessions are updated', () async {
      _session.name = 'test';
      await SessionRepo.updateSession(_session);

      final Session session = await SessionRepo.getSession(_session.id);
      expect(session, _session);
    });

    test('number of updated rows are correct', () async {
      _session.name = 'test';
      final int result = await SessionRepo.updateSession(_session);

      expect(result, 1);
    });

    test('no rows are updated if id is invalid', () async {
      _session.id = null;

      final int result = await SessionRepo.updateSession(_session);
      expect(result, 0);
    });

    test('updates existing row if insertMissing is true', () async {
      _session.name = 'test';
      await SessionRepo.updateSession(_session, insertMissing: true);

      final Session session = await SessionRepo.getSession(_session.id);
      expect(session, _session);
    });

    test('updating non-existing row inserts row if insertMissing is true',
        () async {
      final Session nonInserted = _generator.getSession();
      nonInserted.id = _session.id + 1;
      await SessionRepo.updateSession(nonInserted, insertMissing: true);

      final Session updated = await SessionRepo.getSession(nonInserted.id);
      expect(updated, nonInserted);
    });

    test('updating non-existing row does nothing if insertMissing is false',
        () async {
      final Session nonInserted = _generator.getSession();
      nonInserted.id = _session.id + 1;
      final int result = await SessionRepo.updateSession(nonInserted);

      final Session updated = await SessionRepo.getSession(nonInserted.id);
      expect(result, 0);
      expect(updated, null);
    });

    test('updates on the correct id', () async {
      final String initialName = _session.name;
      _session.id = _session.id + 1;
      await SessionRepo.insertSession(_session);
      _session.name = 'test';
      await SessionRepo.updateSession(_session);

      final List<Session> sessions = await SessionRepo.getSessions();
      expect(sessions[0].name, initialName);
      expect(sessions[1].name, _session.name);
    });
  });

  group('updateSessions', () {
    List<Session> _sessions;

    setUp(() async {
      _sessions = <Session>[];

      for (int i = 0; i < 10; i++) {
        _sessions.add(await _generator.insertSession());
      }
    });

    test('rows are inserted in setup', () async {
      final List<Map<String, dynamic>> res = await _db.query(Session.tableName);
      final List<Session> sessions =
          res.map((p) => Session.fromMap(p)).toList();

      expect(sessions, _sessions);
    });

    test('sessions are updated', () async {
      for (final Session session in _sessions) {
        session.name = 'test';
      }
      await SessionRepo.updateSessions(_sessions);
      final List<Session> sessions = await SessionRepo.getSessions();

      for (int i = 0; i < _sessions.length; i++) {
        expect(sessions[i], _sessions[i]);
      }
    });

    test('updates no rows if empty list is given', () async {
      await SessionRepo.updateSessions([]);

      final List<Session> sessions = await SessionRepo.getSessions();
      expect(sessions, _sessions);
    });

    test('updating returns correct number of rows affected', () async {
      final List<int> actual = await SessionRepo.updateSessions(_sessions);
      expect(actual.length, _sessions.length);
    });

    test('updating returns the ids of the affected rows', () async {
      final List<int> actual = await SessionRepo.updateSessions(_sessions);
      expect(actual, [1, 1, 1, 1, 1, 1, 1, 1, 1, 1]);
    });

    test('the correct row is updated', () async {
      final Session session = _sessions[3];
      session.name = 'updated';
      await SessionRepo.updateSessions(_sessions);
      final List<Session> sessions = await SessionRepo.getSessions();

      expect(sessions.length, _sessions.length);
      for (int i = 0; i < _sessions.length; i++) {
        expect(_sessions[i].name, sessions[i].name);
      }
    });

    test('updating non-existing row inserts row if insertMissing is true',
        () async {
      final Session nonInserted = _generator.getSession();
      _sessions.add(nonInserted);

      await SessionRepo.updateSessions(_sessions, insertMissing: true);

      final List<Session> sessions = await SessionRepo.getSessions();
      expect(sessions, _sessions);
    });

    test('updating non-existing row does nothing if insertMissing is false',
        () async {
      final Session nonInserted = _generator.getSession();
      final List<Session> nonUpdatedList = List.from(_sessions);
      nonUpdatedList.add(nonInserted);
      await SessionRepo.updateSessions(nonUpdatedList);

      final List<Session> sessions = await SessionRepo.getSessions();
      expect(sessions, _sessions);
    });

    test('updates rows in table if insertMissing is true', () async {
      for (Session session in _sessions) {
        session.name = 'updated';
      }
      await SessionRepo.updateSessions(_sessions, insertMissing: true);
      final List<Session> sessions = await SessionRepo.getSessions();

      for (int i = 0; i < _sessions.length; i++) {
        expect(sessions[i], _sessions[i]);
      }
    });

    test('removes non-existing rows if removeDeleted is true', () async {
      _sessions.removeAt(6);
      await SessionRepo.updateSessions(_sessions, removeDeleted: true);

      final List<Session> sessions = await SessionRepo.getSessions();
      expect(sessions, _sessions);
    });

    test('removes non-existing rows on profile id', () async {
      final Profile profile = _sessions[6].profile;
      _sessions.removeAt(6);
      List<Session> expected = List<Session>.from(_sessions).toList();
      _sessions.removeRange(1, 4);
      final List<Session> sessions = <Session>[];

      for (int i = 0; i < 5; i++) {
        sessions.add(_generator.getSession(profileId: profile.id));
      }
      await SessionRepo.insertSessions(sessions);
      await SessionRepo.updateSessions(_sessions,
          profileId: profile.id, removeDeleted: true);

      final List<Session> actual = await SessionRepo.getSessions();
      expect(actual, expected);
    });

    test('does not change non-existing rows if removeDeleted is false',
        () async {
      final List<Session> updatedSessions = <Session>[];
      for (int i = 0; i < _sessions.length; i++) {
        if (i != 6) updatedSessions.add(_sessions[i]);
      }
      await SessionRepo.updateSessions(_sessions, removeDeleted: false);

      final List<Session> sessions = await SessionRepo.getSessions();
      expect(sessions, _sessions);
    });

    test('updates rows in table when removeDeleted is true', () async {
      for (Session session in _sessions) {
        session.name = 'updated';
      }
      await SessionRepo.updateSessions(_sessions, removeDeleted: true);
      final List<Session> sessions = await SessionRepo.getSessions();

      for (int i = 0; i < _sessions.length; i++) {
        expect(sessions[i], _sessions[i]);
      }
    });

    test('updating both inserts and removes rows', () async {
      final Session nonInserted = _generator.getSession();
      nonInserted.id = _sessions.last.id + 1;
      _sessions.removeAt(6);
      _sessions.add(nonInserted);

      await SessionRepo.updateSessions(_sessions,
          insertMissing: true, removeDeleted: true);

      final List<Session> sessions = await SessionRepo.getSessions();
      expect(sessions, _sessions);
    });
  });

  group('deleteSession', () {
    Session _session;

    setUp(() async {
      _session = await _generator.insertSession();
    });

    test('row is inserted in setup', () async {
      final List<Map<String, dynamic>> res = await _db.query(Session.tableName);
      final Session session = res.map((p) => Session.fromMap(p)).single;

      expect(session, _session);
    });

    test('row is deleted', () async {
      await SessionRepo.deleteSession(_session);
      final List<Session> sessions = await SessionRepo.getSessions();
      expect(sessions, []);
    });

    test('deletes only given row', () async {
      final Session session = _generator.getSession();
      await SessionRepo.insertSession(session);
      await SessionRepo.deleteSession(_session);

      final List<Session> sessions = await SessionRepo.getSessions();
      expect(sessions, [session]);
    });

    test('returns number of rows affected', () async {
      _session.id = _session.id + 10;
      await SessionRepo.insertSession(_session);

      final int result = await SessionRepo.deleteSession(_session);
      expect(result, 1);
    });
  });

  group('deleteSessions', () {
    List<Session> _sessions;

    setUp(() async {
      _sessions = <Session>[];

      for (int i = 0; i < 10; i++) {
        _sessions.add(await _generator.insertSession());
      }
    });

    test('rows are inserted in setup', () async {
      final List<Map<String, dynamic>> res = await _db.query(Session.tableName);
      final List<Session> sessions =
          res.map((p) => Session.fromMap(p)).toList();

      expect(sessions, _sessions);
    });

    test('sessions are deleted', () async {
      await SessionRepo.deleteSessions();
      final List<Session> sessions = await SessionRepo.getSessions();
      expect(sessions, []);
    });

    test('sessions are deleted on profile id', () async {
      final Profile profile = _sessions[6].profile;
      _sessions.removeAt(6);
      List<Session> expected = List<Session>.from(_sessions).toList();
      _sessions.removeRange(1, 4);
      final List<Session> sessions = <Session>[];

      for (int i = 0; i < 5; i++) {
        sessions.add(_generator.getSession(profileId: profile.id));
      }
      await SessionRepo.insertSessions(sessions);
      await SessionRepo.deleteSessions(profileId: profile.id);

      final List<Session> actual = await SessionRepo.getSessions();
      expect(actual, expected);
    });

    test('returns number of rows affected', () async {
      final int actual = await SessionRepo.deleteSessions();
      expect(actual, _sessions.length);
    });

    test('deleting on empty table returns number of rows affected', () async {
      await TestUtils.clearDb(_db);
      final int actual = await SessionRepo.deleteSessions();

      expect(actual, 0);
    });
  });
}
