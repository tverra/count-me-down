import 'package:count_me_down/models/profile.dart';

Future<Profile?> getLatestProfile({List<String>? preloadArgs}) {
  throw UnimplementedError();
}

Future<Profile?> getProfile(int id, {List<String>? preloadArgs}) {
  throw UnimplementedError();
}

Future<List<Profile>> getProfiles({List<String>? preloadArgs}) {
  throw UnimplementedError();
}

Future<int> insertProfile(Profile profile) {
  throw UnimplementedError();
}

Future<List<int>> insertProfiles(List<Profile> profiles) {
  throw UnimplementedError();
}

Future<int> updateProfile(
  Profile profile, {
  bool insertMissing = false,
}) {
  throw UnimplementedError();
}

Future<List<int>> updateProfiles(
  List<Profile> profiles, {
  bool insertMissing = false,
  bool removeDeleted = false,
}) {
  throw UnimplementedError();
}

Future<int> deleteProfile(Profile profile) {
  throw UnimplementedError();
}

Future<int> deleteProfiles() {
  throw UnimplementedError();
}
