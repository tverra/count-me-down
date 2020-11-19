import 'package:count_me_down/database/database.dart';
import 'package:count_me_down/database/db_repo.dart';
import 'package:count_me_down/models/profile.dart';
import 'package:count_me_down/models/session.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_wrapper/sqflite_wrapper.dart';

class SessionRepo {
  static Future<Session> getSession(int id, {List<String> preloadArgs}) async {
    final Where where =
        Where(table: Session.tableName, col: Session.colId, val: id);

    final List<Session> sessions = await _getSessions(where, preloadArgs);
    return sessions.isEmpty ? null : sessions.single;
  }

  static Future<List<Session>> getSessions(
      {int profileId, List<String> preloadArgs}) async {
    final Where where = Where();

    if (profileId != null) {
      where.addEquals(Session.colProfileId, profileId,
          table: Session.tableName);
    }

    return _getSessions(where, preloadArgs);
  }

  static Future<List<Session>> _getSessions(
      Where where, List<String> preloadArgs,
      {List<String> columns, int limit}) async {
    final Database db = await _getDb();
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
        Map<String, dynamic> profileMap;

        if (preloadArgs.contains(Session.relProfile)) {
          profileMap =
              Preload.extractPreLoadedMap(Session.tableName, sessionMap);
        }
        if (preloadArgs.contains(Session.relDrinks)) {
          session.drinks = await DrinkRepo.getDrinks(sessionId: session.id);
        }

        session.profile =
            profileMap != null ? Profile.fromMap(profileMap) : null;
      }
      sessions.add(session);
    }
    return sessions;
  }

  static Future<int> insertSession(Session session) async {
    final Database db = await _getDb();

    final int id = await db.transaction((Transaction txn) async {
      final Batch batch = txn.batch();
      _insertSession(batch, session);
      return (await batch.commit())[0];
    });

    session.id = id;
    return session.id;
  }

  static void _insertSession(Batch batch, Session session) {
    final Insert insert = Insert(
        Session.tableName, session.toMap(forQuery: true),
        conflictAlgorithm: ConflictAlgorithm.replace);
    batch.rawInsert(insert.sql, insert.args);
  }

  static Future<List<int>> insertSessions(List<Session> sessions) async {
    final Database db = await _getDb();

    await db.transaction((Transaction txn) async {
      final Batch batch = txn.batch();

      for (Session session in sessions) {
        _insertSession(batch, session);
      }
      return batch.commit();
    });

    return sessions.map((s) => s.id).toList();
  }

  static Future<int> updateSession(Session session,
      {bool insertMissing = false}) async {
    final Database db = await _getDb();

    final List results = await db.transaction((Transaction txn) async {
      final Batch batch = txn.batch();
      _updateSessions(batch, [session], insertMissing, false);
      return batch.commit();
    });

    return results.isEmpty ? 0 : results[0];
  }

  static Future<List> updateSessions(List<Session> sessions,
      {int sessionId,
      bool insertMissing = false,
      bool removeDeleted = false}) async {
    final Database db = await _getDb();

    return db.transaction((Transaction txn) async {
      final Batch batch = txn.batch();
      _updateSessions(batch, sessions, insertMissing, removeDeleted,
          profileId: sessionId);
      return batch.commit();
    });
  }

  static Batch _updateSessions(Batch batch, List<Session> sessions,
      bool insertMissing, bool removeDeleted,
      {int profileId}) {
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

        final Update update =
            Update(Session.tableName, sessionMap, where: where);
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

      TempTable tempTable;

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

  static Future<int> deleteSession(Session session) async {
    final Where where = Where(col: Session.colId, val: session.id);
    return _deleteSessions(where);
  }

  static Future<int> deleteSessions({int profileId}) async {
    final Where where = Where();

    if (profileId != null) {
      where.addEquals(Session.colProfileId, profileId);
    }
    return _deleteSessions(where);
  }

  static Future<int> _deleteSessions(Where where) async {
    final Database db = await _getDb();
    final Delete delete = Delete(Session.tableName, where: where);
    return db.rawDelete(delete.sql, delete.args);
  }

  static Future<Database> _getDb() async {
    return DBProvider.db.getDatabase();
  }
}
