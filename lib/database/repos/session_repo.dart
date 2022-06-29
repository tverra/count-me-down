import 'package:count_me_down/database/db_utils.dart';
import 'package:count_me_down/database/repos/idb/session_idb_repo.dart' as idb;
import 'package:count_me_down/database/repos/sqf/session_sqf_repo.dart' as sqf;
import 'package:count_me_down/models/session.dart';

Future<Session?> getSession(int id, {List<String>? preloadArgs}) {
  if (useSqfLiteDb) {
    return sqf.getSession(id, preloadArgs: preloadArgs);
  } else {
    return idb.getSession(id, preloadArgs: preloadArgs);
  }
}

Future<List<Session>> getSessions({int? profileId, List<String>? preloadArgs}) {
  if (useSqfLiteDb) {
    return sqf.getSessions(profileId: profileId, preloadArgs: preloadArgs);
  } else {
    return idb.getSessions(profileId: profileId, preloadArgs: preloadArgs);
  }
}

Future<Session> insertSession(Session session) {
  if (useSqfLiteDb) {
    return sqf.insertSession(session);
  } else {
    return idb.insertSession(session);
  }
}

Future<List<Session>> insertSessions(List<Session> sessions) {
  if (useSqfLiteDb) {
    return sqf.insertSessions(sessions);
  } else {
    return idb.insertSessions(sessions);
  }
}

Future<Session?> updateSession(Session session, {bool insertMissing = false}) {
  if (useSqfLiteDb) {
    return sqf.updateSession(session, insertMissing: insertMissing);
  } else {
    return idb.updateSession(session, insertMissing: insertMissing);
  }
}

Future<List<Session>> updateSessions(List<Session> sessions,
    {int? profileId, bool insertMissing = false, bool removeDeleted = false}) {
  if (useSqfLiteDb) {
    return sqf.updateSessions(sessions,
        profileId: profileId,
        insertMissing: insertMissing,
        removeDeleted: removeDeleted);
  } else {
    return idb.updateSessions(sessions,
        profileId: profileId,
        insertMissing: insertMissing,
        removeDeleted: removeDeleted);
  }
}

Future<int> deleteSession(Session session) {
  if (useSqfLiteDb) {
    return sqf.deleteSession(session);
  } else {
    return idb.deleteSession(session);
  }
}

Future<int> deleteSessions({int? profileId}) {
  if (useSqfLiteDb) {
    return sqf.deleteSessions(profileId: profileId);
  } else {
    return idb.deleteSessions(profileId: profileId);
  }
}
