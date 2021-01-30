import 'package:count_me_down/models/drink.dart';
import 'package:count_me_down/models/profile.dart';
import 'package:count_me_down/utils/mass.dart';
import 'package:count_me_down/utils/percent.dart';
import 'package:count_me_down/utils/volume.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class SeedData {
  static final List<Profile> _profiles = <Profile>[
    Profile(
      name: 'Generic profile',
      bodyWeight: Mass.exact(kilos: 75),
      bodyWaterPercentage: Percent.fromPercentage(60),
      absorptionTime: Duration(hours: 1),
      perMilMetabolizedPerHour: 0.15,
    ),
  ];
  static final List<Drink> _drinks = <Drink>[
    Drink(
      name: 'Shot',
      volume: Volume.exact(centilitres: 4),
      alcoholConcentration: Percent.fromPercentage(40.0),
      color: Colors.green[800],
      drinkType: DrinkTypes.glass_whiskey,
    ),
    Drink(
      name: 'Beer',
      volume: Volume.exact(decilitres: 5),
      alcoholConcentration: Percent.fromPercentage(4.7),
      color: Colors.orangeAccent,
      drinkType: DrinkTypes.beer,
    ),
    Drink(
      name: 'Wine',
      volume: Volume.exact(centilitres: 15),
      alcoholConcentration: Percent.fromPercentage(12.5),
      color: Colors.red[600],
      drinkType: DrinkTypes.wine_glass,
    ),
  ];

  static Future<void> insertSeedData(Database db) async {
    await db.transaction((Transaction txn) async {
      final Batch batch = txn.batch();

      _profiles.forEach((profile) {
        batch.insert('profiles', profile.toMap(forQuery: true));
      });
      _drinks.forEach((drink) {
        batch.insert('drinks', drink.toMap(forQuery: true));
      });

      await batch.commit();
    });
  }
}
