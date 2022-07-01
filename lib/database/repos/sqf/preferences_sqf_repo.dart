import 'package:count_me_down/database/db_utils.dart';
import 'package:count_me_down/models/preferences.dart';
import 'package:count_me_down/models/profile.dart';
import 'package:count_me_down/models/session.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_wrapper/sqflite_wrapper.dart';

Future<Preferences> getPreferences({List<String>? preloadArgs}) async {
  final Database db = await getSqfDb();
  final Preload preload = Preload();
  final Where where =
      Where(table: Preferences.tableName, col: Preferences.colId, val: 1);

  if (preloadArgs != null) {
    if (preloadArgs.contains(Preferences.relActiveProfile)) {
      preload.add(
        Profile.tableName,
        Profile.colId,
        Preferences.tableName,
        Preferences.colActiveProfileId,
        Profile.columns,
      );
    }
    if (preloadArgs.contains(Preferences.relActiveSession)) {
      preload.add(
        Session.tableName,
        Session.colId,
        Preferences.tableName,
        Preferences.colActiveSessionId,
        Session.columns,
      );
    }
  }

  final Query query =
      Query(Preferences.tableName, where: where, preload: preload);
  final List<Map<String, dynamic>> res =
      await db.rawQuery(query.sql, query.args);

  final Map<String, dynamic>? preferencesMap =
      res.isNotEmpty ? res.single : null;

  if (preferencesMap == null) {
    return Preferences();
  }

  final Preferences preferences = Preferences.fromMap(preferencesMap);

  if (preloadArgs != null) {
    Map<String, dynamic>? sessionMap;
    Map<String, dynamic>? profileMap;

    if (preloadArgs.contains(Preferences.relActiveSession)) {
      sessionMap =
          Preload.extractPreLoadedMap(Session.tableName, preferencesMap);
    }
    if (preloadArgs.contains(Preferences.relActiveProfile)) {
      profileMap =
          Preload.extractPreLoadedMap(Profile.tableName, preferencesMap);
    }

    preferences.activeSession =
        sessionMap != null ? Session.fromMap(sessionMap) : null;
    preferences.activeProfile =
        profileMap != null ? Profile.fromMap(profileMap) : null;
  }

  return preferences;
}

Future<Preferences> updatePreferences(Preferences preferences) async {
  final Database db = await getSqfDb();
  final Map<String, dynamic> preferencesMap = preferences.toMap(forQuery: true);

  final Insert upsert = Insert(
    Preferences.tableName,
    preferencesMap,
    upsertConflictValues: <String>[Preferences.colId],
    upsertAction: Update.forUpsert(preferencesMap),
  );
  final int result = await db.rawUpdate(upsert.sql, upsert.args);

  final Delete delete = Delete(
    Preferences.tableName,
    where: Where(
      table: Preferences.tableName,
      col: Preferences.colId,
      val: 1,
      not: true,
    ),
  );

  await db.rawDelete(delete.sql, delete.args);

  preferences.id = result;
  return preferences;
}
