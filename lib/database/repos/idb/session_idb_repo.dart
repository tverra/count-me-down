import 'package:count_me_down/database/db_utils.dart';
import 'package:count_me_down/database/repos/idb/drink_idb_repo.dart';
import 'package:count_me_down/database/repos/idb/profile_idb_repo.dart';
import 'package:count_me_down/models/drink.dart';
import 'package:count_me_down/models/profile.dart';
import 'package:count_me_down/models/session.dart';
import 'package:idb_sqflite/idb_sqflite.dart';

Future<Session?> getSession(int id, {List<String>? preloadArgs}) async {
  final Database db = await getIdb();
  final Transaction txn = db.transaction(Session.tableName, idbModeReadOnly);
  final ObjectStore store = txn.objectStore(Session.tableName);

  final Object? res = await store.getObject(id);
  await txn.completed;

  final Map<String, dynamic>? casted = castIdbResult(res);
  final Session? session = casted == null ? null : Session.fromMap(casted);
  Profile? profile;
  List<Drink>? drinks;

  if (session != null && preloadArgs != null) {
    if (preloadArgs.contains(Session.relProfile)) {
      final int? profileId = session.profileId;
      if (profileId != null) {
        profile = await getProfile(profileId);
      }
    }
    if (preloadArgs.contains(Session.relDrinks)) {
      drinks = await getDrinks(sessionId: session.id);
    }
  }

  session?.profile = profile;
  session?.drinks = drinks;
  return session;
}

Future<List<Session>> getSessions({
  int? profileId,
  List<String>? preloadArgs,
}) async {
  final Database db = await getIdb();
  final Transaction txn = db.transaction(Session.tableName, idbModeReadOnly);
  final ObjectStore store = txn.objectStore(Session.tableName);

  final List<Object> res = await store.getAll();
  await txn.completed;

  final List<Map<String, dynamic>> casted = castIdbResultList(res);
  final List<Session> sessions = <Session>[];

  for (final Map<String, dynamic> sessionMap in casted) {
    final Session session = Session.fromMap(sessionMap);
    Profile? profile;
    List<Drink>? drinks;

    if (profileId != null && session.profileId != profileId) {
      continue;
    }

    if (preloadArgs != null) {
      if (preloadArgs.contains(Session.relProfile)) {
        final int? profileId = session.profileId;
        if (profileId != null) {
          profile = await getProfile(profileId);
        }
      }
      if (preloadArgs.contains(Session.relDrinks)) {
        drinks = await getDrinks(sessionId: session.id);
      }
    }

    session.profile = profile;
    session.drinks = drinks;
    sessions.add(session);
  }

  return sessions;
}

Future<Session> insertSession(Session session) async {
  final Database db = await getIdb();
  final Transaction txn = db.transaction(Session.tableName, idbModeReadWrite);
  final ObjectStore store = txn.objectStore(Session.tableName);

  final Object key = await store.put(session.toMap(forQuery: true), session.id);

  if (session.id == null) {
    session.id = key as int;
    await store.put(session.toMap(forQuery: true), session.id);
  }

  await txn.completed;

  return session;
}

Future<List<Session>> insertSessions(List<Session> sessions) async {
  final Database db = await getIdb();
  final Transaction txn = db.transaction(Session.tableName, idbModeReadWrite);
  final ObjectStore store = txn.objectStore(Session.tableName);

  for (final Session session in sessions) {
    final Object key =
        await store.put(session.toMap(forQuery: true), session.id);

    if (session.id == null) {
      session.id = key as int;
      await store.put(session.toMap(forQuery: true), session.id);
    }
  }
  await txn.completed;

  return sessions;
}

Future<Session?> updateSession(
  Session session, {
  bool insertMissing = false,
}) async {
  final int? sessionId = session.id;

  if (sessionId != null && sessionId <= 0) return null;

  final Database db = await getIdb();
  final Transaction txn = db.transaction(Session.tableName, idbModeReadWrite);
  final ObjectStore store = txn.objectStore(Session.tableName);
  final Session res = session.copy();

  if (insertMissing) {
    final Object key =
        await store.put(session.toMap(forQuery: true), session.id);
    res.id = key as int;

    if (session.id == null) {
      await store.put(session.toMap(forQuery: true), key);
    }
  } else {
    if (session.id != null) {
      final List<Object> keys = await store.getAllKeys();

      if (keys.contains(session.id)) {
        final Object key =
            await store.put(session.toMap(forQuery: true), session.id);
        res.id = key as int;
      } else {
        return null;
      }
    }
  }
  await txn.completed;
  return res;
}

Future<List<Session>> updateSessions(
  List<Session> sessions, {
  int? profileId,
  bool insertMissing = false,
  bool removeDeleted = false,
}) async {
  final List<Session> existing = await getSessions(profileId: profileId);

  final Database db = await getIdb();
  final Transaction txn = db.transaction(Session.tableName, idbModeReadWrite);
  final ObjectStore store = txn.objectStore(Session.tableName);

  final List<Session> res = <Session>[];

  for (final Session session in sessions) {
    final Session copy = session.copy();

    if (insertMissing) {
      final Object key =
          await store.put(session.toMap(forQuery: true), session.id);
      copy.id = key as int;

      if (session.id == null) {
        await store.put(copy.toMap(forQuery: true), key);
      }

      res.add(copy);
    } else {
      if (session.id != null) {
        if (existing.where((Session c) => c.id == session.id).isNotEmpty) {
          final Object key =
              await store.put(session.toMap(forQuery: true), session.id);
          copy.id = key as int;
          res.add(copy);
        }
      }
    }
  }

  if (removeDeleted) {
    for (final Session session in existing) {
      final int? id = session.id;

      if (id != null && res.where((Session c) => c.id == session.id).isEmpty) {
        await store.delete(id);
      }
    }
  }

  await txn.completed;
  return res;
}

Future<int> deleteSession(Session session) async {
  final Database db = await getIdb();
  final Transaction txn = db.transaction(Session.tableName, idbModeReadWrite);
  final ObjectStore store = txn.objectStore(Session.tableName);

  final List<Object> keys = await store.getAllKeys();

  if (!keys.contains(session.id)) {
    return 0;
  }

  final int? sessionId = session.id;
  if (sessionId != null) await store.delete(sessionId);

  await txn.completed;
  return 1;
}

Future<int> deleteSessions({int? profileId}) async {
  final List<Session> existing = await getSessions(profileId: profileId);

  final Database db = await getIdb();
  final Transaction txn = db.transaction(Session.tableName, idbModeReadWrite);
  final ObjectStore store = txn.objectStore(Session.tableName);

  for (final Session session in existing) {
    final int? sessionId = session.id;
    if (sessionId != null) await store.delete(sessionId);
  }

  await txn.completed;
  return existing.length;
}
