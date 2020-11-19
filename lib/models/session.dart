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
    if (map[endedAt] != null) {
      endedAt = int.tryParse(map[colEndedAt].toString()) != null
          ? DateTime.fromMillisecondsSinceEpoch(
              int.tryParse(map[colEndedAt].toString()),
              isUtc: true)
          : DateTime.tryParse(map[colEndedAt].toString());
    }
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

    return map;
  }
}
