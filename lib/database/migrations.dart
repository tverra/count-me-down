import 'package:count_me_down/utils/utils.dart';
import 'package:sqflite/sqflite.dart';

class Migration {
  final int version;
  final List<String> actions;
  final List<String> rollback;

  const Migration({this.version, this.actions, this.rollback});
}

class Migrations {
  final List<Migration> migrations;

  Migrations({this.migrations = appMigrations});

  int get latestVersion {
    return migrations.length;
  }

  Future<void> create(Database db, int version) async {
    await migrate(db, 0, version);
  }

  Future<void> migrate(Database db, int oldVersion, int newVersion) async {
    await db.transaction((Transaction txn) async {
      final Batch batch = txn.batch();

      for (int i = oldVersion; i < newVersion; i++) {
        migrations[i]
            .actions
            .forEach((action) => batch.execute(Utils.trimTextBlock(action)));
      }

      await batch.commit();
    });
  }

  static const List<Migration> appMigrations = [
    Migration(
      version: 1,
      actions: [
        """CREATE TABLE sessions (
          id INTEGER PRIMARY KEY,
          profile_id INTEGER REFERENCES profiles(id) ON DELETE CASCADE,
          name TEXT,
          started_at INTEGER,
          ended_at INTEGER
        );""",
        """CREATE TABLE profiles (
          id INTEGER PRIMARY KEY,
          name TEXT,
          body_weight INTEGER,
          body_water_percentage INTEGER,
          absorption_time INTEGER,
          per_mil_metabolized_per_hour REAL
        );""",
        """CREATE TABLE drinks (
          id INTEGER PRIMARY KEY,
          session_id INTEGER REFERENCES sessions(id) ON DELETE CASCADE,
          name TEXT,
          volume INTEGER,
          alcohol_concentration REAL,
          timestamp INTEGER,
          color INTEGER,
          drink_type TEXT
        );""",
      ],
      rollback: [
        'DROP TABLE drinks;',
        'DROP TABLE profiles;',
        'DROP TABLE sessions;',
      ],
    )
  ];
}
