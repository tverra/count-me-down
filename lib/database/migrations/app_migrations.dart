import 'migration.dart';

List<Migration> migrations = [
  Migration(
    version: 1,
    actions: <String>[
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
