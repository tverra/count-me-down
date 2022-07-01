import 'package:sqflite_wrapper/sqflite_wrapper.dart';

class Migration {
  late final SqfColumn profilePrimaryKey;
  late final SqfTable profileTable;
  late final SqfColumn sessionPrimaryKey;
  late final SqfTable sessionTable;
  late final SqfTable drinkTable;

  Migration() {
    profilePrimaryKey = _getProfilePrimaryKey();
    profileTable = _getProfileTable();
    sessionPrimaryKey = _getSessionPrimaryKey();
    sessionTable = _getSessionTable();
    drinkTable = _getDrinkTable();
  }

  List<String> migrate() {
    return <String>[
      profileTable.create,
      sessionTable.create,
      drinkTable.create,
    ];
  }

  List<String> rollback() {
    return <String>[
      profileTable.drop,
      sessionTable.drop,
      drinkTable.drop,
    ];
  }

  SqfColumn _getProfilePrimaryKey() {
    return SqfColumn(
      name: 'id',
      type: SqfType.integer,
      properties: <SqfColumnProperty>[SqfColumnProperty.primaryKey],
    );
  }

  SqfTable _getProfileTable() {
    return SqfTable(
      name: 'profiles',
      columns: <SqfColumn>[
        profilePrimaryKey,
        SqfColumn(
          name: 'name',
          type: SqfType.text,
        ),
        SqfColumn(
          name: 'body_weight',
          type: SqfType.integer,
        ),
        SqfColumn(
          name: 'body_water_percentage',
          type: SqfType.integer,
        ),
        SqfColumn(
          name: 'absorption_time',
          type: SqfType.integer,
        ),
        SqfColumn(
          name: 'per_mil_metabolized_per_hour',
          type: SqfType.real,
        )
      ],
    );
  }

  SqfColumn _getSessionPrimaryKey() {
    return SqfColumn(
      name: 'id',
      type: SqfType.integer,
      properties: <SqfColumnProperty>[SqfColumnProperty.primaryKey],
    );
  }

  SqfTable _getSessionTable() {
    return SqfTable(
      name: 'sessions',
      columns: <SqfColumn>[
        sessionPrimaryKey,
        SqfColumn(
          name: 'profile_id',
          type: SqfType.integer,
          references: SqfReferences(
            foreignTableName: profileTable.name,
            foreignColumnName: profilePrimaryKey.name,
            onDelete: SqfAction.cascade,
          ),
        ),
        SqfColumn(
          name: 'name',
          type: SqfType.text,
        ),
        SqfColumn(
          name: 'started_at',
          type: SqfType.integer,
        ),
        SqfColumn(
          name: 'ended_at',
          type: SqfType.integer,
        ),
      ],
    );
  }

  SqfTable _getDrinkTable() {
    return SqfTable(
      name: 'drinks',
      columns: <SqfColumn>[
        SqfColumn(
          name: 'id',
          type: SqfType.integer,
          properties: <SqfColumnProperty>[SqfColumnProperty.primaryKey],
        ),
        SqfColumn(
          name: 'session_id',
          type: SqfType.integer,
          references: SqfReferences(
            foreignTableName: sessionTable.name,
            foreignColumnName: sessionPrimaryKey.name,
            onDelete: SqfAction.cascade,
          ),
        ),
        SqfColumn(
          name: 'name',
          type: SqfType.text,
        ),
        SqfColumn(
          name: 'volume',
          type: SqfType.integer,
        ),
        SqfColumn(
          name: 'alcohol_concentration',
          type: SqfType.real,
        ),
        SqfColumn(
          name: 'timestamp',
          type: SqfType.integer,
        ),
        SqfColumn(
          name: 'color',
          type: SqfType.integer,
        ),
        SqfColumn(
          name: 'drink_type',
          type: SqfType.text,
        ),
      ],
    );
  }
}
