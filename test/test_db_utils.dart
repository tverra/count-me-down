import 'package:count_me_down/database/db_utils.dart';
import 'package:count_me_down/models/drink.dart';
import 'package:count_me_down/models/preferences.dart';
import 'package:count_me_down/models/profile.dart';
import 'package:count_me_down/models/session.dart';
import 'package:idb_sqflite/idb_sqflite.dart' as idb;
import 'package:sqflite/sqflite.dart' as sqf;

Future<int> getLatestId(String table, {String column = 'id'}) async {
  int id;

  if (useSqfLiteDb) {
    final sqf.Database db = await getSqfDb();
    final List<Map<String, dynamic>> res = await db.query(
      table,
      columns: <String>[column],
      orderBy: '$column DESC',
      limit: 1,
    );

    id = res.isNotEmpty ? (res[0][column] as int) : 0;
  } else {
    final idb.Database db = await getIdb();
    final idb.Transaction txn = db.transaction(table, idb.idbModeReadOnly);
    final idb.ObjectStore store = txn.objectStore(table);
    final List<Object> res = await store.getAllKeys();
    await txn.completed;

    id = res.isNotEmpty ? (res.last as int) : 0;
  }

  return id;
}

Future<List<Drink>> getDrinks() async {
  List<Drink>? drinks;

  if (useSqfLiteDb) {
    final sqf.Database db = await getSqfDb();
    final List<Map<String, dynamic>> res = await db.query(Drink.tableName);
    drinks = Drink.fromMapList(res);
  } else {
    final idb.Database db = await getIdb();
    final idb.Transaction txn =
        db.transaction(Drink.tableName, idb.idbModeReadOnly);
    final idb.ObjectStore store = txn.objectStore(Drink.tableName);
    final List<Object> res = await store.getAll();
    drinks = Drink.fromMapList(castIdbResultList(res));
  }

  return drinks ?? <Drink>[];
}

Future<int> insertDrink(Drink drink) async {
  int res;

  if (useSqfLiteDb) {
    final sqf.Database db = await getSqfDb();
    res = await db.insert(Drink.tableName, drink.toMap(forQuery: true));
  } else {
    final idb.Database db = await getIdb();
    final idb.Transaction txn =
        db.transaction(Drink.tableName, idb.idbModeReadWrite);
    final idb.ObjectStore store = txn.objectStore(Drink.tableName);
    res = await store.put(drink.toMap(forQuery: true), drink.id) as int;

    if (drink.id == null) {
      drink.id = res;

      await store.put(
        drink.toMap(forQuery: true),
        res,
      );
    }

    await txn.completed;
  }

  return res;
}

Future<int> deleteDrinks() async {
  int res = 0;

  if (useSqfLiteDb) {
    final sqf.Database db = await getSqfDb();
    res = await db.delete(Drink.tableName);
  } else {
    final idb.Database db = await getIdb();
    final idb.Transaction txn =
        db.transaction(Drink.tableName, idb.idbModeReadWrite);
    final idb.ObjectStore store = txn.objectStore(Drink.tableName);
    final List<Object> keys = await store.getAllKeys();

    for (final Object key in keys) {
      await store.delete(key);
      res++;
    }

    await txn.completed;
  }

  return res;
}

Future<List<Profile>> getProfiles() async {
  List<Profile>? profiles;

  if (useSqfLiteDb) {
    final sqf.Database db = await getSqfDb();
    final List<Map<String, dynamic>> res = await db.query(Profile.tableName);
    profiles = Profile.fromMapList(res);
  } else {
    final idb.Database db = await getIdb();
    final idb.Transaction txn =
        db.transaction(Profile.tableName, idb.idbModeReadOnly);
    final idb.ObjectStore store = txn.objectStore(Profile.tableName);
    final List<Object> res = await store.getAll();
    profiles = Profile.fromMapList(castIdbResultList(res));
  }

  return profiles ?? <Profile>[];
}

Future<int> insertProfile(Profile profile) async {
  int res;

  if (useSqfLiteDb) {
    final sqf.Database db = await getSqfDb();
    res = await db.insert(Profile.tableName, profile.toMap(forQuery: true));
  } else {
    final idb.Database db = await getIdb();
    final idb.Transaction txn =
        db.transaction(Profile.tableName, idb.idbModeReadWrite);
    final idb.ObjectStore store = txn.objectStore(Profile.tableName);
    res = await store.put(profile.toMap(forQuery: true), profile.id) as int;

    if (profile.id == null) {
      profile.id = res;

      await store.put(
        profile.toMap(forQuery: true),
        res,
      );
    }
    await txn.completed;
  }

  return res;
}

