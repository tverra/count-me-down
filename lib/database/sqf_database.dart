import 'dart:async';
import 'dart:io';

import 'package:count_me_down/database/migrations.dart';
import 'package:count_me_down/database/seed_data.dart' as seed_data;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class SqfDbProvider {
  SqfDbProvider._();

  static final SqfDbProvider db = SqfDbProvider._();
  static const String _databaseName = 'count_me_down.db';
  static Database? _database;
  Future<dynamic>? initDbInProgress;
  SqfMigrations? _migrations;

  Future<Database> _initDB(
    int version, {
    bool inMemory = false,
    bool seed = true,
  }) async {
    final String path = join(await _getDatabasesPath(), _databaseName);
    final DatabaseFactory databaseFactory = databaseFactoryFfi;
    Database db;
    sqfliteFfiInit();

    final SqfMigrations migrations = _migrations ??= SqfMigrations();

    final OpenDatabaseOptions options = OpenDatabaseOptions(
      version: version,
      onOpen: (Database db) {},
      onUpgrade: (Database db, int oldVersion, int newVersion) async {
        debugPrint('Upgrading database to version ${newVersion.toString()}');
        debugPrint('old version: $oldVersion');
        debugPrint('new version: $newVersion');

        await migrations.migrate(
          db: db,
          oldVersion: oldVersion,
          newVersion: newVersion,
        );
      },
      onDowngrade: (Database db, int oldVersion, int newVersion) async {
        debugPrint('Downgrading database to version $newVersion');
        debugPrint('old version: $oldVersion');
        debugPrint('new version: $newVersion');

        await migrations.migrate(
          db: db,
          oldVersion: oldVersion,
          newVersion: newVersion,
        );
      },
      onCreate: (Database db, int version) async {
        debugPrint('Creating database version: $version');

        await migrations.create(db, version);

        if (seed) {
          await seed_data.insertSqfSeedData(db);
        }
      },
    );

    if (inMemory) {
      db = await databaseFactory.openDatabase(
        inMemoryDatabasePath,
        options: options,
      );
      debugPrint('inMemory version: ${await db.getVersion()}');
    } else {
      db = await databaseFactory.openDatabase(path, options: options);
      debugPrint('io file version: ${await db.getVersion()}');
    }

    await db.execute('PRAGMA foreign_keys = ON');
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
      version ?? SqfMigrations().latestVersion,
      inMemory: inMemory,
      seed: seed,
    );

    completer.complete();
    initDbInProgress = null;

    return database;
  }

  Future<void> closeDatabase() async {
    final Database? db = _database;

    if (db == null) return;

    await db.close();
    _database = null;
  }

  Future<void> deleteDatabase() async {
    await closeDatabase();
    _migrations = null;
    final File database = File('${await _getDatabasesPath()}$_databaseName');

    if (await database.exists()) {
      await database.delete();
    }
  }

  FutureOr<String> _getDatabasesPath() {
    if (Platform.isAndroid || Platform.isIOS) {
      return getDatabasesPath();
    } else {
      return '${Directory.current.path}/.dart_tool/sqlite/';
    }
  }
}
