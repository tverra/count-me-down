import 'package:count_me_down/extensions.dart';
import 'package:count_me_down/models/session.dart';
import 'package:count_me_down/utils/data_parser.dart';
import 'package:count_me_down/utils/percent.dart';
import 'package:count_me_down/utils/volume.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class Drink {
  static const tableName = 'drink';
  static const colId = 'id';
  static const colSessionId = 'session_id';
  static const colName = 'name';
  static const colVolume = 'volume';
  static const colAlcoholConcentration = 'alcohol_concentration';
  static const colTimestamp = 'timestamp';
  static const colColor = 'color';
  static const colDrinkType = 'drink_type';
  static const relSession = 'session';

  static List _drinkTypes = [
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
  static const alcoholDensity = 0.8;
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
    volume = map[colVolume] != null ? Volume(map[colVolume]) : null;
    alcoholConcentration = map[colAlcoholConcentration] != null
        ? Percent(map[colAlcoholConcentration])
        : null;
    timestamp = p.tryParseDateTime(map[colTimestamp]);
    color = map[colColor] != null ? Color(map[colColor]) : null;
    drinkType =
        map[colDrinkType] != null && _drinkTypes.contains(map[colDrinkType])
            ? DrinkTypes.values[_drinkTypes.indexOf(map[colDrinkType])]
            : null;
    session = map[relSession] != null ? Session.fromMap(map[relSession]) : null;
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
      case DrinkTypes.glass_martini:
        return FontAwesomeIcons.martiniGlass;
      case DrinkTypes.glass_whiskey:
        return FontAwesomeIcons.whiskeyGlass;
      case DrinkTypes.wine_bottle:
        return FontAwesomeIcons.wineBottle;
      case DrinkTypes.wine_glass:
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
      colTimestamp: p.tryParseDateTime(timestamp),
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
  glass_martini,
  glass_whiskey,
  wine_bottle,
  wine_glass,
}
