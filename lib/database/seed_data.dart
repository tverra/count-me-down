import 'package:count_me_down/database/db_utils.dart' as db_utils;
import 'package:count_me_down/models/drink.dart';
import 'package:count_me_down/models/preferences.dart';
import 'package:count_me_down/models/profile.dart';
import 'package:count_me_down/utils/mass.dart';
import 'package:count_me_down/utils/percent.dart';
import 'package:count_me_down/utils/utils.dart' as utils;
import 'package:count_me_down/utils/volume.dart';
import 'package:flutter/material.dart';
import 'package:idb_sqflite/idb_sqflite.dart' as idb;
import 'package:sqflite/sqflite.dart' as sqf;

final List<Profile> _profiles = <Profile>[
  Profile(
    name: 'Generic profile',
    bodyWeight: Mass.units(kilos: 75),
    bodyWaterPercentage: Percent.fromPercent(60),
    absorptionTime: const Duration(hours: 1),
    perMilMetabolizedPerHour: 0.15,
  ),
];
final List<Drink> _drinks = <Drink>[
  Drink(
    name: 'Shot',
    volume: Volume.exact(centilitres: 4),
    alcoholConcentration: Percent.fromPercent(40.0),
    color: Colors.green[800],
    drinkType: DrinkTypes.glassWhiskey,
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
    drinkType: DrinkTypes.wineGlass,
  ),
];
final Preferences _preferences = Preferences(
  activeProfileId: _profiles[0].id,
);

Future<void> insertSqfSeedData(sqf.Database db) async {
  try {
    await _seedDataToSqf(db);
  } catch (error, stacktrace) {
    debugPrint('\nConverting shared preferences to sqlite failed. Reason:');
    utils.printInternalErrors(<String, dynamic>{}, error, stacktrace);
  }
}

Future<void> insertIdbSeedData(idb.Database db) async {
  try {
    await _seedDataToIdb(db);
  } catch (error, stacktrace) {
    debugPrint('\nConverting shared preferences to sqlite failed. Reason:');
    utils.printInternalErrors(<String, dynamic>{}, error, stacktrace);
    await db_utils.clearIdb(db);
  }
}

Future<void> _seedDataToSqf(sqf.Database db) async {
  db.transaction((sqf.Transaction txn) async {
    final sqf.Batch batch = txn.batch();

    batch.insert(Preferences.tableName, _preferences.toMap(forQuery: true));

    for (final Profile profile in _profiles) {
      batch.insert(Profile.tableName, profile.toMap(forQuery: true));
    }
    for (final Drink drink in _drinks) {
      batch.insert(Drink.tableName, drink.toMap(forQuery: true));
    }

    batch.insert(Preferences.tableName, _preferences.toMap(forQuery: true));

    await batch.commit();
  });

}

Future<void> _seedDataToIdb(idb.Database db) async {
  for (final Profile profile in _profiles) {
    await db_utils.insertIntoIdb(
      Profile.tableName,
      profile.toMap(forQuery: true),
      key: profile.id,
      db: db,
    );
  }
  for (final Drink drink in _drinks) {
    await db_utils.insertIntoIdb(
      Drink.tableName,
      drink.toMap(forQuery: true),
      key: drink.id,
      db: db,
    );
  }
}
