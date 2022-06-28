import 'package:count_me_down/database/db_utils.dart';
import 'package:count_me_down/database/repos/idb/drink_idb_repo.dart' as idb;
import 'package:count_me_down/database/repos/sqf/drink_sqf_repo.dart' as sqf;
import 'package:count_me_down/models/drink.dart';

Future<Drink?> getDrink(int id, {List<String>? preloadArgs}) {
  if (useSqfLiteDb) {
    return sqf.getDrink(id, preloadArgs: preloadArgs);
  } else {
    return idb.getDrink(id, preloadArgs: preloadArgs);
  }
}

Future<List<Drink>> getDrinks({int? sessionId, List<String>? preloadArgs}) {
  if (useSqfLiteDb) {
    return sqf.getDrinks(sessionId: sessionId, preloadArgs: preloadArgs);
  } else {
    return idb.getDrinks(sessionId: sessionId, preloadArgs: preloadArgs);
  }
}

Future<List<Drink>> getDrinkTemplates({List<String>? preloadArgs}) {
  if (useSqfLiteDb) {
    return sqf.getDrinkTemplates(preloadArgs: preloadArgs);
  } else {
    return idb.getDrinkTemplates(preloadArgs: preloadArgs);
  }
}

Future<int> insertDrink(Drink drink) {
  if (useSqfLiteDb) {
    return sqf.insertDrink(drink);
  } else {
    return idb.insertDrink(drink);
  }
}

Future<List<int>> insertDrinks(List<Drink> drinks) {
  if (useSqfLiteDb) {
    return sqf.insertDrinks(drinks);
  } else {
    return idb.insertDrinks(drinks);
  }
}

Future<int> updateDrink(Drink drink, {bool insertMissing = false}) {
  if (useSqfLiteDb) {
    return sqf.updateDrink(drink, insertMissing: insertMissing);
  } else {
    return idb.updateDrink(drink, insertMissing: insertMissing);
  }
}

Future<List<int>> updateDrinks(
  List<Drink> drinks, {
  int? sessionId,
  bool insertMissing = false,
  bool removeDeleted = false,
}) {
  if (useSqfLiteDb) {
    return sqf.updateDrinks(
      drinks,
      sessionId: sessionId,
      insertMissing: insertMissing,
      removeDeleted: removeDeleted,
    );
  } else {
    return idb.updateDrinks(
      drinks,
      sessionId: sessionId,
      insertMissing: insertMissing,
      removeDeleted: removeDeleted,
    );
  }
}

Future<int> deleteDrink(Drink drink) {
  if (useSqfLiteDb) {
    return sqf.deleteDrink(drink);
  } else {
    return idb.deleteDrink(drink);
  }
}

Future<int> deleteDrinks({int? sessionId}) {
  if (useSqfLiteDb) {
    return sqf.deleteDrinks(sessionId: sessionId);
  } else {
    return idb.deleteDrinks(sessionId: sessionId);
  }
}
