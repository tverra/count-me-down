import 'package:count_me_down/database/migrations/v1.dart' as v1;
import 'package:sqflite_wrapper/sqflite_wrapper.dart';

class Migration {
  final v1.Migration migrationV1;
  late final SqfTable preferencesTable;

  Migration({required this.migrationV1}) {
    preferencesTable = _getPreferencesTable();
  }

  List<String> migrate() {
    return <String>[preferencesTable.create];
  }

  List<String> rollback() {
    return <String>[preferencesTable.drop];
  }

  SqfTable _getPreferencesTable() {
    return SqfTable(
      name: 'preferences',
      columns: <SqfColumn>[
        SqfColumn(
          name: 'id',
          type: SqfType.integer,
          properties: <SqfColumnProperty>[SqfColumnProperty.primaryKey],
        ),
        SqfColumn(
          name: 'active_session_id',
          type: SqfType.integer,
          references: SqfReferences(
            foreignTableName: migrationV1.profileTable.name,
            foreignColumnName: migrationV1.profilePrimaryKey.name,
            onDelete: SqfAction.setNull,
          ),
        ),
        SqfColumn(
          name: 'active_profile_id',
          type: SqfType.integer,
          references: SqfReferences(
            foreignTableName: migrationV1.profileTable.name,
            foreignColumnName: migrationV1.profilePrimaryKey.name,
            onDelete: SqfAction.setNull,
          ),
        ),
        SqfColumn(
          name: 'drink_web_hook',
          type: SqfType.text,
        ),
      ],
    );
  }
}
