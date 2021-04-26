import 'package:count_me_down/database/migrations.dart';
import 'package:count_me_down/database/seed_data.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:sqflite_ffi_test/sqflite_ffi.dart';

class DBProvider {
  DBProvider._();

  static final DBProvider db = DBProvider._();
  static Database _database;
  final Migrations _migrations = Migrations();

  Future<Database> _initDB(int version, {bool inMemory, bool seed}) async {
    final String path = join(await getDatabasesPath(), "count_me_down.db");
    final DatabaseFactory databaseFactory = databaseFactoryFfi;
    Database db;
    sqfliteFfiInit();

    final OpenDatabaseOptions options = OpenDatabaseOptions(
        version: version,
        onOpen: (db) {},
        onUpgrade: (Database db, int oldVersion, int newVersion) async {
          debugPrint("Upgrading to version ${newVersion.toString()}");

          print('old version: $oldVersion');
          print('new version: $newVersion');

          await _migrations.migrate(db, oldVersion, newVersion);
        },
        onDowngrade: (Database db, int oldVersion, int newVersion) async {
          debugPrint("Downgrading to version ${newVersion.toString()}");

          print('old version: $oldVersion');
          print('new version: $newVersion');

          await _migrations.migrate(db, oldVersion, newVersion);
        },
        onCreate: (Database db, int version) async {
          print('version: $version');

          await _migrations.create(db, version);

          if (seed) {
            await SeedData.insertSeedData(db);
          }
        });

    if (inMemory) {
      db = await databaseFactory.openDatabase(inMemoryDatabasePath,
          options: options);
      print('inMemory version: ${await db.getVersion()}');
    } else {
      db = await databaseFactory.openDatabase(path, options: options);
      print('io file version: ${await db.getVersion()}');
    }

    await db.execute('PRAGMA foreign_keys = ON');
    return db;
  }

  Future<Database> getDatabase({
    int version,
    bool inMemory = false,
    bool seed = true,
  }) async {
    if (_database != null) return _database;
    _database = await _initDB(
      version ?? _migrations.latestVersion,
      inMemory: inMemory,
      seed: seed,
    );

    return _database;
  }
}
