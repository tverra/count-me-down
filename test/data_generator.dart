import 'dart:async';

import 'package:count_me_down/models/drink.dart';
import 'package:count_me_down/models/preferences.dart';
import 'package:count_me_down/models/profile.dart';
import 'package:count_me_down/models/session.dart';
import 'package:count_me_down/utils/mass.dart';
import 'package:count_me_down/utils/percent.dart';
import 'package:count_me_down/utils/volume.dart';
import 'package:flutter/material.dart';

import 'test_utils.dart' as test_utils;
import 'test_db_utils.dart' as db_utils;

Future<Drink> insertDrink({
  int? id,
  int? sessionId,
  String? name,
  Volume? volume,
  Percent? alcoholConcentration,
  DateTime? timestamp,
  Color? color,
  DrinkTypes? drinkType,
  Session? session,
}) async {
  Session? relSession;

  if (sessionId == null) {
    relSession = session ?? getSession();
    await db_utils.insertSession(relSession);
  }

  final int? relSessionId = relSession?.id ?? sessionId;

  final Drink drink = getDrink(
    id: id,
    sessionId:
        relSessionId == null ? null : (relSessionId > 0 ? relSessionId : null),
    name: name,
    volume: volume,
    alcoholConcentration: alcoholConcentration,
    timestamp: timestamp,
    color: color,
    drinkType: drinkType,
    session: session,
  );

  drink.session = relSession ?? session;

  drink.id = await db_utils.insertDrink(drink);

  return drink;
}

Drink getDrink({
  int? id,
  int? sessionId,
  String? name,
  Volume? volume,
  Percent? alcoholConcentration,
  DateTime? timestamp,
  Color? color,
  DrinkTypes? drinkType,
  Session? session,
}) {
  final DateTime dateTime = test_utils.getDateTime();

  final Drink drink = Drink(
    sessionId: sessionId,
    name: name ?? 'Drink',
    volume: volume ?? Volume(500),
    alcoholConcentration: alcoholConcentration ?? Percent(0.05),
    timestamp: timestamp ?? dateTime,
    color: color ?? Color(4283215696),
    drinkType: drinkType ?? DrinkTypes.beer,
  );
  drink.id = id;
  drink.session = session;

  return drink;
}

Future<Profile> insertProfile({
  int? id,
  String? name,
  Mass? bodyWeight,
  Percent? bodyWaterPercentage,
  Duration? absorptionTime,
  double? perMilMetabolizedPerHour,
  List<Session>? sessions,
}) async {
  final Profile profile = getProfile(
    id: id,
    name: name,
    bodyWeight: bodyWeight,
    bodyWaterPercentage: bodyWaterPercentage,
    absorptionTime: absorptionTime,
    perMilMetabolizedPerHour: perMilMetabolizedPerHour,
    sessions: sessions,
  );

  profile.id = await db_utils.insertProfile(profile);

  return profile;
}

Profile getProfile({
  int? id,
  String? name,
  Mass? bodyWeight,
  Percent? bodyWaterPercentage,
  Duration? absorptionTime,
  double? perMilMetabolizedPerHour,
  List<Session>? sessions,
}) {
  final Profile profile = Profile(
    name: name ?? 'Profile',
    bodyWeight: bodyWeight ?? Mass.units(kilos: 75),
    bodyWaterPercentage: bodyWaterPercentage ?? Percent.fromPercent(60),
    absorptionTime: absorptionTime ?? Duration(hours: 1),
    perMilMetabolizedPerHour: perMilMetabolizedPerHour ?? 0.15,
  );
  profile.id = id;
  profile.sessions = sessions;

  return profile;
}

Future<Session> insertSession({
  int? id,
  int? profileId,
  String? name,
  DateTime? startedAt,
  DateTime? endedAt,
  Profile? profile,
  List<Drink>? drinks,
}) async {
  Profile? relProfile;

  if (profileId == null) {
    relProfile = profile ?? getProfile();
    await db_utils.insertProfile(relProfile);
  }

  final int? relProfileId = relProfile?.id ?? profileId;

  final Session session = getSession(
    id: id,
    profileId:
        relProfileId == null ? null : (relProfileId > 0 ? relProfileId : null),
    name: name,
    startedAt: startedAt,
    endedAt: endedAt,
    profile: relProfile ?? profile,
    drinks: drinks,
  );

  session.id = await db_utils.insertSession(session);

  return session;
}

Session getSession({
  int? id,
  int? profileId,
  String? name,
  DateTime? startedAt,
  DateTime? endedAt,
  Profile? profile,
  List<Drink>? drinks,
}) {
  final DateTime dateTime = test_utils.getDateTime();

  final Session session = Session(
    profileId: profileId,
    name: name ?? 'Session',
    startedAt: startedAt ?? dateTime.subtract(Duration(hours: 1)),
    endedAt: endedAt ?? dateTime,
  );
  session.id = id;
  session.profile = profile;
  session.drinks = drinks;

  return session;
}

Future<Preferences> insertPreferences({
  int? id,
  int? activeSessionId,
  int? activeProfileId,
  String? drinkWebHook,
  Session? activeSession,
  Profile? activeProfile,
}) async {
  Session? relSession;
  Profile? relProfile;

  if (activeSessionId == null) {
    relSession = relSession ?? getSession();
    await db_utils.insertSession(relSession);
  }
  if (activeProfileId == null) {
    relProfile = relProfile ?? getProfile();
    await db_utils.insertProfile(relProfile);
  }

  final int? relSessionId = relSession?.id ?? activeSessionId;
  final int? relProfileId = relProfile?.id ?? activeProfileId;

  final Preferences preferences = getPreferences(
    id: id,
    activeSessionId:
        relSessionId == null ? null : (relSessionId > 0 ? relSessionId : null),
    activeProfileId:
        relProfileId == null ? null : (relProfileId > 0 ? relProfileId : null),
    drinkWebHook: drinkWebHook,
    activeSession: relSession ?? activeSession,
    activeProfile: relProfile ?? activeProfile,
  );

  preferences.id = await db_utils.insertPreferences(preferences);

  return preferences;
}

Preferences getPreferences({
  int? id,
  int? activeSessionId,
  int? activeProfileId,
  String? drinkWebHook,
  Session? activeSession,
  Profile? activeProfile,
}) {
  final Preferences preferences = Preferences(
    activeSessionId: activeSessionId,
    activeProfileId: activeProfileId,
    drinkWebHook: drinkWebHook ?? 'webhook',
  );
  preferences.id = id;
  preferences.activeSession = activeSession;
  preferences.activeProfile = activeProfile;

  return preferences;
}
