import 'dart:async';

import 'package:count_me_down/database/migrations.dart';
import 'package:count_me_down/database/seed_data.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:idb_shim/idb_browser.dart';
// ignore: depend_on_referenced_packages
import 'package:idb_shim/idb_client_memory.dart';
import 'package:idb_sqflite/idb_sqflite.dart';

class IdbProvider {
  IdbProvider._();

  static final IdbProvider db = IdbProvider._();
  static const String _databaseName = 'count_me_down.db';
  static Database? _database;
  Future<dynamic>? initDbInProgress;
  IdbMigrations? _migrations;
  IdbFactory? _factory;

  Future<Database> _initDB(
    int version, {
    bool inMemory = false,
    bool seed = true,
  }) async {
    if (inMemory) {
      _factory = newIdbFactoryMemory();
    }
    final IdbFactory factory = _factory ??= idbFactoryBrowser;

    Database db;

    final IdbMigrations migrations = _migrations ??= IdbMigrations();

    db = await factory.open(
      _databaseName,
      version: version,
      onUpgradeNeeded: (VersionChangeEvent event) async {
        final Database db = event.database;

        if (event.oldVersion == 0) {
          debugPrint('Creating database version: $version');

          await migrations.create(db, version);
          await event.transaction.completed;

          if (seed) {
            debugPrint('Seeding database');
            await SeedData.insertIdbSeedData(db);
          }
        } else {
          debugPrint('Upgrading database to version ${event.newVersion}');
          debugPrint('old version: ${event.oldVersion}');
          debugPrint('new version: ${event.newVersion}');

          await migrations.migrate(
            db: db,
            oldVersion: event.oldVersion,
            newVersion: event.newVersion,
          );
          await event.transaction.completed;
        }
      },
    );

    if (inMemory) {
      debugPrint('inMemory version: $version');
    } else {
      debugPrint('io file version: $version');
    }

    return db;
  }

  Future<Database> getDatabase({
    int? version,
    bool inMemory = false,
    bool seed = true,
  }) async {
    final Database? db = _database;

    if (db != null) return db;

    if (initDbInProgress != null) {
      await initDbInProgress;
      return getDatabase(version: version, inMemory: inMemory, seed: seed);
    }

    final Completer<dynamic> completer = Completer<dynamic>();
    initDbInProgress = completer.future;

    final Database database = _database = await _initDB(
      version ?? (_migrations ?? IdbMigrations()).latestVersion,
      inMemory: inMemory,
      seed: seed,
    );

    completer.complete();
    initDbInProgress = null;

    return database;
  }

  void closeDatabase() {
    final Database? db = _database;

    if (db == null) return;

    db.close();
    _database = null;
  }

  Future<void> deleteDatabase() async {
    final IdbFactory? factory = _factory;
    final Database? db = _database;

    if (factory == null || db == null) return;

    db.close();
    await factory.deleteDatabase(_databaseName);

    _database = null;
    _migrations = null;
  }
}
