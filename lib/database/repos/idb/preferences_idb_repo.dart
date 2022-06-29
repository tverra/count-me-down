import 'package:count_me_down/database/db_utils.dart';
import 'package:count_me_down/database/repos/idb/profile_idb_repo.dart';
import 'package:count_me_down/database/repos/idb/session_idb_repo.dart';
import 'package:count_me_down/models/preferences.dart';
import 'package:count_me_down/models/profile.dart';
import 'package:count_me_down/models/session.dart';
import 'package:idb_sqflite/idb_sqflite.dart';

Future<Preferences> getPreferences({List<String>? preloadArgs}) async {
  final Database db = await getIdb();
  final Transaction txn =
      db.transaction(Preferences.tableName, idbModeReadOnly);
  final ObjectStore store = txn.objectStore(Preferences.tableName);

  final Object res = await store.getAll();
  await txn.completed;

  final List<Map<String, dynamic>> casted = castIdbResultList(res);
  final Preferences? preferences =
      casted.isEmpty ? null : Preferences.fromMap(casted.last);
  Session? activeSession;
  Profile? activeProfile;

  if (preferences != null && preloadArgs != null) {
    if (preloadArgs.contains(Preferences.relActiveSession)) {
      final int? activeSessionId = preferences.activeSessionId;
      if (activeSessionId != null) {
        activeSession = await getSession(activeSessionId);
      }
    }
    if (preloadArgs.contains(Preferences.relActiveProfile)) {
      final int? activeProfileId = preferences.activeProfileId;
      if (activeProfileId != null) {
        activeProfile = await getProfile(activeProfileId);
      }
    }
  }

  preferences?.activeSession = activeSession;
  preferences?.activeProfile = activeProfile;

  return preferences ?? Preferences();
}

Future<Preferences> updatePreferences(Preferences preferences) async {
  final Database db = await getIdb();
  final Transaction txn =
      db.transaction(Preferences.tableName, idbModeReadWrite);
  final ObjectStore store = txn.objectStore(Preferences.tableName);

  final List<Object> keys = await store.getAllKeys();

  for (final Object key in keys) {
    await store.delete(key);
  }

  await store.put(
    preferences.toMap(forQuery: true),
    Preferences.tableName,
  );
  await txn.completed;

  return preferences;
}
