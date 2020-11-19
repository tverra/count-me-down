import 'package:count_me_down/database/database.dart';
import 'package:count_me_down/database/db_repo.dart';
import 'package:count_me_down/models/profile.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_wrapper/sqflite_wrapper.dart';

class ProfileRepo {
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
}
