import 'package:count_me_down/database/db_utils.dart';
import 'package:count_me_down/models/drink.dart';
import 'package:count_me_down/models/session.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_wrapper/sqflite_wrapper.dart';

Future<Drink?> getDrink(int id, {List<String>? preloadArgs}) async {
  final Where where = Where(table: Drink.tableName, col: Drink.colId, val: id);

  final List<Drink> drinks = await _getDrinks(where, preloadArgs);
  return drinks.isEmpty ? null : drinks.single;
}

Future<List<Drink>> getDrinks({
  int? sessionId,
  List<String>? preloadArgs,
}) async {
  final Where where = Where();

  if (sessionId != null) {
    where.addEquals(Drink.colSessionId, sessionId, table: Drink.tableName);
  }

  return _getDrinks(where, preloadArgs);
}

Future<List<Drink>> getDrinkTemplates({List<String>? preloadArgs}) async {
  final Where where =
      Where(table: Drink.tableName, col: Drink.colSessionId, val: null);

  return _getDrinks(where, preloadArgs);
}

Future<List<Drink>> _getDrinks(
  Where where,
  List<String>? preloadArgs, {
  List<String>? columns,
  int? limit,
}) async {
  final Database db = await getSqfDb();
  final Preload preload = Preload();

  if (preloadArgs != null) {
    if (preloadArgs.contains(Drink.relSession)) {
      preload.add(
        Session.tableName,
        Session.colId,
        Drink.tableName,
        Drink.colSessionId,
        Session.columns,
      );
    }
  }

  final Query query = Query(
    Drink.tableName,
    columns: columns,
    where: where,
    preload: preload,
    limit: limit,
  );

  final List<Map<String, dynamic>> res =
      await db.rawQuery(query.sql, query.args);

  final List<Drink> drinks = <Drink>[];
  for (final Map<String, dynamic> drinkMap in res) {
    final Drink drink = Drink.fromMap(drinkMap);

    if (preloadArgs != null) {
      Map<String, dynamic>? sessionMap;

      if (preloadArgs.contains(Drink.relSession)) {
        sessionMap = Preload.extractPreLoadedMap(Session.tableName, drinkMap);

        drink.session = sessionMap != null ? Session.fromMap(sessionMap) : null;
      }
    }
    drinks.add(drink);
  }
  return drinks;
}

Future<Drink> insertDrink(Drink drink) async {
  final Database db = await getSqfDb();

  final List<Object?> result = await db.transaction((Transaction txn) async {
    final Batch batch = txn.batch();
    _insertDrink(batch, drink);
    return batch.commit();
  });

  final int? id = int.tryParse(result[0].toString());

  drink.id = id;
  return drink;
}

void _insertDrink(Batch batch, Drink drink) {
  final Insert insert = Insert(
    Drink.tableName,
    drink.toMap(forQuery: true),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
  batch.rawInsert(insert.sql, insert.args);
}

Future<List<Drink>> insertDrinks(List<Drink> drinks) async {
  final Database db = await getSqfDb();

  final List<Object?> result = await db.transaction((Transaction txn) async {
    final Batch batch = txn.batch();

    for (final Drink drink in drinks) {
      _insertDrink(batch, drink);
    }
    return batch.commit();
  });

  for (int i = 0; i < drinks.length; i++) {
    final int? id = int.tryParse(result[i].toString());
    drinks[i].id = id;
  }
  return drinks;
}

Future<Drink?> updateDrink(Drink drink, {bool insertMissing = false}) async {
  final Database db = await getSqfDb();

  final List<Object?> results = await db.transaction((Transaction txn) async {
    final Batch batch = txn.batch();
    _updateDrinks(batch, <Drink>[drink], insertMissing, false);
    return batch.commit();
  });

  final int? id = int.tryParse(results[0].toString());
  drink.id = id;

  return results[0] == 0 ? null : drink;
}

Future<List<Drink>> updateDrinks(
  List<Drink> drinks, {
  int? sessionId,
  bool insertMissing = false,
  bool removeDeleted = false,
}) async {
  final Database db = await getSqfDb();

  final List<Object?> result = await db.transaction((Transaction txn) async {
    final Batch batch = txn.batch();
    _updateDrinks(
      batch,
      drinks,
      insertMissing,
      removeDeleted,
      sessionId: sessionId,
    );
    return batch.commit();
  });

  final List<Drink> updated = <Drink>[];

  for (int i = 0; i < drinks.length; i++) {
    final int? updatedId = int.tryParse(result[i].toString());

    if (updatedId == 1) {
      updated.add(drinks[i]);
    } else if (drinks[i].id == null && updatedId != null && updatedId > 0) {
      drinks[i].id = updatedId;
      updated.add(drinks[i]);
    }
  }

  return drinks;
}

Batch _updateDrinks(
  Batch batch,
  List<Drink> drinks,
  bool insertMissing,
  bool removeDeleted, {
  int? sessionId,
}) {
  for (final Drink drink in drinks) {
    final Map<String, dynamic> drinkMap = drink.toMap(forQuery: true);

    if (insertMissing) {
      final Insert upsert = Insert(
        Drink.tableName,
        drinkMap,
        upsertConflictValues: <String>[Drink.colId],
        upsertAction: Update.forUpsert(drinkMap),
      );
      batch.rawInsert(upsert.sql, upsert.args);
    } else {
      final Where where = Where(col: Drink.colId, val: drink.id);

      final Update update = Update(Drink.tableName, drinkMap, where: where);
      batch.rawUpdate(update.sql, update.args);
    }
  }

  if (removeDeleted) {
    final Where where = Where();

    if (sessionId != null) {
      where.addEquals(Drink.colSessionId, sessionId);
    }
    final Query subQuery =
        Query(Drink.tableName, columns: <String>[Drink.colId]);
    where.addSubQuery(Drink.colId, subQuery, table: Drink.tableName);

    TempTable? tempTable;

    if (drinks.isNotEmpty) {
      final List<int?> updatedIds = drinks.map((Drink d) => d.id).toList();
      tempTable = TempTable(Drink.tableName);
      batch.execute(tempTable.createTableSql);
      tempTable.insertValues(batch, updatedIds);

      where.addSubQuery(
        Drink.colId,
        tempTable.query,
        table: Drink.tableName,
        not: true,
      );
    }

    final Delete delete = Delete(Drink.tableName, where: where);
    batch.rawDelete(delete.sql, delete.args);

    if (tempTable != null) batch.execute(tempTable.dropTableSql);
  }
  return batch;
}

Future<int> deleteDrink(Drink drink) async {
  final Where where = Where(col: Drink.colId, val: drink.id);
  return _deleteDrinks(where);
}

Future<int> deleteDrinks({int? sessionId}) async {
  final Where where = Where();

  if (sessionId != null) {
    where.addEquals(Drink.colSessionId, sessionId);
  }
  return _deleteDrinks(where);
}

Future<int> _deleteDrinks(Where where) async {
  final Database db = await getSqfDb();
  final Delete delete = Delete(Drink.tableName, where: where);
  return db.rawDelete(delete.sql, delete.args);
}
