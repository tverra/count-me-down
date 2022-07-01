import 'dart:async';

import 'package:count_me_down/database/db_utils.dart';
import 'package:count_me_down/database/indexed_database.dart';
import 'package:count_me_down/database/sqf_database.dart';
import 'package:count_me_down/models/drink.dart';
import 'package:count_me_down/models/preferences.dart';
import 'package:count_me_down/models/profile.dart';
import 'package:count_me_down/models/session.dart';
import 'package:idb_sqflite/idb_sqflite.dart' as idb;
import 'package:sqflite/sqflite.dart' as sqf;

Future<void> loadTestDb({int? version, bool seed = false}) {
  return loadDb(version: version, inMemory: true, seed: seed);
}

Future<void> loadDb({
  int? version,
  bool inMemory = false,
  bool seed = false,
}) async {
  if (useSqfLiteDb) {
    await SqfDbProvider.db.getDatabase(
      version: version,
      inMemory: inMemory,
      seed: seed,
    );
  } else {
    await IdbProvider.db.getDatabase(
      version: version,
      inMemory: inMemory,
      seed: seed,
    );
  }
}

FutureOr<void> closeDb() async {
  if (useSqfLiteDb) {
    await SqfDbProvider.db.closeDatabase();
  } else {
    IdbProvider.db.closeDatabase();
  }
}

Future<void> deleteDb() async {
  if (useSqfLiteDb) {
    await SqfDbProvider.db.deleteDatabase();
  } else {
    IdbProvider.db.deleteDatabase();
  }
}

Future<void> clearDb() async {
  final List<String> tables = <String>[
    Profile.tableName,
    Session.tableName,
    Drink.tableName,
    Preferences.tableName,
  ];

  if (useSqfLiteDb) {
    final sqf.Database db = await SqfDbProvider.db.getDatabase();

    for (final String table in tables) {
      await db.delete(table);
    }
  } else {
    final idb.Database db = await IdbProvider.db.getDatabase();

    for (final String table in tables) {
      final idb.Transaction txn = db.transaction(table, idb.idbModeReadWrite);
      final idb.ObjectStore store = txn.objectStore(table);

      final List<Object> keys = await store.getAllKeys();

      for (final Object key in keys) {
        await store.delete(key);
      }

      await txn.completed;
    }
  }
}

DateTime getDateTime() {
  final int milliseconds = DateTime.now().toUtc().millisecondsSinceEpoch;
  return DateTime.fromMillisecondsSinceEpoch(milliseconds, isUtc: true);
}

Future<void> get idbDeleteDelay {
  return Future<void>.delayed(const Duration(seconds: 1));
}
