import 'package:count_me_down/models/preferences.dart';
import 'package:count_me_down/pages/create_session_page.dart';
import 'package:count_me_down/pages/session_page.dart';
import 'package:count_me_down/pages/sessions_page.dart';
import 'package:count_me_down/pages/settings_page.dart';
import 'package:count_me_down/pages/start_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final SharedPreferences sharedPreferences =
      await SharedPreferences.getInstance();
  final String preferencesJson = sharedPreferences.getString('preferences');
  final Preferences preferences = preferencesJson != null
      ? Preferences.fromJson(preferencesJson)
      : Preferences.initialValues();

  runApp(Provider(
    create: (_) => preferences,
    child: CountMeDownApp(),
  ));
}

class CountMeDownApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Preferences preferences = context.watch<Preferences>();

    return MaterialApp(
        theme: ThemeData(
          // Tyrkisk pepper blå
          primaryColor: Color.fromRGBO(1, 12, 142, 1),
          // Jäger grønn
          // primaryColor: Color.fromRGBO(11, 38, 16, 1),
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute: preferences.activeSessionId == null ? '/' : 'session',
        routes: {
          '/': (_) => StartPage(),
          '/settings': (_) => SettingsPage(),
          '/sessions': (_) => SessionsPage(),
          '/sessions/createSession': (_) => CreateSessionPage(),
          'session': (_) => SessionPage(),
        },
        onGenerateRoute: (RouteSettings settings) {
          return null;
        });
  }
}
