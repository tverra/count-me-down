import 'dart:async';

import 'package:count_me_down/models/drink.dart';
import 'package:count_me_down/models/profile.dart';
import 'package:count_me_down/models/session.dart';
import 'package:count_me_down/utils/mass.dart';
import 'package:count_me_down/utils/percentage.dart';
import 'package:count_me_down/utils/volume.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import 'test_utils.dart';

class DataGenerator {
  Database db;

  DataGenerator(this.db);

  Future<Profile> insertProfile({
    int id,
    String name,
    Mass bodyWeight,
    Percentage bodyWaterPercentage,
    Duration absorptionTime,
    double perMilMetabolizedPerHour,
  }) async {
    final Profile profile = getProfile(
      id: id,
      name: name,
      bodyWeight: bodyWeight,
      bodyWaterPercentage: bodyWaterPercentage,
      absorptionTime: absorptionTime,
      perMilMetabolizedPerHour: perMilMetabolizedPerHour,
    );

    profile.id =
        await db.insert(Profile.tableName, profile.toMap(forQuery: true));

    return profile;
  }

  Profile getProfile({
    int id,
    String name,
    Mass bodyWeight,
    Percentage bodyWaterPercentage,
    Duration absorptionTime,
    double perMilMetabolizedPerHour,
  }) {
    final Profile profile = Profile(
      name: name ?? 'Profile',
      bodyWeight: bodyWeight ?? Mass.exact(kilos: 75),
      bodyWaterPercentage: bodyWaterPercentage ?? Percentage.fromPercentage(60),
      absorptionTime: absorptionTime ?? Duration(hours: 1),
      perMilMetabolizedPerHour: perMilMetabolizedPerHour ?? 0.15,
    );
    profile.id = id;

    return profile;
  }

  Future<Session> insertSession({
    int id,
    int profileId,
    String name,
    DateTime startedAt,
    DateTime endedAt,
    Profile profile,
  }) async {
    final Session session = getSession(
      id: id,
      profileId: profileId,
      name: name,
      startedAt: startedAt,
      endedAt: endedAt,
    );

    if (profileId == null) {
      final Profile relProfile = profile ?? getProfile();

      relProfile.id = session.profileId =
          await db.insert(Profile.tableName, relProfile.toMap(forQuery: true));
      session.profile = relProfile;
    } else if (profileId < 1) {
      session.profileId = null;
    }

    session.id =
        await db.insert(Session.tableName, session.toMap(forQuery: true));

    return session;
  }

  Session getSession({
    int id,
    int profileId,
    String name,
    DateTime startedAt,
    DateTime endedAt,
  }) {
    final DateTime dateTime = TestUtils.getDateTime();

    final Session session = Session(
      profileId: profileId,
      name: name ?? 'Session',
      startedAt: startedAt ?? dateTime.subtract(Duration(hours: 1)),
      endedAt: endedAt ?? dateTime,
    );
    session.id = id;

    return session;
  }

  Future<Drink> insertDrink({
    int id,
    int sessionId,
    String name,
    Volume volume,
    Percentage alcoholConcentration,
    DateTime timestamp,
    Color color,
    DrinkTypes drinkType,
    Session session,
  }) async {
    final Drink drink = getDrink(
      id: id,
      sessionId: sessionId,
      name: name,
      volume: volume,
      alcoholConcentration: alcoholConcentration,
      timestamp: timestamp,
      color: color,
      drinkType: drinkType,
    );

    if (sessionId == null) {
      final Session relSession = session ?? getSession();

      relSession.id = drink.sessionId =
          await db.insert(Session.tableName, relSession.toMap(forQuery: true));
      drink.session = relSession;
    } else if (sessionId < 1) {
      drink.sessionId = null;
    }

    drink.id = await db.insert(Drink.tableName, drink.toMap(forQuery: true));

    return drink;
  }

  Drink getDrink({
    int id,
    int sessionId,
    String name,
    Volume volume,
    Percentage alcoholConcentration,
    DateTime timestamp,
    Color color,
    DrinkTypes drinkType,
  }) {
    final DateTime dateTime = TestUtils.getDateTime();

    final Drink drink = Drink(
      sessionId: sessionId,
      name: name ?? 'Drink',
      volume: Volume(500),
      alcoholConcentration: Percentage(0.05),
      timestamp: dateTime,
      color: Color(4283215696),
      drinkType: DrinkTypes.beer,
    );
    drink.id = id;

    return drink;
  }
}
