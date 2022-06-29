import 'package:count_me_down/models/drink.dart';
import 'package:count_me_down/models/profile.dart';
import 'package:count_me_down/utils/data_parser.dart';

class Session {
  static const String tableName = 'session';
  static const String colId = 'id';
  static const String colProfileId = 'profile_id';
  static const String colName = 'name';
  static const String colStartedAt = 'started_at';
  static const String colEndedAt = 'ended_at';
  static const String relProfile = 'profile';
  static const String relDrinks = 'drinks';

  int? id;
  int? profileId;
  String? name;
  DateTime? startedAt;
  DateTime? endedAt;

  Profile? profile;
  List<Drink>? drinks;

  Session({
    this.profileId,
    this.name,
    this.startedAt,
    this.endedAt,
  });

  Session.fromMap(Map<String, dynamic> map) {
    final DataParser p = DataParser();

    id = p.tryParseInt(map[colId]);
    profileId = p.tryParseInt(map[colProfileId]);
    name = p.tryParseString(map[colName]);
    startedAt = p.tryParseDateTime(map[colStartedAt]);
    endedAt = p.tryParseDateTime(map[colEndedAt]);
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

  static List<Session>? fromMapList(dynamic list) {
    return (list as List<dynamic>?)
        ?.map<Session>(
          (dynamic session) => Session.fromMap(session as Map<String, dynamic>),
        )
        .toList();
  }

  Map<String, dynamic> toMap({bool forQuery = false}) {
    final DataParser p = DataParser(forQuery: forQuery);

    final Map<String, dynamic> map = <String, dynamic>{
      colId: p.serializeInt(id),
      colProfileId: p.serializeInt(profileId),
      colName: p.serializeString(name),
      colStartedAt: p.serializeDateTime(startedAt),
      colEndedAt: p.serializeDateTime(endedAt),
    };

    if (!forQuery) {
      map.putIfAbsent(relProfile, () => profile?.toMap(forQuery: forQuery));
      map.putIfAbsent(relDrinks,
          () => drinks?.map((d) => d.toMap(forQuery: forQuery)).toList());
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
