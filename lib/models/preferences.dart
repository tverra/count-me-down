import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  int activeSessionId;
  int activeProfileId;
  String drinkWebHook;

  Preferences({this.activeSessionId, this.activeProfileId, this.drinkWebHook});

  Preferences.fromJson(String json) {
    final Map<String, dynamic> parsed = jsonDecode(json);

    activeSessionId = parsed['activeSessionId'];
    activeProfileId = parsed['activeProfileId'];
    drinkWebHook = parsed['drinkWebHook'];
  }

  Preferences.initialValues() {
    activeProfileId = 1;
  }

  String toJson() {
    final Map<String, dynamic> map = {
      'activeSessionId': activeSessionId,
      'activeProfileId': activeProfileId,
      'drinkWebHook': drinkWebHook,
    };

    return jsonEncode(map);
  }

  Future<bool> save() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();

    return sharedPreferences.setString('preferences', toJson());
  }
}
