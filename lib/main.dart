import 'package:count_me_down/database/repos/preferences_repo.dart';
import 'package:count_me_down/models/preferences.dart';
import 'package:count_me_down/pages/create_session_page.dart';
import 'package:count_me_down/pages/graph_page.dart';
import 'package:count_me_down/pages/profile_page.dart';
import 'package:count_me_down/pages/scoreboard_page.dart';
import 'package:count_me_down/pages/session_page.dart';
import 'package:count_me_down/pages/sessions_page.dart';
import 'package:count_me_down/pages/settings_page.dart';
import 'package:count_me_down/pages/start_page.dart';
import 'package:count_me_down/styles.dart' as styles;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Preferences preferences = await getPreferences();

  while (preferences.id == null) {
    await Future<void>.delayed(const Duration(milliseconds: 100));

    preferences = await getPreferences();
  }

  runApp(
    Provider<Preferences>(
      create: (_) => preferences,
      child: CountMeDownApp(),
    ),
  );
}

class CountMeDownApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Preferences preferences = context.watch<Preferences>();

    return MaterialApp(
      theme: ThemeData(
        primarySwatch: styles.colorToMaterialColor(styles.hotNSweetBlue),
        appBarTheme: const AppBarTheme(backgroundColor: styles.hotNSweetBlue),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: preferences.activeSessionId == null ? '/' : 'session',
      routes: <String, Widget Function(BuildContext)>{
        '/': (_) => StartPage(),
        '/settings': (_) => SettingsPage(),
        '/sessions': (_) => SessionsPage(),
        '/sessions/createSession': (_) => CreateSessionPage(),
        '/scoreboard': (_) => const ScoreboardPage(),
        '/graph': (_) => const GraphPage(),
        '/profile': (_) => const ProfilePage(),
        'session': (_) => const SessionPage(),
      },
      onGenerateRoute: (RouteSettings settings) {
        return null;
      },
    );
  }
}
