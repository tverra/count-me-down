import 'package:count_me_down/database/db_repos.dart';
import 'package:count_me_down/database/db_utils.dart';
import 'package:count_me_down/models/drink.dart';
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

  group('getSession', () {
    late Session _session;

    setUp(() async {
      _session = await generator.insertSession();
    });

    test('rows are inserted in setup', () async {
      final Session session = (await db_utils.getSessions()).single;

      expect(session, _session);
    });

    test('returns row on given id', () async {
      final Session session = (await getSession(_session.id!))!;
      expect(session, _session);
    });

    test('return null if no rows exists', () async {
      await test_utils.clearDb();

      final Session? session = await getSession(_session.id!);
      expect(session, null);
    });

    test('preloading drinks returns null if no sessions exists', () async {
      await test_utils.clearDb();

      final Session? session = await getSession(
        _session.id!,
        preloadArgs: <String>[Session.relDrinks],
      );
      expect(session, null);
    });

    test('returns null if id is invalid', () async {
      final Session? session = await getSession(-1);
      expect(session, null);
    });

    test('preloading profile includes profile', () async {
      final Session session = (await getSession(
        _session.id!,
        preloadArgs: <String>[Session.relProfile],
      ))!;

      expect(session.profile, _session.profile);
    });

    test('preloading non-existing profile returns null', () async {
      final Session session = await generator.insertSession(profileId: -1);

      final Session insertedSession = (await getSession(
        session.id!,
        preloadArgs: <String>[Session.relProfile],
      ))!;

      expect(insertedSession.profile, null);
    });

    test('invalid preload returns no preloads', () async {
      final Session session = (await getSession(
        _session.id!,
        preloadArgs: <String>['invalid'],
      ))!;

      expect(session.profile, null);
      expect(session.drinks, null);
    });

    test('preloading empty row returns null', () async {
      final Session? session = await getSession(
        _session.id! + 1,
        preloadArgs: <String>[Session.relProfile, Session.relDrinks],
      );
      expect(session, null);
    });

    test('drinks are null if not preloaded', () async {
      await generator.insertDrink();

      for (int i = 0; i < 5; i++) {
        await generator.insertDrink(sessionId: _session.id);
      }

      final Session session = (await getSession(_session.id!))!;
      expect(session.drinks, null);
    });

    test('preloading drinks returns list of drinks', () async {
      final List<Drink> drinks = <Drink>[];
      await generator.insertDrink();

      for (int i = 0; i < 5; i++) {
        drinks.add(await generator.insertDrink(sessionId: _session.id));
      }

      final Session session = (await getSession(
        _session.id!,
        preloadArgs: <String>[Session.relDrinks],
      ))!;

      expect(session.drinks, drinks);
    });

    test('preloading drinks returns empty list if no drinks', () async {
      final Session session = (await getSession(
        _session.id!,
        preloadArgs: <String>[Session.relDrinks],
      ))!;
      expect(session.drinks, <Drink>[]);
    });
  });

  group('getSessions', () {
    late List<Session> _sessions;

    setUp(() async {
      _sessions = <Session>[];

      for (int i = 0; i < 10; i++) {
        _sessions.add(await generator.insertSession());
      }
    });

    test('rows are inserted in setup', () async {
      final List<Session> sessions = await db_utils.getSessions();

      expect(sessions, _sessions);
    });

    test('returns all rows', () async {
      final List<Session> sessions = await getSessions();
      expect(sessions, _sessions);
    });

    test('returns all rows on profile id', () async {
      final List<Session> sessions = <Session>[];
      sessions.add(_sessions[2]);

      for (int i = 0; i < 3; i++) {
        final Session session =
            generator.getSession(profileId: _sessions[2].profileId);
        sessions.add(session);
      }
      await insertSessions(sessions);

      final List<Session> insertedSessions =
          await getSessions(profileId: _sessions[2].profileId);
      expect(insertedSessions, sessions);
    });

    test('returns empty list if no rows', () async {
      await test_utils.clearDb();

      final List<Session> sessions = await getSessions();
      expect(sessions, <Session>[]);
    });

    test('preloading children on empty row returns empty list', () async {
      await test_utils.clearDb();

      final List<Session> sessions = await getSessions(
        preloadArgs: <String>[Session.relDrinks],
      );

      expect(sessions, <Session>[]);
    });

    test('drinks are null if not preloaded', () async {
      final List<Session> sessions = await getSessions();

      for (int i = 0; i < sessions.length; i++) {
        expect(sessions[i].drinks, null);
      }
    });

    test('drinks are empty list if no drinks exists', () async {
      final List<Session> sessions =
          await getSessions(preloadArgs: <String>[Session.relDrinks]);

      for (int i = 0; i < sessions.length; i++) {
        expect(sessions[i].drinks, <Session>[]);
      }
    });

    test('preloading profile includes profile', () async {
      final List<Session> sessions =
          await getSessions(preloadArgs: <String>[Session.relProfile]);

      for (int i = 0; i < _sessions.length; i++) {
        expect(sessions[i].profile, _sessions[i].profile);
      }
    });

    test('preloading parent on profile id includes profile', () async {
      final List<Session> sessions = await getSessions(
        profileId: _sessions[4].profileId,
        preloadArgs: <String>[Session.relProfile],
      );

      expect(sessions[0].profile, _sessions[4].profile);
    });

    test('preloading non-existing parent returns null', () async {
      await test_utils.clearDb();
      final List<Session> sessions = <Session>[];

      for (int i = 0; i < 5; i++) {
        final Session session = generator.getSession();
        sessions.add(session);
      }
      await insertSessions(sessions);

      final List<Session> insertedSessions =
          await getSessions(preloadArgs: <String>[Session.relProfile]);

      for (final Session session in insertedSessions) {
        expect(session.profile, null);
      }
    });

    test('invalid preload returns no preloads', () async {
      final List<Session> sessions =
          await getSessions(preloadArgs: <String>['invalid']);

      for (final Session session in sessions) {
        expect(session.profile, null);
        expect(session.drinks, null);
      }
    });

    test('preloading parent on empty row returns empty list', () async {
      await test_utils.clearDb();

      final List<Session> sessions =
          await getSessions(preloadArgs: <String>[Session.relProfile]);

      for (final Session session in sessions) {
        expect(session, <Session>[]);
      }
    });

    test('preloading children on empty row returns empty list', () async {
      await test_utils.clearDb();

      final List<Session> sessions =
          await getSessions(preloadArgs: <String>[Session.relDrinks]);

      for (final Session session in sessions) {
        expect(session, <Session>[]);
      }
    });

    test('preloading drinks returns list of drinks', () async {
      final List<Drink> drinks = <Drink>[];
      await generator.insertDrink(sessionId: -1);

      for (final Session session in _sessions) {
        for (int i = 0; i < 5; i++) {
          drinks.add(await generator.insertDrink(sessionId: session.id));
        }
      }
      final List<Session> sessions =
          await getSessions(preloadArgs: <String>[Session.relDrinks]);

      for (int i = 0; i < sessions.length; i++) {
        expect(
          sessions[i].drinks,
          drinks.getRange(i * 5, (i + 1) * 5).toList(),
        );
      }
    });
  });

  group('insertSession', () {
    late Session _session;

    setUp(() async {
      _session = generator.getSession();
    });

    test('no rows are inserted in setup', () async {
      final List<Session> sessions = await db_utils.getSessions();
      expect(sessions.length, 0);
    });

    test('inserts row into table', () async {
      await insertSession(_session);

      final Session session = (await getSession(_session.id!))!;
      expect(session, _session);
    });

    test('id is auto-incremented', () async {
      final Session session = generator.getSession();
      session.id = null;
      final int? id = (await insertSession(session)).id;
      final List<Session> insertedSessions = await getSessions();
      expect(id == null, false);
      expect(insertedSessions.length, 1);
    });

    test('correct id is returned after insertion', () async {
      _session.id = 1000;
      final Session updated = await insertSession(_session);
      final Session inserted = (await getSession(_session.id!))!;

      expect(updated.id, 1000);
      expect(inserted.id, 1000);
    });

    test('inserting on existing id replaces previous data', () async {
      await insertSession(_session);
      _session.name = 'test';
      await insertSession(_session);

      final Session session = (await getSession(_session.id!))!;
      expect(session, _session);
    });
  });

  group('insertSessions', () {
    late List<Session> _sessions;

    setUp(() async {
      _sessions = <Session>[];

      for (int i = 0; i < 10; i++) {
        _sessions.add(generator.getSession());
      }
    });

    test('no rows are inserted in setup', () async {
      final List<Session> sessions = await db_utils.getSessions();
      expect(sessions.length, 0);
    });

    test('rows are inserted', () async {
      await insertSessions(_sessions);

      final List<Session> sessions = await getSessions();
      expect(sessions, _sessions);
    });

    test('inserts no row if empty list is given', () async {
      await insertSessions(<Session>[]);

      final List<Session> sessions = await getSessions();
      expect(sessions, <Session>[]);
    });

    test('correct ids are returned after inserting', () async {
      final List<int> expected = <int>[];

      for (int i = 0; i < _sessions.length; i++) {
        _sessions[i].id = 1000 + i;
        expected.add(1000 + i);
      }
      final List<Session> updated = await insertSessions(_sessions);

      final List<int> actual = updated.map((Session s) => s.id!).toList();

      expect(actual, expected);
    });

    test('inserting on existing id replaces previous data', () async {
      final List<Session> result = await insertSessions(_sessions);

      for (int i = 0; i < result.length; i++) {
        final Session copy = _sessions[i].copy();
        copy.name = 'test';
        _sessions[i] = copy;
      }
      await insertSessions(_sessions);

      final List<Session> sessions = await getSessions();
      for (int i = 0; i < _sessions.length; i++) {
        expect(_sessions[i], sessions[i]);
      }
    });

    test('inserting the same row multiple times returns correct result',
        () async {
      final List<Session> sessions = <Session>[];
      for (int i = 0; i < 10; i++) {
        final Session copy = _sessions[0].copy();
        copy.id = 1;
        sessions.add(copy);
      }
      final List<Session> result = await insertSessions(sessions);

      expect(result, sessions);
    });
  });

  group('updateSession', () {
    late Session _session;

    setUp(() async {
      _session = await generator.insertSession();
    });

    test('row is inserted in setup', () async {
      final Session session = (await db_utils.getSessions()).single;

      expect(session, _session);
    });

    test('sessions are updated', () async {
      _session.name = 'test';
      await updateSession(_session);

      final Session session = (await getSession(_session.id!))!;
      expect(session, _session);
    });

    test('returns the updated row', () async {
      _session.name = 'test';
      final Session? result = await updateSession(_session);

      expect(result, _session);
    });

    test('no rows are updated if id is invalid', () async {
      _session.id = -1;

      final Session? result = await updateSession(_session);

      expect(result, null);
    });

    test('updates existing row if insertMissing is true', () async {
      _session.name = 'test';
      await updateSession(_session, insertMissing: true);

      final Session? session = await getSession(_session.id!);
      expect(session, _session);
    });

    test('updating non-existing row inserts row if insertMissing is true',
        () async {
      final Session nonInserted = generator.getSession();
      final Session? updated =
          await updateSession(nonInserted, insertMissing: true);

      final Session? inserted = await getSession(updated!.id!);
      expect(inserted, nonInserted);
    });

    test('updating non-existing row does nothing if insertMissing is false',
        () async {
      final Session nonInserted = generator.getSession(id: 1000);
      final Session? result = await updateSession(nonInserted);

      final Session? updated = await getSession(1000);
      expect(result, null);
      expect(updated, null);
    });

    test('updates on the correct id', () async {
      final String initialName = _session.name!;
      _session.id = _session.id! + 1;
      _session.name = 'session_name_id${_session.id! + 1}';
      await insertSession(_session);

      _session.name = 'test';
      await updateSession(_session);

      final List<Session> sessions = await getSessions();

      expect(sessions[0].name, initialName);
      expect(sessions[1].name, _session.name);
    });
  });

  group('updateSessions', () {
    late List<Session> _sessions;

    setUp(() async {
      _sessions = <Session>[];

      for (int i = 0; i < 10; i++) {
        _sessions.add(await generator.insertSession());
      }
    });

    test('rows are inserted in setup', () async {
      final List<Session> sessions = await db_utils.getSessions();

      expect(sessions, _sessions);
    });

    test('sessions are updated', () async {
      final List<Session> toBeUpdated = <Session>[];

      for (final Session session in _sessions) {
        final Session copy = session.copy();
        copy.name = 'test';
        toBeUpdated.add(copy);
      }
      await updateSessions(toBeUpdated);
      final List<Session> sessions = await getSessions();

      for (int i = 0; i < _sessions.length; i++) {
        expect(sessions[i], toBeUpdated[i]);
      }
    });

    test('updates no rows if empty list is given', () async {
      await updateSessions(<Session>[]);

      final List<Session> sessions = await getSessions();
      expect(sessions, _sessions);
    });

    test('updating returns the affected rows', () async {
      final List<Session> result = await updateSessions(_sessions);
      expect(result, _sessions);
    });

    test('updating does not return unaffected rows', () async {
      _sessions[2].id = -1;
      final List<Session> result = await updateSessions(_sessions);

      final List<Session> expected = List<Session>.from(_sessions);
      expected.removeAt(2);

      expect(result, expected);
    });

    test('the correct row is updated', () async {
      _sessions[3].name = 'updated';
      await updateSessions(_sessions);
      final List<Session> sessions = await getSessions();

      expect(sessions.length, _sessions.length);
      for (int i = 0; i < _sessions.length; i++) {
        expect(_sessions[i].name, sessions[i].name);
      }
    });

    test('updating non-existing row inserts row if insertMissing is true',
        () async {
      final Session nonInserted = generator.getSession();
      _sessions.add(nonInserted);

      final List<Session> updated =
          await updateSessions(_sessions, insertMissing: true);

      _sessions.last.id = updated.last.id;

      final List<Session> sessions = await getSessions();
      expect(sessions, _sessions);
    });

    test('updating non-existing row does nothing if insertMissing is false',
        () async {
      final Session nonInserted = generator.getSession();
      final List<Session> nonUpdatedList = List<Session>.from(_sessions);
      nonUpdatedList.add(nonInserted);
      await updateSessions(nonUpdatedList);

      final List<Session> sessions = await getSessions();
      expect(sessions, _sessions);
    });

    test('updates rows in table if insertMissing is true', () async {
      final List<Session> toBeUpdated = <Session>[];

      for (final Session session in _sessions) {
        final Session copy = session.copy();
        copy.name = 'updated';
        toBeUpdated.add(copy);
      }
      await updateSessions(toBeUpdated, insertMissing: true);
      final List<Session> sessions = await getSessions();

      for (int i = 0; i < _sessions.length; i++) {
        expect(sessions[i], toBeUpdated[i]);
      }
    });

    test('removes non-existing rows if removeDeleted is true', () async {
      _sessions.removeAt(6);
      await updateSessions(_sessions, removeDeleted: true);

      final List<Session> sessions = await getSessions();
      expect(sessions, _sessions);
    });

    test('removes non-existing rows on profile id', () async {
      final Profile profile = _sessions[6].profile!;
      _sessions.removeAt(6);
      final List<Session> expected = List<Session>.from(_sessions).toList();
      _sessions.removeRange(1, 4);
      final List<Session> sessions = <Session>[];

      for (int i = 0; i < 5; i++) {
        sessions.add(generator.getSession(profileId: profile.id));
      }
      await insertSessions(sessions);
      await updateSessions(
        _sessions,
        profileId: profile.id,
        removeDeleted: true,
      );

      final List<Session> actual = await getSessions();
      expect(actual, expected);
    });

    test('does not change non-existing rows if removeDeleted is false',
        () async {
      final List<Session> updatedSessions = <Session>[];
      for (int i = 0; i < _sessions.length; i++) {
        if (i != 6) updatedSessions.add(_sessions[i]);
      }
      await updateSessions(_sessions, removeDeleted: false);

      final List<Session> sessions = await getSessions();
      expect(sessions, _sessions);
    });

    test('updates rows in table when removeDeleted is true', () async {
      final List<Session> toBeUpdated = <Session>[];

      for (final Session session in _sessions) {
        final Session copy = session.copy();
        copy.name = 'updated';
        toBeUpdated.add(copy);
      }
      await updateSessions(toBeUpdated, removeDeleted: true);
      final List<Session> sessions = await getSessions();

      for (int i = 0; i < _sessions.length; i++) {
        expect(sessions[i], toBeUpdated[i]);
      }
    });

    test('updating both inserts and removes rows', () async {
      final Session nonInserted = generator.getSession();
      _sessions.removeAt(6);
      _sessions.add(nonInserted);

      await updateSessions(_sessions, insertMissing: true, removeDeleted: true);

      final List<Session> sessions = await getSessions();
      expect(sessions, _sessions);
    });
  });

  group('deleteSession', () {
    late Session _session;

    setUp(() async {
      _session = await generator.insertSession();
    });

    test('row is inserted in setup', () async {
      final Session session = (await db_utils.getSessions()).single;

      expect(session, _session);
    });

    test('row is deleted', () async {
      await deleteSession(_session);
      final List<Session> sessions = await getSessions();
      expect(sessions, <Session>[]);
    });

    test('deletes only given row', () async {
      final Session session = generator.getSession();
      await insertSession(session);
      await deleteSession(_session);

      final List<Session> sessions = await getSessions();
      expect(sessions, <Session>[session]);
    });

    test('returns number of rows affected', () async {
      final int result = await deleteSession(_session);
      expect(result, 1);
    });

    test('returns zero if no rows are affected ', () async {
      final Session session = generator.getSession();

      final int result = await deleteSession(session);
      expect(result, 0);
    });
  });

  group('deleteSessions', () {
    late List<Session> _sessions;

    setUp(() async {
      _sessions = <Session>[];

      for (int i = 0; i < 10; i++) {
        _sessions.add(await generator.insertSession());
      }
    });

    test('rows are inserted in setup', () async {
      final List<Session> sessions = await db_utils.getSessions();

      expect(sessions, _sessions);
    });

    test('sessions are deleted', () async {
      await deleteSessions();
      final List<Session> sessions = await getSessions();
      expect(sessions, <Session>[]);
    });

    test('sessions are deleted on profile id', () async {
      final Profile profile = _sessions[6].profile!;
      _sessions.removeAt(6);
      final List<Session> expected = List<Session>.from(_sessions).toList();
      _sessions.removeRange(1, 4);
      final List<Session> sessions = <Session>[];

      for (int i = 0; i < 5; i++) {
        sessions.add(generator.getSession(profileId: profile.id));
      }
      await insertSessions(sessions);
      await deleteSessions(profileId: profile.id);

      final List<Session> actual = await getSessions();
      expect(actual, expected);
    });

    test('no sessions are deleted if profile id is invalid', () async {
      final int actual = await deleteSessions(profileId: 1000);

      expect(actual, 0);
    });

    test('returns number of rows affected', () async {
      final int actual = await deleteSessions();
      expect(actual, _sessions.length);
    });

    test('deleting on empty table returns number of rows affected', () async {
      await test_utils.clearDb();
      final int actual = await deleteSessions();

      expect(actual, 0);
    });
  });
}