Future<int> deleteProfiles() async {
  int res = 0;

  if (useSqfLiteDb) {
    final sqf.Database db = await getSqfDb();
    res = await db.delete(Profile.tableName);
  } else {
    final idb.Database db = await getIdb();
    final idb.Transaction txn =
        db.transaction(Profile.tableName, idb.idbModeReadWrite);
    final idb.ObjectStore store = txn.objectStore(Profile.tableName);
    final List<Object> keys = await store.getAllKeys();

    for (final Object key in keys) {
      await store.delete(key);
      res++;
    }

    await txn.completed;
  }

  return res;
}

Future<List<Session>> getSessions() async {
  List<Session>? sessions;

  if (useSqfLiteDb) {
    final sqf.Database db = await getSqfDb();
    final List<Map<String, dynamic>> res = await db.query(Session.tableName);
    sessions = Session.fromMapList(res);
  } else {
    final idb.Database db = await getIdb();
    final idb.Transaction txn =
        db.transaction(Session.tableName, idb.idbModeReadOnly);
    final idb.ObjectStore store = txn.objectStore(Session.tableName);
    final List<Object> res = await store.getAll();
    sessions = Session.fromMapList(castIdbResultList(res));
  }

  return sessions ?? <Session>[];
}

Future<int> insertSession(Session session) async {
  int res;

  if (useSqfLiteDb) {
    final sqf.Database db = await getSqfDb();
    res = await db.insert(Session.tableName, session.toMap(forQuery: true));
  } else {
    final idb.Database db = await getIdb();
    final idb.Transaction txn =
        db.transaction(Session.tableName, idb.idbModeReadWrite);
    final idb.ObjectStore store = txn.objectStore(Session.tableName);
    res = await store.put(session.toMap(forQuery: true), session.id) as int;

    if (session.id == null) {
      session.id = res;

      await store.put(
        session.toMap(forQuery: true),
        res,
      );
    }
    await txn.completed;
  }

  return res;
}

Future<int> deleteSessions() async {
  int res = 0;

  if (useSqfLiteDb) {
    final sqf.Database db = await getSqfDb();
    res = await db.delete(Session.tableName);
  } else {
    final idb.Database db = await getIdb();
    final idb.Transaction txn =
        db.transaction(Session.tableName, idb.idbModeReadWrite);
    final idb.ObjectStore store = txn.objectStore(Session.tableName);
    final List<Object> keys = await store.getAllKeys();

    for (final Object key in keys) {
      await store.delete(key);
      res++;
    }

    await txn.completed;
  }

  return res;
}

Future<List<Preferences>> getPreferences() async {
  List<Preferences>? preferences;

  if (useSqfLiteDb) {
    final sqf.Database db = await getSqfDb();
    final List<Map<String, dynamic>> res =
        await db.query(Preferences.tableName);
    preferences = Preferences.fromMapList(res);
  } else {
    final idb.Database db = await getIdb();
    final idb.Transaction txn =
        db.transaction(Preferences.tableName, idb.idbModeReadOnly);
    final idb.ObjectStore store = txn.objectStore(Preferences.tableName);
    final List<Object> res = await store.getAll();

    preferences = Preferences.fromMapList(castIdbResultList(res));
  }

  return preferences ?? <Preferences>[];
}

Future<int> insertPreferences(Preferences preferences) async {
  int res;

  if (useSqfLiteDb) {
    final sqf.Database db = await getSqfDb();
    res = await db.insert(
      Preferences.tableName,
      preferences.toMap(forQuery: true),
    );
  } else {
    final idb.Database db = await getIdb();
    final idb.Transaction txn =
        db.transaction(Preferences.tableName, idb.idbModeReadWrite);
    final idb.ObjectStore store = txn.objectStore(Preferences.tableName);
    res = await store.put(preferences.toMap(forQuery: true), preferences.id)
        as int;

    if (preferences.id == null) {
      preferences.id = res;

      await store.put(
        preferences.toMap(forQuery: true),
        res,
      );
    }

    await txn.completed;
  }

  return res;
}

Future<int> deletePreferences() async {
  int res = 0;

  if (useSqfLiteDb) {
    final sqf.Database db = await getSqfDb();
    res = await db.delete(Preferences.tableName);
  } else {
    final idb.Database db = await getIdb();
    final idb.Transaction txn =
        db.transaction(Preferences.tableName, idb.idbModeReadWrite);
    final idb.ObjectStore store = txn.objectStore(Preferences.tableName);
    final List<Object> keys = await store.getAllKeys();

    for (final Object key in keys) {
      await store.delete(key);
      res++;
    }

    await txn.completed;
  }

  return res;
}
