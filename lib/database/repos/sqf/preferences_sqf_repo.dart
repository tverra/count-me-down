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
      preload.add(Profile.tableName, Profile.colId, Preferences.tableName,
          Preferences.colActiveProfileId, Profile.columns);
    }
    if (preloadArgs.contains(Preferences.relActiveSession)) {
      preload.add(Session.tableName, Session.colId, Preferences.tableName,
          Preferences.colActiveSessionId, Session.columns);
    }
  }

  final Query query = Query(Preferences.tableName, where: where);
  final List<Map<String, dynamic>> res =
      await db.rawQuery(query.sql, query.args);

  final Map<String, dynamic> preferencesMap = res.single;
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

  final Where where = Where(col: Preferences.colId, val: preferences.id);

  final Update update =
      Update(Preferences.tableName, preferencesMap, where: where);
  final int result = await db.rawUpdate(update.sql, update.args);

  preferences.id = result;
  return preferences;
}
