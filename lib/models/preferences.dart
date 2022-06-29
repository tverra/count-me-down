import 'package:count_me_down/models/profile.dart';
import 'package:count_me_down/models/session.dart';
import 'package:count_me_down/utils/data_parser.dart';

class Preferences {
  static const tableName = 'preferences';
  static const colId = 'id';
  static const colActiveSessionId = 'active_session_id';
  static const colActiveProfileId = 'active_profile_id';
  static const colDrinkWebHook = 'drink_web_hook';
  static const relActiveSession = 'active_session';
  static const relActiveProfile = 'active_profile';

  int? id;
  int? activeSessionId;
  int? activeProfileId;
  String? drinkWebHook;

  Session? activeSession;
  Profile? activeProfile;

  Preferences({this.activeSessionId, this.activeProfileId, this.drinkWebHook});

  Preferences.fromMap(Map<String, dynamic> map) {
    final DataParser p = DataParser();

    id = p.tryParseInt(map[colId]);
    activeSessionId = p.tryParseInt(map[colActiveSessionId]);
    activeProfileId = p.tryParseInt(map[colActiveProfileId]);
    drinkWebHook = p.tryParseString(map[colDrinkWebHook]);

    activeSession = map[relActiveSession] != null
        ? Session.fromMap(map[relActiveSession])
        : null;
    activeProfile = map[relActiveProfile] != null
        ? Profile.fromMap(map[relActiveProfile])
        : null;
  }

  static List<String> get columns {
    return <String>[
      colId,
      colActiveSessionId,
      colActiveProfileId,
      colDrinkWebHook,
    ];
  }

  static List<Preferences>? fromMapList(dynamic list) {
    return (list as List<dynamic>?)
        ?.map<Preferences>(
          (dynamic preferences) =>
              Preferences.fromMap(preferences as Map<String, dynamic>),
        )
        .toList();
  }

  Map<String, dynamic> toMap({bool forQuery = false}) {
    final DataParser p = DataParser(forQuery: forQuery);

    final Map<String, dynamic> map = <String, dynamic>{
      colId: p.serializeInt(id),
      colActiveSessionId: p.serializeInt(activeSessionId),
      colActiveProfileId: p.serializeInt(activeProfileId),
      colDrinkWebHook: p.serializeString(drinkWebHook),
    };

    if (!forQuery) {
      map.putIfAbsent(
          relActiveSession, () => activeSession?.toMap(forQuery: forQuery));
      map.putIfAbsent(
          relActiveProfile, () => activeProfile?.toMap(forQuery: forQuery));
    }

    return map;
  }

  Preferences copy() {
    return Preferences.fromMap(toMap());
  }

  @override
  String toString() {
    return toMap().toString();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Preferences &&
          id == other.id &&
          activeSessionId == other.activeSessionId &&
          activeProfileId == other.activeProfileId &&
          drinkWebHook == other.drinkWebHook;

  @override
  int get hashCode =>
      id.hashCode ^
      activeSessionId.hashCode ^
      activeProfileId.hashCode ^
      drinkWebHook.hashCode;
}
