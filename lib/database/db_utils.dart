import 'package:count_me_down/database/indexed_database.dart';
import 'package:count_me_down/database/sqf_database.dart';
import 'package:count_me_down/models/drink.dart';
import 'package:count_me_down/models/preferences.dart';
import 'package:count_me_down/models/profile.dart';
import 'package:count_me_down/models/session.dart';
import 'package:flutter/foundation.dart';
import 'package:idb_sqflite/idb_sqflite.dart' as idb;
import 'package:sqflite/sqflite.dart' as sqf;

bool get useSqfLiteDb {
  return !kIsWeb;
}

int? getResult(Object? res) {
  final Object? resId = res;

  if (resId == null) {
    return null;
  } else if (resId is! int) {
    return null;
  } else {
    return resId;
  }
}

int? getSingleResult(List<Object?> res) {
  final Object? resId = res.isNotEmpty ? res[0] : null;

  if (resId == null) {
    return null;
  } else if (resId is! int) {
    return null;
  } else {
    return resId;
  }
}

Future<sqf.Database> getSqfDb() async {
  return SqfDbProvider.db.getDatabase();
}

Future<idb.Database> getIdb() async {
  return IdbProvider.db.getDatabase();
}

Map<String, dynamic>? castIdbResult(Object? res) {
  if (res == null) return null;

  final Map<dynamic, dynamic> map = res as Map<dynamic, dynamic>;

  return Map<String, dynamic>.from(
    map.map(
      (dynamic key, dynamic value) {
        return MapEntry<String, dynamic>(key.toString(), value);
      },
    ),
  );
}

List<Map<String, dynamic>> castIdbResultList(Object res) {
  final List<Map<String, dynamic>> casted = <Map<String, dynamic>>[];

  for (final Object obj in res as List<Object>) {
    final Map<String, dynamic>? map = castIdbResult(obj);

    if (map != null) {
      casted.add(map);
    }
  }
  return casted;
}

Future<List<Map<String, dynamic>>> queryFromIdb(
  String table, {
  idb.Database? db,
}) async {
  final idb.Database database = db ?? await getIdb();
  final idb.Transaction txn = database.transaction(table, idb.idbModeReadOnly);
  final idb.ObjectStore store = txn.objectStore(table);
  final List<Object> res = await store.getAll();
  await txn.completed;

  return castIdbResultList(res);
}

Future<Object?> insertIntoIdb(
  String table,
  Map<String, dynamic> data, {
  Object? key,
  idb.Database? db,
  bool updateExisting = true,
}) async {
  final idb.Database database = db ?? await getIdb();
  final idb.Transaction txn = database.transaction(table, idb.idbModeReadWrite);
  final idb.ObjectStore store = txn.objectStore(table);
  Object? res;

  if (updateExisting) {
    res = await store.put(data, key);
  } else {
    try {
      res = await store.add(data, key);
    } catch (error) {
      // ignore
    }
  }

  await txn.completed;

  return res;
}

Future<int> deleteFromIdb(String table, {Object? id, idb.Database? db}) async {
  final idb.Database database = db ?? await getIdb();
  final idb.Transaction txn = database.transaction(table, idb.idbModeReadWrite);
  final idb.ObjectStore store = txn.objectStore(table);
  final List<Object> keys = await store.getAllKeys();
  int res = 0;

  for (final Object key in keys) {
    if (id != null && id != key) {
      continue;
    }

    await store.delete(key);
    res++;
  }
  await txn.completed;

  return res;
}

Future<List<Map<String, dynamic>>> queryFrom(String table) async {
  if (useSqfLiteDb) {
    final sqf.Database db = await getSqfDb();
    return db.query(table);
  } else {
    return queryFromIdb(table);
  }
}

Future<Object?> insertInto(
  String table,
  Map<String, dynamic> data, [
  Object? key,
]) async {
  if (useSqfLiteDb) {
    final sqf.Database db = await getSqfDb();
    return db.insert(table, data);
  } else {
    return insertIntoIdb(table, data, key: key);
  }
}

Future<int> deleteFrom(String table, [Object? id]) async {
  if (useSqfLiteDb) {
    final sqf.Database db = await getSqfDb();
    return db.delete(table, where: id != null ? 'id = $id' : null);
  } else {
    return deleteFromIdb(table, id: id);
  }
}

Future<void> clearIdb([idb.Database? db]) async {
  await deleteFromIdb(Profile.tableName, db: db);
  await deleteFromIdb(Session.tableName, db: db);
  await deleteFromIdb(Drink.tableName, db: db);
  await deleteFromIdb(Preferences.tableName, db: db);
}

Future<void> clearDatabase() async {
  await deleteFrom(Profile.tableName);
  await deleteFrom(Session.tableName);
  await deleteFrom(Drink.tableName);
  await deleteFrom(Preferences.tableName);
}
