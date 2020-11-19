import 'package:count_me_down/database/database.dart';
import 'package:count_me_down/database/migrations.dart';
import 'package:count_me_down/models/drink.dart';
import 'package:count_me_down/models/profile.dart';
import 'package:count_me_down/models/session.dart';
import 'package:count_me_down/utils/mass.dart';
import 'package:count_me_down/utils/percentage.dart';
import 'package:count_me_down/utils/volume.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_ffi_test/sqflite_ffi_test.dart';

void main() {
  /*test('this is a test', () {
    final int actual = 42;
    final int expected = 69;
    expect(actual, expected);
  });*/

  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiTestInit();
  Database _db;

  setUp(() async {
    _db = await DBProvider.db
        .getDatabase(version: Migrations.latestVersion, inMemory: true);
  });

  group('Latest version', () {
    Map<String, dynamic> _session;
    Map<String, dynamic> _profile;
    Map<String, dynamic> _drink;

    setUp(() {
      _session = Session(
        name: 'name',
        startedAt: DateTime.now(),
        endedAt: DateTime.now(),
      ).toMap(forQuery: true);
      _profile = Profile(
        name: 'name',
        bodyWeight: Mass.exact(kilos: 75),
        bodyWaterPercentage: Percentage.fromPercentage(60),
        absorptionTime: Duration(minutes: 30),
        perMilMetabolizedPerHour: 0.15,
      ).toMap(forQuery: true);
      _drink = Drink(
        name: 'name',
        volume: Volume.exact(centilitres: 4),
        alcoholConcentration: Percentage.fromPercentage(40.0),
        timestamp: DateTime.now(),
        color: Colors.transparent,
        drinkType: DrinkTypes.beer,
      ).toMap(forQuery: true);
    });

    test('Database is created', () async {
      _profile['id'] = await _db.insert('profiles', _profile);
      _session['profile_id'] = _profile['id'];
      _drink['session_id'] = _session['id'];

      _session['id'] = await _db.insert('sessions', _session);
      _drink['id'] = await _db.insert('drinks', _drink);

      final Map<String, dynamic> profile =
          (await _db.query('profiles', where: 'id = ${_profile['id']}')).single;
      final Map<String, dynamic> session =
          (await _db.query('sessions', where: 'id = ${_session['id']}')).single;
      final Map<String, dynamic> drink =
          (await _db.query('drinks', where: 'id = ${_drink['id']}')).single;

      expect(profile, _profile);
      expect(session, _session);
      expect(drink, _drink);
    });
  });
}
