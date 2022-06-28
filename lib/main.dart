import 'package:count_me_down/database/repos/preferences_repo.dart';
import 'package:count_me_down/models/preferences.dart';
import 'package:count_me_down/pages/create_session_page.dart';
import 'package:count_me_down/pages/profile_page.dart';
import 'package:count_me_down/pages/scoreboard_page.dart';
import 'package:count_me_down/pages/session_page.dart';
import 'package:count_me_down/pages/sessions_page.dart';
import 'package:count_me_down/pages/settings_page.dart';
import 'package:count_me_down/pages/start_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final Preferences preferences = await getPreferences();

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
          // Hot 'n Sweet blå
          primaryColor: Color.fromRGBO(1, 12, 142, 1),
          // Jägermeister grønn
          // primaryColor: Color.fromRGBO(11, 38, 16, 1),
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute: preferences.activeSessionId == null ? '/' : 'session',
        routes: {
          '/': (_) => StartPage(),
          '/settings': (_) => SettingsPage(),
          '/sessions': (_) => SessionsPage(),
          '/sessions/createSession': (_) => CreateSessionPage(),
          '/scoreboard': (_) => ScoreboardPage(),
          '/profile': (_) => ProfilePage(),
          'session': (_) => SessionPage(),
        },
        onGenerateRoute: (RouteSettings settings) {
          return null;
        });
  }
}
