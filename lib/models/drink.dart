import 'package:count_me_down/extensions.dart';
import 'package:count_me_down/models/session.dart';
import 'package:count_me_down/utils/data_parser.dart';
import 'package:count_me_down/utils/percent.dart';
import 'package:count_me_down/utils/volume.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class Drink {
  static const String tableName = 'drinks';
  static const String colId = 'id';
  static const String colSessionId = 'session_id';
  static const String colName = 'name';
  static const String colVolume = 'volume';
  static const String colAlcoholConcentration = 'alcohol_concentration';
  static const String colTimestamp = 'timestamp';
  static const String colColor = 'color';
  static const String colDrinkType = 'drink_type';
  static const String relSession = 'session';

  static const List<String> _drinkTypes = <String>[
    'beer',
    'blender',
    'cocktail',
    'coffee',
    'flask',
    'glass_martini',
    'glass_whiskey',
    'wine_bottle',
    'wine_glass',
  ];
  static const double alcoholDensity = 0.8;
  int? id;
  int? sessionId;
  String? name;
  Volume? volume;
  Percent? alcoholConcentration;
  DateTime? timestamp;
  Color? color;
  DrinkTypes? drinkType;

  Session? session;

  Drink({
    this.sessionId,
    this.name,
    this.volume,
    this.alcoholConcentration,
    this.timestamp,
    this.color,
    this.drinkType,
  });

  Drink.fromMap(Map<String, dynamic> map) {
    final DataParser p = DataParser();

    id = p.tryParseInt(map[colId]);
    sessionId = p.tryParseInt(map[colSessionId]);
    name = p.tryParseString(map[colName]);
    volume = map[colVolume] != null ? Volume(map[colVolume] as int) : null;
    alcoholConcentration = map[colAlcoholConcentration] != null
        ? Percent(map[colAlcoholConcentration] as double)
        : null;
    timestamp = p.tryParseDateTime(map[colTimestamp]);
    color = map[colColor] != null ? Color(map[colColor] as int) : null;
    drinkType = map[colDrinkType] != null &&
            _drinkTypes.contains(map[colDrinkType])
        ? DrinkTypes.values[_drinkTypes.indexOf(map[colDrinkType] as String)]
        : null;
    session = map[relSession] != null
        ? Session.fromMap(map[relSession] as Map<String, dynamic>)
        : null;
  }

  static List<String> get columns {
    return <String>[
      colId,
      colSessionId,
      colName,
      colVolume,
      colAlcoholConcentration,
      colTimestamp,
      colColor,
      colDrinkType,
    ];
  }

  static List<Drink>? fromMapList(dynamic list) {
    return (list as List<dynamic>?)
        ?.map<Drink>(
          (dynamic drink) => Drink.fromMap(drink as Map<String, dynamic>),
        )
        .toList();
  }

  IconData get iconData {
    switch (drinkType) {
      case DrinkTypes.beer:
        return FontAwesomeIcons.beerMugEmpty;
      case DrinkTypes.blender:
        return FontAwesomeIcons.blender;
      case DrinkTypes.cocktail:
        return FontAwesomeIcons.martiniGlassCitrus;
      case DrinkTypes.coffee:
        return FontAwesomeIcons.mugSaucer;
      case DrinkTypes.flask:
        return FontAwesomeIcons.flask;
      case DrinkTypes.glassMartini:
        return FontAwesomeIcons.martiniGlass;
      case DrinkTypes.glassWhiskey:
        return FontAwesomeIcons.whiskeyGlass;
      case DrinkTypes.wineBottle:
        return FontAwesomeIcons.wineBottle;
      case DrinkTypes.wineGlass:
        return FontAwesomeIcons.wineGlassEmpty;
      default:
        return FontAwesomeIcons.whiskeyGlass;
    }
  }

  Map<String, dynamic> toMap({bool forQuery = false}) {
    final DataParser p = DataParser(forQuery: forQuery);
    final DrinkTypes? drinkType = this.drinkType;

    final Map<String, dynamic> map = <String, dynamic>{
      colId: p.serializeInt(id),
      colSessionId: p.serializeInt(sessionId),
      colName: p.serializeString(name),
      colVolume: volume?.millilitres,
      colAlcoholConcentration: alcoholConcentration?.fraction,
      colTimestamp: p.serializeDateTime(timestamp),
      colColor: color?.value,
      colDrinkType: drinkType != null ? _drinkTypes[drinkType.index] : null,
    };

    if (!forQuery) {
      map.putIfAbsent(relSession, () => session?.toMap(forQuery: forQuery));
    }

    return map;
  }

  double get alcoholContentInGrams {
    return (volume?.millilitres ?? 0) *
        (alcoholConcentration?.fraction ?? 0) *
        alcoholDensity;
  }

  bool consumedBetween(DateTime from, DateTime to) {
    final DateTime? timestamp = this.timestamp;

    if (timestamp == null) return false;

    return (timestamp.isAfter(from) || timestamp.isAtSameMomentAs(from)) &&
        (timestamp.isBefore(to) || timestamp.isAtSameMomentAs(to));
  }

  double currentlyAbsorbedAlcohol(Duration absorptionTime) {
    final DateTime now = MockableDateTime.current;

    final DateTime fullyAbsorbed =
        (timestamp ?? DateTime.now()).add(absorptionTime);
    final bool alreadyAbsorbed = fullyAbsorbed.isBefore(now);

    if (alreadyAbsorbed) {
      return alcoholContentInGrams;
    }

    final Duration timeUntilAbsorption = fullyAbsorbed.difference(now);
    final Duration totalAbsorptionTime =
        fullyAbsorbed.difference(timestamp ?? DateTime.now());
    final bool absorptionCompleted = timeUntilAbsorption == Duration.zero;
    final bool absorptionNotStarted = totalAbsorptionTime < timeUntilAbsorption;

    if (absorptionCompleted) {
      return alcoholContentInGrams;
    } else if (absorptionNotStarted) {
      return 0;
    }

    final double percentAbsorbed =
        1.0 - timeUntilAbsorption.inSeconds / totalAbsorptionTime.inSeconds;

    return alcoholContentInGrams * percentAbsorbed;
  }

  Drink copy() {
    return Drink.fromMap(toMap());
  }

  @override
  String toString() {
    final DateTime? timestamp = this.timestamp;

    if (timestamp == null) {
      return '(${volume.toString()}) - $name';
    }

    return '${DateFormat('HH:mm').format(timestamp.toLocal())} '
        '(${volume.toString()}) - $name';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Drink &&
          id == other.id &&
          sessionId == other.sessionId &&
          name == other.name &&
          volume == other.volume &&
          alcoholConcentration == other.alcoholConcentration &&
          timestamp == other.timestamp &&
          color == other.color &&
          drinkType == other.drinkType;

  @override
  int get hashCode =>
      id.hashCode ^
      sessionId.hashCode ^
      name.hashCode ^
      volume.hashCode ^
      alcoholConcentration.hashCode ^
      timestamp.hashCode ^
      color.hashCode ^
      drinkType.hashCode;
}

enum DrinkTypes {
  beer,
  blender,
  cocktail,
  coffee,
  flask,
  glassMartini,
  glassWhiskey,
  wineBottle,
  wineGlass,
}
