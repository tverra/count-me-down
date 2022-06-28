import 'package:count_me_down/models/drink.dart';
import 'package:count_me_down/models/preferences.dart';
import 'package:count_me_down/models/profile.dart';
import 'package:count_me_down/utils/mass.dart';
import 'package:count_me_down/utils/percent.dart';
import 'package:count_me_down/utils/volume.dart';
import 'package:flutter/material.dart';
import 'package:idb_sqflite/idb_sqflite.dart' as idb;
import 'package:sqflite/sqflite.dart' as sqf;

class SeedData {
  static final Preferences _preferences = Preferences();

  static final List<Profile> _profiles = <Profile>[
    Profile(
      name: 'Generic profile',
      bodyWeight: Mass.units(kilos: 75),
      bodyWaterPercentage: Percent.fromPercent(60),
      absorptionTime: Duration(hours: 1),
      perMilMetabolizedPerHour: 0.15,
    ),
  ];
  static final List<Drink> _drinks = <Drink>[
    Drink(
      name: 'Shot',
      volume: Volume.exact(centilitres: 4),
      alcoholConcentration: Percent.fromPercent(40.0),
      color: Colors.green[800],
      drinkType: DrinkTypes.glass_whiskey,
    ),
    Drink(
      name: 'Beer',
      volume: Volume.exact(decilitres: 5),
      alcoholConcentration: Percent.fromPercent(4.7),
      color: Colors.orangeAccent,
      drinkType: DrinkTypes.beer,
    ),
    Drink(
      name: 'Wine',
      volume: Volume.exact(centilitres: 15),
      alcoholConcentration: Percent.fromPercent(12.5),
      color: Colors.red[600],
      drinkType: DrinkTypes.wine_glass,
    ),
  ];

  static Future<void> insertSqfSeedData(sqf.Database db) async {
    await db.transaction((sqf.Transaction txn) async {
      final sqf.Batch batch = txn.batch();

      batch.insert(Preferences.tableName, _preferences.toMap(forQuery: true));

      _profiles.forEach((profile) {
        batch.insert(Profile.tableName, profile.toMap(forQuery: true));
      });
      _drinks.forEach((drink) {
        batch.insert(Drink.tableName, drink.toMap(forQuery: true));
      });

      await batch.commit();
    });
  }

  static Future<void> insertIdbSeedData(idb.Database db) async {
    throw UnimplementedError();
  }
}
