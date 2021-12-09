import 'package:count_me_down/database/database.dart';
import 'package:count_me_down/database/db_repo.dart';
import 'package:count_me_down/models/profile.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_wrapper/sqflite_wrapper.dart';

class ProfileRepo {
  static Future<Profile> getLatestProfile({List<String> preloadArgs}) async {
    final Database db = await _getDb();

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
        profile.sessions = await SessionRepo.getSessions(profileId: profile.id);
      }
    }

    return profile;
  }

  static Future<Profile> getProfile(int id, {List<String> preloadArgs}) async {
    final Where where =
        Where(table: Profile.tableName, col: Profile.colId, val: id);

    final List<Profile> profiles = await _getProfiles(where, preloadArgs);
    return profiles.isEmpty ? null : profiles.single;
  }

  static Future<List<Profile>> getProfiles({List<String> preloadArgs}) async {
    return _getProfiles(Where(), preloadArgs);
  }

  static Future<List<Profile>> _getProfiles(
      Where where, List<String> preloadArgs,
      {List<String> columns, int limit}) async {
    final Database db = await _getDb();
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
          profile.sessions =
              await SessionRepo.getSessions(profileId: profile.id);
        }
      }
      profiles.add(profile);
    }
    return profiles;
  }

  static Future<Database> _getDb() async {
    return DBProvider.db.getDatabase();
  }

  static Future<int> updateProfile(Profile profile,
      {bool insertMissing = false}) async {
    final Database db = await _getDb();

    final List results = await db.transaction((Transaction txn) async {
      final Batch batch = txn.batch();
      _updateProfiles(batch, [profile], insertMissing, false);
      return batch.commit();
    });

    return results.isEmpty ? 0 : results[0];
  }

  static Future<List<int>> updateProfiles(List<Profile> profiles,
      {bool insertMissing = false, bool removeDeleted = false}) async {
    final Database db = await _getDb();

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

    return resultList;
  }

  static Batch _updateProfiles(Batch batch, List<Profile> profiles,
      bool insertMissing, bool removeDeleted) {
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

        final Update update =
        Update(Profile.tableName, profileMap, where: where);
        batch.rawUpdate(update.sql, update.args);
      }
    }

    if (removeDeleted) {
      final Where where = Where();

      final Query subQuery = Query(Profile.tableName, columns: [Profile.colId]);
      where.addSubQuery(Profile.colId, subQuery, table: Profile.tableName);

      TempTable tempTable;

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
}
