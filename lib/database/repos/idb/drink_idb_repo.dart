import 'package:count_me_down/database/db_utils.dart';
import 'package:count_me_down/database/repos/idb/session_idb_repo.dart';
import 'package:count_me_down/models/drink.dart';
import 'package:count_me_down/models/session.dart';
import 'package:idb_sqflite/idb_sqflite.dart';

Future<Drink?> getDrink(int id, {List<String>? preloadArgs}) async {
  final Database db = await getIdb();
  final Transaction txn = db.transaction(Drink.tableName, idbModeReadOnly);
  final ObjectStore store = txn.objectStore(Drink.tableName);

  final Object? res = await store.getObject(id);
  await txn.completed;

  final Map<String, dynamic>? casted = castIdbResult(res);
  final Drink? drink = casted == null ? null : Drink.fromMap(casted);
  Session? session;

  if (drink != null) {
    if (preloadArgs != null) {
      if (preloadArgs.contains(Drink.relSession)) {
        final int? sessionId = drink.sessionId;
        if (sessionId != null) {
          session = await getSession(sessionId);
        }
      }
    }
  }

  drink?.session = session;
  return drink;
}

Future<List<Drink>> getDrinks({
  int? sessionId,
  List<String>? preloadArgs,
}) async {
  final Database db = await getIdb();
  final Transaction txn = db.transaction(Drink.tableName, idbModeReadOnly);
  final ObjectStore store = txn.objectStore(Drink.tableName);

  final List<Object> res = await store.getAll();
  await txn.completed;

  final List<Map<String, dynamic>> casted = castIdbResultList(res);
  final List<Drink> drinks = <Drink>[];

  for (final Map<String, dynamic> drinkMap in casted) {
    final Drink drink = Drink.fromMap(drinkMap);

    if (sessionId != null && drink.sessionId != sessionId) {
      continue;
    }

    Session? session;

    if (preloadArgs != null) {
      if (preloadArgs.contains(Drink.relSession)) {
        final int? sessionId = drink.sessionId;
        if (sessionId != null) {
          session = await getSession(sessionId);
        }
      }
    }

    drink.session = session;
    drinks.add(drink);
  }
  return drinks;
}

Future<List<Drink>> getDrinkTemplates({List<String>? preloadArgs}) async {
  final Database db = await getIdb();
  final Transaction txn = db.transaction(Drink.tableName, idbModeReadOnly);
  final ObjectStore store = txn.objectStore(Drink.tableName);

  final List<Object> res = await store.getAll();
  await txn.completed;

  final List<Map<String, dynamic>> casted = castIdbResultList(res);
  final List<Drink> drinks = <Drink>[];

  for (final Map<String, dynamic> drinkMap in casted) {
    final Drink drink = Drink.fromMap(drinkMap);

    if (drink.sessionId != null) {
      continue;
    }

    Session? session;

    if (preloadArgs != null) {
      if (preloadArgs.contains(Drink.relSession)) {
        final int? sessionId = drink.sessionId;
        if (sessionId != null) {
          session = await getSession(sessionId);
        }
      }
    }
    drink.session = session;
    drinks.add(drink);
  }
  return drinks;
}

Future<Drink> insertDrink(Drink drink) async {
  final Database db = await getIdb();
  final Transaction txn = db.transaction(Drink.tableName, idbModeReadWrite);
  final ObjectStore store = txn.objectStore(Drink.tableName);

  final Object key = await store.put(drink.toMap(forQuery: true), drink.id);

  if (drink.id == null) {
    drink.id = key as int;
    await store.put(drink.toMap(forQuery: true), drink.id);
  }

  await txn.completed;

  return drink;
}

Future<List<Drink>> insertDrinks(List<Drink> drinks) async {
  final Database db = await getIdb();
  final Transaction txn = db.transaction(Drink.tableName, idbModeReadWrite);
  final ObjectStore store = txn.objectStore(Drink.tableName);

  for (final Drink drink in drinks) {
    final Object key = await store.put(drink.toMap(forQuery: true), drink.id);

    if (drink.id == null) {
      drink.id = key as int;
      await store.put(drink.toMap(forQuery: true), drink.id);
    }
  }
  await txn.completed;

  return drinks;
}

Future<Drink?> updateDrink(Drink drink, {bool insertMissing = false}) async {
  final int? drinkId = drink.id;

  if (drinkId != null && drinkId <= 0) return null;

  final Database db = await getIdb();
  final Transaction txn = db.transaction(Drink.tableName, idbModeReadWrite);
  final ObjectStore store = txn.objectStore(Drink.tableName);
  final Drink res = drink.copy();

  if (insertMissing) {
    final Object key = await store.put(drink.toMap(forQuery: true), drink.id);
    res.id = key as int;

    if (drink.id == null) {
      await store.put(drink.toMap(forQuery: true), key);
    }
  } else {
    if (drink.id != null) {
      final List<Object> keys = await store.getAllKeys();

      if (keys.contains(drink.id)) {
        final Object key =
            await store.put(drink.toMap(forQuery: true), drink.id);
        res.id = key as int;
      } else {
        return null;
      }
    }
  }
  await txn.completed;
  return res;
}

Future<List<Drink>> updateDrinks(
  List<Drink> drinks, {
  int? sessionId,
  bool insertMissing = false,
  bool removeDeleted = false,
}) async {
  final List<Drink> existing = await getDrinks(sessionId: sessionId);

  final Database db = await getIdb();
  final Transaction txn = db.transaction(Drink.tableName, idbModeReadWrite);
  final ObjectStore store = txn.objectStore(Drink.tableName);

  final List<Drink> res = <Drink>[];

  for (final Drink drink in drinks) {
    final Drink copy = drink.copy();

    if (insertMissing) {
      final Object key = await store.put(drink.toMap(forQuery: true), drink.id);
      copy.id = key as int;

      if (drink.id == null) {
        await store.put(copy.toMap(forQuery: true), key);
      }

      res.add(copy);
    } else {
      if (drink.id != null) {
        if (existing.where((Drink c) => c.id == drink.id).isNotEmpty) {
          final Object key =
              await store.put(drink.toMap(forQuery: true), drink.id);
          copy.id = key as int;
          res.add(copy);
        }
      }
    }
  }

  if (removeDeleted) {
    for (final Drink drink in existing) {
      if (res.where((Drink c) => c.id == drink.id).isEmpty) {
        final int? id = drink.id;

        if (id != null && res.where((Drink d) => d.id == drink.id).isEmpty) {
          await store.delete(id);
        }
      }
    }
  }

  await txn.completed;
  return res;
}

Future<int> deleteDrink(Drink drink) async {
  final Database db = await getIdb();
  final Transaction txn = db.transaction(Drink.tableName, idbModeReadWrite);
  final ObjectStore store = txn.objectStore(Drink.tableName);

  final List<Object> keys = await store.getAllKeys();

  if (!keys.contains(drink.id)) {
    return 0;
  }

  final int? drinkId = drink.id;

  if (drinkId != null) await store.delete(drinkId);

  await txn.completed;
  return 1;
}

Future<int> deleteDrinks({int? sessionId}) async {
  final List<Drink> existing = await getDrinks(sessionId: sessionId);

  final Database db = await getIdb();
  final Transaction txn = db.transaction(Drink.tableName, idbModeReadWrite);
  final ObjectStore store = txn.objectStore(Drink.tableName);

  for (final Drink drink in existing) {
    final int? drinkId = drink.id;

    if (drinkId != null) await store.delete(drinkId);
  }

  await txn.completed;
  return existing.length;
}
