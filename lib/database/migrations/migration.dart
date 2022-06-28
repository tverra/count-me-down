import 'package:count_me_down/utils/utils.dart';
import 'package:meta/meta.dart';
import 'package:sqflite/sqflite.dart';

import 'app_migrations.dart' as appMigrations;

class Migration {
  final int version;
  final List<String> actions;
  final List<String> rollback;

  const Migration({this.version, this.actions, this.rollback});
}

class Migrations {
  final List<Migration> migrations;

  Migrations({this.migrations});

  int get latestVersion {
    return (migrations ?? appMigrations.migrations).length;
  }

  Future<void> create(Database db, int version) async {
    await migrate(db: db, oldVersion: 0, newVersion: version);
  }

  Future<List<Object>> migrate({
    @required Database db,
    @required int oldVersion,
    @required int newVersion,
  }) async {
    if (newVersion > oldVersion) {
      return _migrate(db, oldVersion, newVersion);
    } else if (newVersion < oldVersion) {
      return _rollback(db, oldVersion, newVersion);
    }

    return <Object>[];
  }

  Future<List<Object>> _migrate(
      Database db, int oldVersion, int newVersion) async {
    return db.transaction((Transaction txn) async {
      final Batch batch = txn.batch();

      for (int i = oldVersion; i < newVersion; i++) {
        for (final String action in migrations[i].actions) {
          batch.execute(Utils.trimTextBlock(action));
        }
      }

      return batch.commit();
    });
  }

  Future<List<Object>> _rollback(
      Database db, int oldVersion, int newVersion) async {
    return db.transaction((Transaction txn) async {
      final Batch batch = txn.batch();

      for (int i = newVersion; i < oldVersion; i++) {
        for (final String rollback in migrations[i].rollback) {
          batch.execute(Utils.trimTextBlock(rollback));
        }
      }

      return batch.commit();
    });
  }
}
