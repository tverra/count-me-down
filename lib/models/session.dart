import 'package:count_me_down/models/drink.dart';
import 'package:count_me_down/models/profile.dart';

class Session {
  static const String tableName = 'sessions';
  static const String colId = 'id';
  static const String colProfileId = 'profile_id';
  static const String colName = 'name';
  static const String colStartedAt = 'started_at';
  static const String colEndedAt = 'ended_at';
  static const String relProfile = 'profile';
  static const String relDrinks = 'drinks';

  int id;
  int profileId;
  String name;
  DateTime startedAt;
  DateTime endedAt;

  Profile profile;
  List<Drink> drinks;

  Session({
    this.profileId,
    this.name,
    this.startedAt,
    this.endedAt,
  });

  Session.fromMap(Map<String, dynamic> map) {
    id = map[colId];
    profileId = map[colProfileId];
    name = map[colName];
    if (map[colStartedAt] != null) {
      startedAt = int.tryParse(map[colStartedAt].toString()) != null
          ? DateTime.fromMillisecondsSinceEpoch(
              int.tryParse(map[colStartedAt].toString()),
              isUtc: true)
          : DateTime.tryParse(map[colStartedAt].toString());
    }
    if (map[colEndedAt] != null) {
      endedAt = int.tryParse(map[colEndedAt].toString()) != null
          ? DateTime.fromMillisecondsSinceEpoch(
              int.tryParse(map[colEndedAt].toString()),
              isUtc: true)
          : DateTime.tryParse(map[colEndedAt].toString());
    }
    profile = map[relProfile] != null ? Profile.fromMap(map[relProfile]) : null;
    drinks = map[relDrinks] != null
        ? map[relDrinks].map<Drink>((d) => Drink.fromMap(d)).toList()
        : null;
  }

  static List<String> get columns {
    return <String>[
      colId,
      colProfileId,
      colName,
      colStartedAt,
      colEndedAt,
    ];
  }

  Map<String, dynamic> toMap({bool forQuery = false}) {
    final Map<String, dynamic> map = <String, dynamic>{};

    map[colId] = id;
    map[colProfileId] = profileId;
    map[colName] = name;
    map[colStartedAt] = startedAt != null
        ? forQuery
            ? startedAt.millisecondsSinceEpoch
            : startedAt.toIso8601String()
        : null;
    map[colEndedAt] = endedAt != null
        ? forQuery
            ? endedAt.millisecondsSinceEpoch
            : endedAt.toIso8601String()
        : null;

    if (!forQuery) {
      map[relProfile] =
          profile != null ? profile.toMap(forQuery: forQuery) : null;
      map[relDrinks] = drinks != null
          ? drinks.map((d) => d.toMap(forQuery: forQuery)).toList()
          : null;
    }

    return map;
  }

  Session copy() {
    return Session.fromMap(toMap());
  }

  @override
  String toString() {
    return toMap().toString();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Session &&
          id == other.id &&
          profileId == other.profileId &&
          name == other.name &&
          startedAt == other.startedAt &&
          endedAt == other.endedAt;

  @override
  int get hashCode =>
      id.hashCode ^
      profileId.hashCode ^
      name.hashCode ^
      startedAt.hashCode ^
      endedAt.hashCode;
}
