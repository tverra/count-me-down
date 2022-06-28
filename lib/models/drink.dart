import 'dart:ui';

import 'package:count_me_down/extensions.dart';
import 'package:count_me_down/models/session.dart';
import 'package:count_me_down/utils/percent.dart';
import 'package:count_me_down/utils/volume.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class Drink {
  static const tableName = 'drinks';
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
  int id;
  int sessionId;
  String name;
  Volume volume;
  Percent alcoholConcentration;
  DateTime timestamp;
  Color color;
  DrinkTypes drinkType;

  Session session;

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
    id = map[colId];
    sessionId = map[colSessionId];
    name = map[colName];
    volume = map[colVolume] != null ? Volume(map[colVolume]) : null;
    alcoholConcentration = map[colAlcoholConcentration] != null
        ? Percent(map[colAlcoholConcentration])
        : null;
    if (map[colTimestamp] != null) {
      timestamp = int.tryParse(map[colTimestamp].toString()) != null
          ? DateTime.fromMillisecondsSinceEpoch(
              int.tryParse(map[colTimestamp].toString()),
              isUtc: true)
          : DateTime.tryParse(map[colTimestamp].toString());
    }
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

  IconData get iconData {
    switch (drinkType) {
      case DrinkTypes.beer:
        return FontAwesomeIcons.beer;
      case DrinkTypes.blender:
        return FontAwesomeIcons.blender;
      case DrinkTypes.cocktail:
        return FontAwesomeIcons.cocktail;
      case DrinkTypes.coffee:
        return FontAwesomeIcons.coffee;
      case DrinkTypes.flask:
        return FontAwesomeIcons.flask;
      case DrinkTypes.glass_martini:
        return FontAwesomeIcons.glassMartiniAlt;
      case DrinkTypes.glass_whiskey:
        return FontAwesomeIcons.glassWhiskey;
      case DrinkTypes.wine_bottle:
        return FontAwesomeIcons.wineBottle;
      case DrinkTypes.wine_glass:
        return FontAwesomeIcons.wineGlassAlt;
      default:
        return FontAwesomeIcons.glassWhiskey;
    }
  }

  Map<String, dynamic> toMap({bool forQuery = false}) {
    final Map<String, dynamic> map = <String, dynamic>{};

    map[colId] = id;
    map[colSessionId] = sessionId;
    map[colName] = name;
    map[colVolume] = volume != null ? volume.millilitres : null;
    map[colAlcoholConcentration] =
        alcoholConcentration != null ? alcoholConcentration.fraction : null;
    map[colTimestamp] = timestamp != null
        ? forQuery
            ? timestamp.millisecondsSinceEpoch
            : timestamp.toIso8601String()
        : null;
    map[colColor] = color != null ? color.value : null;
    map[colDrinkType] = drinkType != null ? _drinkTypes[drinkType.index] : null;

    if (!forQuery) {
      map[relSession] =
          session != null ? session.toMap(forQuery: forQuery) : null;
    }

    return map;
  }

  double get alcoholContentInGrams {
    return volume.millilitres * alcoholConcentration.fraction * alcoholDensity;
  }

  bool consumedBetween(DateTime from, DateTime to) {
    return (timestamp.isAfter(from) || timestamp.isAtSameMomentAs(from)) &&
        (timestamp.isBefore(to) || timestamp.isAtSameMomentAs(to));
  }

  double currentlyAbsorbedAlcohol(Duration absorptionTime) {
    final DateTime now = MockableDateTime.current;
    final DateTime fullyAbsorbed = timestamp.add(absorptionTime);
    final bool alreadyAbsorbed = fullyAbsorbed.isBefore(now);

    if (alreadyAbsorbed) {
      return alcoholContentInGrams;
    }

    final Duration timeUntilAbsorption = fullyAbsorbed.difference(now);
    final Duration totalAbsorptionTime = fullyAbsorbed.difference(timestamp);
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
