import 'package:count_me_down/models/session.dart';
import 'package:count_me_down/utils/data_parser.dart';
import 'package:count_me_down/utils/mass.dart';
import 'package:count_me_down/utils/percent.dart';

class Profile {
  static const String tableName = 'profile';
  static const String colId = 'id';
  static const String colName = 'name';
  static const String colBodyWeight = 'body_weight';
  static const String colBodyWaterPercentage = 'body_water_percentage';
  static const String colAbsorptionTime = 'absorption_time';
  static const String colPerMilMetabolizedPerHour =
      'per_mil_metabolized_per_hour';
  static const String relSessions = 'sessions';

  int? id;
  String? name;
  Mass? bodyWeight;
  Percent? bodyWaterPercentage;
  Duration? absorptionTime;
  double? perMilMetabolizedPerHour;

  List<Session>? sessions;

  Profile({
    this.name,
    this.bodyWeight,
    this.bodyWaterPercentage,
    this.absorptionTime,
    this.perMilMetabolizedPerHour,
  });

  Profile.fromMap(Map<String, dynamic> map) {
    final DataParser p = DataParser();

    id = p.tryParseInt(map[colId]);
    name = p.tryParseString(map[colName]);
    bodyWeight = map[colBodyWeight] != null ? Mass(map[colBodyWeight]) : null;
    bodyWaterPercentage = map[colBodyWaterPercentage] != null
        ? Percent(map[colBodyWaterPercentage])
        : null;
    absorptionTime = map[colAbsorptionTime] != null
        ? Duration(milliseconds: map[colAbsorptionTime])
        : null;
    perMilMetabolizedPerHour =
        p.tryParseDouble(map[colPerMilMetabolizedPerHour]);
    sessions = map[relSessions] != null
        ? map[relSessions].map<Session>((s) => Session.fromMap(s)).toList()
        : null;
  }

  static List<String> get columns {
    return <String>[
      colId,
      colName,
      colBodyWeight,
      colBodyWaterPercentage,
      colAbsorptionTime,
      colPerMilMetabolizedPerHour,
    ];
  }

  static String getGender(double bodyWaterPercentage) {
    if (bodyWaterPercentage == 70.0) {
      return 'Male';
    } else if (bodyWaterPercentage == 60.0) {
      return 'Female';
    } else {
      return 'Average';
    }
  }

  Map<String, dynamic> toMap({bool forQuery = false}) {
    final DataParser p = DataParser(forQuery: forQuery);
    final Map<String, dynamic> map = <String, dynamic>{
      colId: p.serializeInt(id),
      colName: p.serializeString(name),
      colBodyWeight: bodyWeight?.grams,
      colBodyWaterPercentage: bodyWaterPercentage?.fraction,
      colAbsorptionTime: absorptionTime?.inMilliseconds,
      colPerMilMetabolizedPerHour: perMilMetabolizedPerHour,
    };

    if (!forQuery) {
      map.putIfAbsent(relSessions,
          () => sessions?.map((s) => s.toMap(forQuery: forQuery)).toList());
    }

    return map;
  }

  Profile copyWith({
    int? sessionId,
    String? name,
    Mass? bodyWeight,
    Percent? bodyWaterPercentage,
    Duration? absorptionTime,
    double? perMilMetabolizedPerHour,
  }) {
    return Profile(
      name: name ?? this.name,
      bodyWeight: bodyWeight ?? this.bodyWeight,
      bodyWaterPercentage: bodyWaterPercentage ?? this.bodyWaterPercentage,
      absorptionTime: absorptionTime ?? this.absorptionTime,
      perMilMetabolizedPerHour:
          perMilMetabolizedPerHour ?? this.perMilMetabolizedPerHour,
    );
  }

  Profile copy() {
    return Profile.fromMap(toMap());
  }

  @override
  String toString() {
    return toMap().toString();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Profile &&
          id == other.id &&
          name == other.name &&
          bodyWeight == other.bodyWeight &&
          bodyWaterPercentage == other.bodyWaterPercentage &&
          absorptionTime == other.absorptionTime &&
          perMilMetabolizedPerHour == other.perMilMetabolizedPerHour;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      bodyWeight.hashCode ^
      bodyWaterPercentage.hashCode ^
      absorptionTime.hashCode ^
      perMilMetabolizedPerHour.hashCode;
}
