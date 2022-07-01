import 'package:count_me_down/database/db_utils.dart';
import 'package:count_me_down/database/repos/idb/preferences_idb_repo.dart'
    as idb;
import 'package:count_me_down/database/repos/sqf/preferences_sqf_repo.dart'
    as sqf;
import 'package:count_me_down/models/preferences.dart';

Future<Preferences> getPreferences({List<String>? preloadArgs}) async {
  if (useSqfLiteDb) {
    return sqf.getPreferences(preloadArgs: preloadArgs);
  } else {
    return idb.getPreferences(preloadArgs: preloadArgs);
  }
}

Future<Preferences> updatePreferences(Preferences preferences) async {
  if (useSqfLiteDb) {
    return sqf.updatePreferences(preferences);
  } else {
    return idb.updatePreferences(preferences);
  }
}
