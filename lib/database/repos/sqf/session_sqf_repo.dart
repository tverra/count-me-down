import 'package:count_me_down/database/db_utils.dart';
import 'package:count_me_down/database/repos/sqf/drink_sqf_repo.dart';
import 'package:count_me_down/models/profile.dart';
import 'package:count_me_down/models/session.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_wrapper/sqflite_wrapper.dart';

Future<Session?> getSession(int id, {List<String>? preloadArgs}) async {
  final Where where =
      Where(table: Session.tableName, col: Session.colId, val: id);

  final List<Session> sessions = await _getSessions(where, preloadArgs);
  return sessions.isEmpty ? null : sessions.single;
}

Future<List<Session>> getSessions(
    {int? profileId, List<String>? preloadArgs}) async {
  final Where where = Where();

  if (profileId != null) {
    where.addEquals(Session.colProfileId, profileId, table: Session.tableName);
  }

  return _getSessions(where, preloadArgs);
}

Future<List<Session>> _getSessions(Where where, List<String>? preloadArgs,
    {List<String>? columns, int? limit}) async {
  final Database db = await getSqfDb();
  final Preload preload = Preload();

  if (preloadArgs != null) {
    if (preloadArgs.contains(Session.relProfile)) {
      preload.add(Profile.tableName, Profile.colId, Session.tableName,
          Session.colProfileId, Profile.columns);
    }
  }

  final Query query = Query(
    Session.tableName,
    columns: columns,
    where: where,
    preload: preload,
    limit: limit,
  );
  final List<Map<String, dynamic>> res =
      await db.rawQuery(query.sql, query.args);

  final List<Session> sessions = <Session>[];
  for (Map<String, dynamic> sessionMap in res) {
    final Session session = Session.fromMap(sessionMap);

    if (preloadArgs != null) {
      Map<String, dynamic>? profileMap;

      if (preloadArgs.contains(Session.relProfile)) {
        profileMap = Preload.extractPreLoadedMap(Profile.tableName, sessionMap);
      }
      if (preloadArgs.contains(Session.relDrinks)) {
        session.drinks = await getDrinks(sessionId: session.id);
      }

      session.profile = profileMap != null ? Profile.fromMap(profileMap) : null;
    }
    sessions.add(session);
  }
  return sessions;
}

Future<Session> insertSession(Session session) async {
  final Database db = await getSqfDb();

  final int id = await db.transaction((Transaction txn) async {
    final Batch batch = txn.batch();
    _insertSession(batch, session);
    return (await batch.commit())[0] as int;
  });

  session.id = id;
  return session;
}

void _insertSession(Batch batch, Session session) {
  final Insert insert = Insert(Session.tableName, session.toMap(forQuery: true),
      conflictAlgorithm: ConflictAlgorithm.replace);
  batch.rawInsert(insert.sql, insert.args);
}

Future<List<Session>> insertSessions(List<Session> sessions) async {
  final Database db = await getSqfDb();

  final List result = await db.transaction((Transaction txn) async {
    final Batch batch = txn.batch();

    for (Session session in sessions) {
      _insertSession(batch, session);
    }
    return batch.commit();
  });

  for (int i = 0; i < sessions.length; i++) {
    sessions[i].id = result[i];
  }
  return sessions;
}

Future<Session?> updateSession(Session session,
    {bool insertMissing = false}) async {
  final Database db = await getSqfDb();

  final List results = await db.transaction((Transaction txn) async {
    final Batch batch = txn.batch();
    _updateSessions(batch, [session], insertMissing, false);
    return batch.commit();
  });

  return results[0] == 0 ? null : session;
}

Future<List<Session>> updateSessions(List<Session> sessions,
    {int? profileId,
    bool insertMissing = false,
    bool removeDeleted = false}) async {
  final Database db = await getSqfDb();

  final List result = await db.transaction((Transaction txn) async {
    final Batch batch = txn.batch();
    _updateSessions(batch, sessions, insertMissing, removeDeleted,
        profileId: profileId);
    return batch.commit();
  });

  final List<int> resultList = result.toList().cast<int>();

  for (int i = 0; i < sessions.length; i++) {
    if (sessions[i].id == null) {
      sessions[i].id = resultList[i];
    }
  }

  return sessions;
}

Batch _updateSessions(
    Batch batch, List<Session> sessions, bool insertMissing, bool removeDeleted,
    {int? profileId}) {
  for (Session session in sessions) {
    final Map<String, dynamic> sessionMap = session.toMap(forQuery: true);

    if (insertMissing) {
      final Insert upsert = Insert(
        Session.tableName,
        sessionMap,
        upsertConflictValues: [Session.colId],
        upsertAction: Update.forUpsert(sessionMap),
      );
      batch.rawInsert(upsert.sql, upsert.args);
    } else {
      final Where where = Where(col: Session.colId, val: session.id);

      final Update update = Update(Session.tableName, sessionMap, where: where);
      batch.rawUpdate(update.sql, update.args);
    }
  }

  if (removeDeleted) {
    final Where where = Where();

    if (profileId != null) {
      where.addEquals(Session.colProfileId, profileId);
    }
    final Query subQuery = Query(Session.tableName, columns: [Session.colId]);
    where.addSubQuery(Session.colId, subQuery, table: Session.tableName);

    TempTable? tempTable;

    if (sessions.length > 0) {
      final List updatedIds = sessions.map((d) => d.id).toList();
      tempTable = TempTable(Session.tableName);
      batch.execute(tempTable.createTableSql);
      tempTable.insertValues(batch, updatedIds);

      where.addSubQuery(Session.colId, tempTable.query,
          table: Session.tableName, not: true);
    }

    final Delete delete = Delete(Session.tableName, where: where);
    batch.rawDelete(delete.sql, delete.args);

    if (tempTable != null) batch.execute(tempTable.dropTableSql);
  }
  return batch;
}

Future<int> deleteSession(Session session) async {
  final Where where = Where(col: Session.colId, val: session.id);
  return _deleteSessions(where);
}

Future<int> deleteSessions({int? profileId}) async {
  final Where where = Where();

  if (profileId != null) {
    where.addEquals(Session.colProfileId, profileId);
  }
  return _deleteSessions(where);
}

Future<int> _deleteSessions(Where where) async {
  final Database db = await getSqfDb();
  final Delete delete = Delete(Session.tableName, where: where);
  return db.rawDelete(delete.sql, delete.args);
}
