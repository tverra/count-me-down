import 'package:count_me_down/database/migrations/app_migrations.dart'
    as app_migrations;
import 'package:count_me_down/utils/utils.dart' as utils;
import 'package:idb_sqflite/idb_sqflite.dart' as idb;
import 'package:sqflite/sqflite.dart' as sqf;
import 'package:sqflite_wrapper/sqflite_wrapper.dart';

typedef MigrationActions = List<String> Function();

class SqfMigration {
  final int version;
  final MigrationActions _migration;
  final MigrationActions _rollback;
  List<String>? cachedMigration;
  List<String>? cachedRollback;

  SqfMigration({
    required this.version,
    required MigrationActions migration,
    required MigrationActions rollback,
  })  : _migration = migration,
        _rollback = rollback;

  MigrationActions get migrate {
    final List<String>? cached = cachedMigration;

    return () {
      if (cached != null) {
        return cached;
      }

      return cachedMigration = _migration();
    };
  }

  MigrationActions get rollback {
    final List<String>? cached = cachedRollback;

    return () {
      if (cached != null) {
        return cached;
      }

      return cachedRollback = _rollback();
    };
  }
}

class IdbMigration {
  final int version;
  final List<IdbMigrationTable> properties;

  const IdbMigration({
    required this.version,
    required this.properties,
  });
}

class IdbMigrationTable {
  final SqfTable table;
  final bool autoIncrement;
  final List<IdbIndex>? indexes;

  IdbMigrationTable(this.table, {required this.autoIncrement, this.indexes});
}

class IdbIndex {
  final String name;
  final dynamic keyPath;
  final bool? unique;
  final bool? multiEntry;

  const IdbIndex(this.name, this.keyPath, {this.unique, this.multiEntry});
}

class SqfMigrations {
  final List<SqfMigration>? migrations;
  late final List<SqfMigration> appMigrations;

  SqfMigrations({this.migrations}) {
    appMigrations = app_migrations.Migrations().getSqfMigrations();

    for (int i = 0; i < appMigrations.length; i++) {
      appMigrations[i].migrate();
    }
    for (int i = appMigrations.length - 1; i >= 0; i--) {
      appMigrations[i].rollback();
    }
  }

  int get latestVersion {
    return (migrations ?? appMigrations).length;
  }

  Future<void> create(sqf.Database db, int version) async {
    await migrate(db: db, oldVersion: 0, newVersion: version);
  }

  Future<List<Object?>> migrate({
    required sqf.Database db,
    required int oldVersion,
    required int newVersion,
  }) async {
    if (newVersion > oldVersion) {
      return _migrate(db, oldVersion, newVersion);
    } else if (newVersion < oldVersion) {
      return _rollback(db, oldVersion, newVersion);
    }

    return <Object>[];
  }

  Future<List<Object?>> _migrate(
    sqf.Database db,
    int oldVersion,
    int newVersion,
  ) async {
    final List<SqfMigration> sqfMigrations = migrations ?? appMigrations;

    return db.transaction((sqf.Transaction txn) async {
      final sqf.Batch batch = txn.batch();

      for (int i = oldVersion; i < newVersion; i++) {
        final List<String> actions = sqfMigrations[i].migrate();

        for (final String action in actions) {
          batch.execute(utils.trimTextBlock(action));
        }
      }

      return batch.commit();
    });
  }

  Future<List<Object?>> _rollback(
    sqf.Database db,
    int oldVersion,
    int newVersion,
  ) async {
    final List<SqfMigration> sqfMigrations = migrations ?? appMigrations;

    return db.transaction((sqf.Transaction txn) async {
      final sqf.Batch batch = txn.batch();

      for (int i = oldVersion - 1; i >= newVersion; i--) {
        if (sqfMigrations.length <= i) continue;

        final List<String> actions = sqfMigrations[i].rollback();

        for (final String action in actions) {
          batch.execute(utils.trimTextBlock(action));
        }
      }

      return batch.commit();
    });
  }
}

class IdbMigrations {
  final List<IdbMigration>? migrations;
  late final List<IdbMigration> appMigrations;

  IdbMigrations({this.migrations}) {
    appMigrations = app_migrations.Migrations().getIdbMigrations();
  }

  int get latestVersion {
    return (migrations ?? appMigrations).length;
  }

  Future<void> create(idb.Database db, int version) async {
    final int numberOfMigrations = (migrations ?? appMigrations).length;
    final int versionOrHighest =
        version < numberOfMigrations ? version : numberOfMigrations;

    await migrate(db: db, oldVersion: 0, newVersion: versionOrHighest);
  }

  Future<List<idb.ObjectStore>> migrate({
    required idb.Database db,
    required int oldVersion,
    required int newVersion,
  }) async {
    final int numberOfMigrations = (migrations ?? appMigrations).length;
    final int newVersionOrHighest =
        newVersion < numberOfMigrations ? newVersion : numberOfMigrations;
    final int oldVersionOrHighest =
        oldVersion < numberOfMigrations ? oldVersion : numberOfMigrations;

    if (newVersionOrHighest > oldVersionOrHighest) {
      return _migrate(db, oldVersion, newVersion);
    } else if (newVersionOrHighest < oldVersionOrHighest) {
      _rollback(db, oldVersion, newVersion);
    }

    return <idb.ObjectStore>[];
  }

  List<idb.ObjectStore> _migrate(
    idb.Database db,
    int oldVersion,
    int newVersion,
  ) {
    final List<idb.ObjectStore> objectStores = <idb.ObjectStore>[];
    final List<IdbMigration> idbMigrations = migrations ?? appMigrations;

    for (int i = oldVersion; i < newVersion; i++) {
      if (i >= appMigrations.length) break;

      for (final IdbMigrationTable table in idbMigrations[i].properties) {
        final idb.ObjectStore store = db.createObjectStore(
          table.table.name,
          autoIncrement: table.autoIncrement,
        );

        for (final IdbIndex index in table.indexes ?? <IdbIndex>[]) {
          store.createIndex(
            index.name,
            index.keyPath,
            unique: index.unique,
            multiEntry: index.multiEntry,
          );
        }

        objectStores.add(store);
      }
    }

    return objectStores;
  }

  void _rollback(
    idb.Database db,
    int oldVersion,
    int newVersion,
  ) {
    for (int i = newVersion; i < oldVersion; i++) {
      for (final IdbMigrationTable table
          in (migrations ?? appMigrations)[i].properties) {
        db.deleteObjectStore(table.table.name);
      }
    }
  }
}
