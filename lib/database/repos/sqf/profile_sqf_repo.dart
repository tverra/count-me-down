import 'package:count_me_down/database/db_utils.dart';
import 'package:count_me_down/database/repos/sqf/session_sqf_repo.dart';
import 'package:count_me_down/models/profile.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_wrapper/sqflite_wrapper.dart';

Future<Profile?> getLatestProfile({List<String>? preloadArgs}) async {
  final Database db = await getSqfDb();

  final Query query = Query(
    Profile.tableName,
    orderBy: OrderBy(
      table: Profile.tableName,
      col: Profile.colId,
      orderType: OrderType.desc,
    ),
    limit: 1,
  );

  final List<Map<String, dynamic>> res =
      await db.rawQuery(query.sql, query.args);

  if (res.isEmpty) return null;

  final Profile profile = Profile.fromMap(res.single);

  if (preloadArgs != null) {
    if (preloadArgs.contains(Profile.relSessions)) {
      profile.sessions = await getSessions(profileId: profile.id);
    }
  }

  return profile;
}

Future<Profile?> getProfile(int id, {List<String>? preloadArgs}) async {
  final Where where =
      Where(table: Profile.tableName, col: Profile.colId, val: id);

  final List<Profile> profiles = await _getProfiles(where, preloadArgs);
  return profiles.isEmpty ? null : profiles.single;
}

Future<List<Profile>> getProfiles({List<String>? preloadArgs}) async {
  return _getProfiles(Where(), preloadArgs);
}

Future<List<Profile>> _getProfiles(Where where, List<String>? preloadArgs,
    {List<String>? columns, int? limit}) async {
  final Database db = await getSqfDb();
  final Preload preload = Preload();

  final Query query = Query(
    Profile.tableName,
    columns: columns,
    where: where,
    preload: preload,
    limit: limit,
  );
  final List<Map<String, dynamic>> res =
      await db.rawQuery(query.sql, query.args);

  final List<Profile> profiles = <Profile>[];
  for (Map<String, dynamic> profileMap in res) {
    final Profile profile = Profile.fromMap(profileMap);

    if (preloadArgs != null) {
      if (preloadArgs.contains(Profile.relSessions)) {
        profile.sessions = await getSessions(profileId: profile.id);
      }
    }
    profiles.add(profile);
  }
  return profiles;
}

Future<Profile> insertProfile(Profile profile) async {
  final Database db = await getSqfDb();

  final int id = await db.transaction((Transaction txn) async {
    final Batch batch = txn.batch();
    _insertProfile(batch, profile);
    return (await batch.commit())[0] as int;
  });

  profile.id = id;
  return profile;
}

void _insertProfile(Batch batch, Profile profile) {
  final Insert insert = Insert(Profile.tableName, profile.toMap(forQuery: true),
      conflictAlgorithm: ConflictAlgorithm.replace);
  batch.rawInsert(insert.sql, insert.args);
}

Future<List<Profile>> insertProfiles(List<Profile> profiles) async {
  final Database db = await getSqfDb();

  final List result = await db.transaction((Transaction txn) async {
    final Batch batch = txn.batch();

    for (Profile profile in profiles) {
      _insertProfile(batch, profile);
    }
    return batch.commit();
  });

  for (int i = 0; i < profiles.length; i++) {
    profiles[i].id = result[i];
  }
  return profiles;
}

Future<Profile?> updateProfile(Profile profile,
    {bool insertMissing = false}) async {
  final Database db = await getSqfDb();

  final List results = await db.transaction((Transaction txn) async {
    final Batch batch = txn.batch();
    _updateProfiles(batch, [profile], insertMissing, false);
    return batch.commit();
  });

  return results[0] == null ? null : profile;
}

Future<List<Profile>> updateProfiles(List<Profile> profiles,
    {bool insertMissing = false, bool removeDeleted = false}) async {
  final Database db = await getSqfDb();

  final List result = await db.transaction((Transaction txn) async {
    final Batch batch = txn.batch();
    _updateProfiles(batch, profiles, insertMissing, removeDeleted);
    return batch.commit();
  });

  final List<int> resultList = result.toList().cast<int>();

  for (int i = 0; i < profiles.length; i++) {
    if (profiles[i].id == null) {
      profiles[i].id = resultList[i];
    }
  }

  return profiles;
}

Batch _updateProfiles(Batch batch, List<Profile> profiles, bool insertMissing,
    bool removeDeleted) {
  for (Profile profile in profiles) {
    final Map<String, dynamic> profileMap = profile.toMap(forQuery: true);

    if (insertMissing) {
      final Insert upsert = Insert(
        Profile.tableName,
        profileMap,
        upsertConflictValues: [Profile.colId],
        upsertAction: Update.forUpsert(profileMap),
      );
      batch.rawInsert(upsert.sql, upsert.args);
    } else {
      final Where where = Where(col: Profile.colId, val: profile.id);

      final Update update = Update(Profile.tableName, profileMap, where: where);
      batch.rawUpdate(update.sql, update.args);
    }
  }

  if (removeDeleted) {
    final Where where = Where();

    final Query subQuery = Query(Profile.tableName, columns: [Profile.colId]);
    where.addSubQuery(Profile.colId, subQuery, table: Profile.tableName);

    TempTable? tempTable;

    if (profiles.length > 0) {
      final List updatedIds = profiles.map((p) => p.id).toList();
      tempTable = TempTable(Profile.tableName);
      batch.execute(tempTable.createTableSql);
      tempTable.insertValues(batch, updatedIds);

      where.addSubQuery(Profile.colId, tempTable.query,
          table: Profile.tableName, not: true);
    }

    final Delete delete = Delete(Profile.tableName, where: where);
    batch.rawDelete(delete.sql, delete.args);

    if (tempTable != null) batch.execute(tempTable.dropTableSql);
  }
  return batch;
}

Future<int> deleteProfile(Profile profile) async {
  final Where where = Where(col: Profile.colId, val: profile.id);
  return _deleteProfiles(where);
}

Future<int> deleteProfiles() async {
  final Where where = Where();

  return _deleteProfiles(where);
}

Future<int> _deleteProfiles(Where where) async {
  final Database db = await getSqfDb();
  final Delete delete = Delete(Profile.tableName, where: where);
  return db.rawDelete(delete.sql, delete.args);
}
