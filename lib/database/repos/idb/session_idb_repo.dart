import 'package:count_me_down/models/session.dart';

Future<Session?> getSession(int id, {List<String>? preloadArgs}) {
  throw UnimplementedError();
}

Future<List<Session>> getSessions({int? profileId, List<String>? preloadArgs}) {
  throw UnimplementedError();
}

Future<int> insertSession(Session session) {
  throw UnimplementedError();
}

Future<List<int>> insertSessions(List<Session> sessions) {
  throw UnimplementedError();
}

Future<int> updateSession(Session session, {bool insertMissing = false}) {
  throw UnimplementedError();
}

Future<List<int>> updateSessions(List<Session> sessions,
    {int? profileId, bool insertMissing = false, bool removeDeleted = false}) {
  throw UnimplementedError();
}

Future<int> deleteSession(Session session) {
  throw UnimplementedError();
}

Future<int> deleteSessions({int? profileId}) {
  throw UnimplementedError();
}
