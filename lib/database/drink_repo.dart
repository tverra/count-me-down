import 'package:count_me_down/database/database.dart';
import 'package:count_me_down/models/drink.dart';
import 'package:count_me_down/models/session.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_wrapper/sqflite_wrapper.dart';

class DrinkRepo {
  static Future<Drink> getDrink(int id, {List<String> preloadArgs}) async {
    final Where where =
        Where(table: Drink.tableName, col: Drink.colId, val: id);

    final List<Drink> drinks = await _getDrinks(where, preloadArgs);
    return drinks.isEmpty ? null : drinks.single;
  }

  static Future<List<Drink>> getDrinks(
      {int sessionId, List<String> preloadArgs}) async {
    final Where where = Where();

    if (sessionId != null) {
      where.addEquals(Drink.colSessionId, sessionId, table: Drink.tableName);
    }

    return _getDrinks(where, preloadArgs);
  }

  static Future<List<Drink>> getDrinkTemplates(
      {List<String> preloadArgs}) async {
    final Where where =
        Where(table: Drink.tableName, col: Drink.colSessionId, val: null);

    return _getDrinks(where, preloadArgs);
  }

  static Future<List<Drink>> _getDrinks(Where where, List<String> preloadArgs,
      {List<String> columns, int limit}) async {
    final Database db = await _getDb();
    final Preload preload = Preload();

    if (preloadArgs != null) {
      if (preloadArgs.contains(Drink.relSession)) {
        preload.add(Session.tableName, Session.colId, Drink.tableName,
            Drink.colSessionId, Session.columns);
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
    for (Map<String, dynamic> drinkMap in res) {
      final Drink drink = Drink.fromMap(drinkMap);

      if (preloadArgs != null) {
        Map<String, dynamic> sessionMap;

        if (preloadArgs.contains(Drink.relSession)) {
          sessionMap = Preload.extractPreLoadedMap(Session.tableName, drinkMap);

          drink.session =
              sessionMap != null ? Session.fromMap(sessionMap) : null;
        }
      }
      drinks.add(drink);
    }
    return drinks;
  }

  static Future<int> insertDrink(Drink drink) async {
    final Database db = await _getDb();

    final int id = await db.transaction((Transaction txn) async {
      final Batch batch = txn.batch();
      _insertDrink(batch, drink);
      return (await batch.commit())[0];
    });

    drink.id = id;
    return drink.id;
  }

  static void _insertDrink(Batch batch, Drink drink) {
    final Insert insert = Insert(Drink.tableName, drink.toMap(forQuery: true),
        conflictAlgorithm: ConflictAlgorithm.replace);
    batch.rawInsert(insert.sql, insert.args);
  }

  static Future<List<int>> insertDrinks(List<Drink> drinks) async {
    final Database db = await _getDb();

    final List result = await db.transaction((Transaction txn) async {
      final Batch batch = txn.batch();

      for (Drink drink in drinks) {
        _insertDrink(batch, drink);
      }
      return batch.commit();
    });

    for (int i = 0; i < drinks.length; i++) {
      drinks[i].id = result[i];
    }
    return result.toList().cast<int>();
  }

  static Future<int> updateDrink(Drink drink,
      {bool insertMissing = false}) async {
    final Database db = await _getDb();

    final List results = await db.transaction((Transaction txn) async {
      final Batch batch = txn.batch();
      _updateDrinks(batch, [drink], insertMissing, false);
      return batch.commit();
    });

    return results.isEmpty ? 0 : results[0];
  }

  static Future<List<int>> updateDrinks(List<Drink> drinks,
      {int sessionId,
      bool insertMissing = false,
      bool removeDeleted = false}) async {
    final Database db = await _getDb();

    final List result = await db.transaction((Transaction txn) async {
      final Batch batch = txn.batch();
      _updateDrinks(batch, drinks, insertMissing, removeDeleted,
          sessionId: sessionId);
      return batch.commit();
    });

    final List<int> resultList = result.toList().cast<int>();

    for (int i = 0; i < drinks.length; i++) {
      if (drinks[i].id == null) {
        drinks[i].id = resultList[i];
      }
    }

    return resultList;
  }

  static Batch _updateDrinks(
      Batch batch, List<Drink> drinks, bool insertMissing, bool removeDeleted,
      {int sessionId}) {
    for (Drink drink in drinks) {
      final Map<String, dynamic> drinkMap = drink.toMap(forQuery: true);

      if (insertMissing) {
        final Insert upsert = Insert(
          Drink.tableName,
          drinkMap,
          upsertConflictValues: [Drink.colId],
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
      final Query subQuery = Query(Drink.tableName, columns: [Drink.colId]);
      where.addSubQuery(Drink.colId, subQuery, table: Drink.tableName);

      TempTable tempTable;

      if (drinks.length > 0) {
        final List updatedIds = drinks.map((d) => d.id).toList();
        tempTable = TempTable(Drink.tableName);
        batch.execute(tempTable.createTableSql);
        tempTable.insertValues(batch, updatedIds);

        where.addSubQuery(Drink.colId, tempTable.query,
            table: Drink.tableName, not: true);
      }

      final Delete delete = Delete(Drink.tableName, where: where);
      batch.rawDelete(delete.sql, delete.args);

      if (tempTable != null) batch.execute(tempTable.dropTableSql);
    }
    return batch;
  }

  static Future<int> deleteDrink(Drink drink) async {
    final Where where = Where(col: Drink.colId, val: drink.id);
    return _deleteDrinks(where);
  }

  static Future<int> deleteDrinks({int sessionId}) async {
    final Where where = Where();

    if (sessionId != null) {
      where.addEquals(Drink.colSessionId, sessionId);
    }
    return _deleteDrinks(where);
  }

  static Future<int> _deleteDrinks(Where where) async {
    final Database db = await _getDb();
    final Delete delete = Delete(Drink.tableName, where: where);
    return db.rawDelete(delete.sql, delete.args);
  }

  static Future<Database> _getDb() async {
    return DBProvider.db.getDatabase();
  }
}
