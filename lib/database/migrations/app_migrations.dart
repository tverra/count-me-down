import 'package:count_me_down/database/migrations.dart' as migrations;
import 'package:count_me_down/database/migrations/v1.dart' as v1;
import 'package:count_me_down/database/migrations/v2.dart' as v2;

class Migrations {
  late final v1.Migration migrationV1;
  late final v2.Migration migrationV2;

  Migrations() {
    migrationV1 = v1.Migration();
    migrationV2 = v2.Migration(migrationV1: migrationV1);
  }

  List<migrations.SqfMigration> getSqfMigrations() {
    return <migrations.SqfMigration>[
      migrations.SqfMigration(
        version: 1,
        migration: migrationV1.migrate,
        rollback: migrationV1.rollback,
      ),
      migrations.SqfMigration(
        version: 2,
        migration: migrationV2.migrate,
        rollback: migrationV2.rollback,
      )
    ];
  }

  List<migrations.IdbMigration> getIdbMigrations() {
    return <migrations.IdbMigration>[
      migrations.IdbMigration(
        version: 1,
        properties: <migrations.IdbMigrationTable>[
          migrations.IdbMigrationTable(
            migrationV1.profileTable,
            autoIncrement: true,
          ),
          migrations.IdbMigrationTable(
            migrationV1.sessionTable,
            autoIncrement: true,
          ),
          migrations.IdbMigrationTable(
            migrationV1.drinkTable,
            autoIncrement: true,
          ),
        ],
      ),
      migrations.IdbMigration(
        version: 2,
        properties: <migrations.IdbMigrationTable>[
          migrations.IdbMigrationTable(
            migrationV2.preferencesTable,
            autoIncrement: true,
          ),
        ],
      ),
    ];
  }
}
