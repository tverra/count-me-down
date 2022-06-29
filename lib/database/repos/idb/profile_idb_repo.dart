import 'package:count_me_down/database/db_utils.dart';
import 'package:count_me_down/database/repos/idb/session_idb_repo.dart';
import 'package:count_me_down/models/profile.dart';
import 'package:count_me_down/models/session.dart';
import 'package:idb_sqflite/idb_sqflite.dart';

Future<Profile?> getLatestProfile({List<String>? preloadArgs}) {
  throw UnimplementedError();
}

Future<Profile?> getProfile(int id, {List<String>? preloadArgs}) async {
  final Database db = await getIdb();
  final Transaction txn = db.transaction(Profile.tableName, idbModeReadOnly);
  final ObjectStore store = txn.objectStore(Profile.tableName);

  final Object? res = await store.getObject(id);
  await txn.completed;

  final Map<String, dynamic>? casted = castIdbResult(res);
  final Profile? profile = casted == null ? null : Profile.fromMap(casted);
  List<Session>? sessions;

  if (profile != null) {
    if (preloadArgs != null) {
      if (preloadArgs.contains(Profile.relSessions)) {
        sessions = await getSessions(profileId: profile.id);
      }
    }
  }

  profile?.sessions = sessions;
  return profile;
}

Future<List<Profile>> getProfiles({List<String>? preloadArgs}) async {
  final Database db = await getIdb();
  final Transaction txn = db.transaction(Profile.tableName, idbModeReadOnly);
  final ObjectStore store = txn.objectStore(Profile.tableName);

  final List<Object> res = await store.getAll();
  await txn.completed;

  final List<Map<String, dynamic>> casted = castIdbResultList(res);
  final List<Profile> profiles = <Profile>[];

  for (final Map<String, dynamic> profileMap in casted) {
    final Profile profile = Profile.fromMap(profileMap);

    List<Session>? sessions;

    if (preloadArgs != null) {
      if (preloadArgs.contains(Profile.relSessions)) {
        sessions = await getSessions(profileId: profile.id);
      }
    }

    profile.sessions = sessions;
    profiles.add(profile);
  }
  return profiles;
}

Future<Profile> insertProfile(Profile profile) async {
  final Database db = await getIdb();
  final Transaction txn = db.transaction(Profile.tableName, idbModeReadWrite);
  final ObjectStore store = txn.objectStore(Profile.tableName);

  await store.put(profile.toMap(forQuery: true), profile.id);
  await txn.completed;

  return profile;
}

Future<List<Profile>> insertProfiles(List<Profile> profiles) async {
  final Database db = await getIdb();
  final Transaction txn = db.transaction(Profile.tableName, idbModeReadWrite);
  final ObjectStore store = txn.objectStore(Profile.tableName);

  for (final Profile profile in profiles) {
    await store.put(profile.toMap(forQuery: true), profile.id);
  }
  await txn.completed;

  return profiles;
}

Future<Profile?> updateProfile(
  Profile profile, {
  bool insertMissing = false,
}) async {
  final Database db = await getIdb();
  final Transaction txn = db.transaction(Profile.tableName, idbModeReadWrite);
  final ObjectStore store = txn.objectStore(Profile.tableName);
  Profile? res;

  if (insertMissing) {
    await store.put(profile.toMap(forQuery: true), profile.id);
    res = profile;
  } else {
    final List<Object> keys = await store.getAllKeys();

    if (keys.contains(profile.id)) {
      await store.put(profile.toMap(forQuery: true), profile.id);
      res = profile;
    }
  }
  await txn.completed;
  return res;
}

Future<List<Profile>> updateProfiles(
  List<Profile> profiles, {
  bool insertMissing = false,
  bool removeDeleted = false,
}) async {
  final List<Profile> existing = await getProfiles();

  final Database db = await getIdb();
  final Transaction txn = db.transaction(Profile.tableName, idbModeReadWrite);
  final ObjectStore store = txn.objectStore(Profile.tableName);

  final List<Profile> res = <Profile>[];

  for (final Profile profile in profiles) {
    if (insertMissing) {
      await store.put(profile.toMap(forQuery: true), profile.id);
      res.add(profile);
    } else {
      if (existing.where((Profile c) => c.id == profile.id).isNotEmpty) {
        await store.put(profile.toMap(forQuery: true), profile.id);
        res.add(profile);
      }
    }
  }
  await txn.completed;

  if (removeDeleted) {
    for (final Profile profile in existing) {
      if (res.where((Profile c) => c.id == profile.id).isEmpty) {
        await deleteProfile(profile);
      }
    }
  }
  return res;
}

Future<int> deleteProfile(Profile profile) async {
  final Database db = await getIdb();
  final Transaction txn = db.transaction(Profile.tableName, idbModeReadWrite);
  final ObjectStore store = txn.objectStore(Profile.tableName);

  final List<Object> keys = await store.getAllKeys();

  if (!keys.contains(profile.id)) {
    return 0;
  }

  final int? profileId = profile.id;
  if (profileId != null) await store.delete(profileId);

  await txn.completed;
  return 1;
}

Future<int> deleteProfiles() async {
  final List<Profile> existing = await getProfiles();

  final Database db = await getIdb();
  final Transaction txn = db.transaction(Profile.tableName, idbModeReadWrite);
  final ObjectStore store = txn.objectStore(Profile.tableName);

  for (final Profile profile in existing) {
    final int? profileId = profile.id;
    if (profileId != null) await store.delete(profileId);
  }

  await txn.completed;
  return existing.length;
}
