import 'package:count_me_down/database/db_utils.dart';
import 'package:count_me_down/database/repos/idb/profile_idb_repo.dart' as idb;
import 'package:count_me_down/database/repos/sqf/profile_sqf_repo.dart' as sqf;
import 'package:count_me_down/models/profile.dart';

Future<Profile?> getLatestProfile({List<String>? preloadArgs}) {
  if (useSqfLiteDb) {
    return sqf.getLatestProfile(preloadArgs: preloadArgs);
  } else {
    return idb.getLatestProfile(preloadArgs: preloadArgs);
  }
}

Future<Profile?> getProfile(int id, {List<String>? preloadArgs}) {
  if (useSqfLiteDb) {
    return sqf.getProfile(id, preloadArgs: preloadArgs);
  } else {
    return idb.getProfile(id, preloadArgs: preloadArgs);
  }
}

Future<List<Profile>> getProfiles({List<String>? preloadArgs}) {
  if (useSqfLiteDb) {
    return sqf.getProfiles(preloadArgs: preloadArgs);
  } else {
    return idb.getProfiles(preloadArgs: preloadArgs);
  }
}

Future<Profile> insertProfile(Profile profile) {
  if (useSqfLiteDb) {
    return sqf.insertProfile(profile);
  } else {
    return idb.insertProfile(profile);
  }
}

Future<List<Profile>> insertProfiles(List<Profile> profiles) {
  if (useSqfLiteDb) {
    return sqf.insertProfiles(profiles);
  } else {
    return idb.insertProfiles(profiles);
  }
}

Future<Profile?> updateProfile(
  Profile profile, {
  bool insertMissing = false,
}) {
  if (useSqfLiteDb) {
    return sqf.updateProfile(profile, insertMissing: insertMissing);
  } else {
    return idb.updateProfile(profile, insertMissing: insertMissing);
  }
}

Future<List<Profile>> updateProfiles(
  List<Profile> profiles, {
  bool insertMissing = false,
  bool removeDeleted = false,
}) {
  if (useSqfLiteDb) {
    return sqf.updateProfiles(profiles,
        insertMissing: insertMissing, removeDeleted: removeDeleted);
  } else {
    return idb.updateProfiles(profiles,
        insertMissing: insertMissing, removeDeleted: removeDeleted);
  }
}

Future<int> deleteProfile(Profile profile) {
  if (useSqfLiteDb) {
    return sqf.deleteProfile(profile);
  } else {
    return idb.deleteProfile(profile);
  }
}

Future<int> deleteProfiles() {
  if (useSqfLiteDb) {
    return sqf.deleteProfiles();
  } else {
    return idb.deleteProfiles();
  }
}
