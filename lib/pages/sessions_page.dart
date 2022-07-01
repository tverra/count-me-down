import 'package:count_me_down/database/db_repos.dart';
import 'package:count_me_down/models/preferences.dart';
import 'package:count_me_down/models/session.dart';
import 'package:count_me_down/pages/create_session_page.dart';
import 'package:count_me_down/pages/session_page.dart';
import 'package:count_me_down/utils/utils.dart' as utils;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SessionsPage extends StatefulWidget {
  static const String routeName = '/sessions';

  @override
  _SessionsPageState createState() => _SessionsPageState();
}

class _SessionsPageState extends State<SessionsPage> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sessions')),
      body: Builder(
        builder: (BuildContext context) {
          return FutureBuilder<List<Session>>(
            future: getSessions(),
            builder:
                (BuildContext context, AsyncSnapshot<List<Session>> snapshot) {
              final List<Session>? data = snapshot.data;

              if (data == null) {
                return const Center(child: CircularProgressIndicator());
              }

              return Stack(
                children: <Widget>[
                  ListView.builder(
                    padding: EdgeInsets.only(
                      bottom: 80.0 + MediaQuery.of(context).padding.bottom,
                    ),
                    itemCount: data.length,
                    itemBuilder: (BuildContext context, int index) {
                      final Session session = data[index];
                      final DateTime? startedAt = session.startedAt;

                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Material(
                          elevation: 2.0,
                          child: TextButton(
                            onPressed: _isLoading
                                ? null
                                : () => _openSession(context, session),
                            child: Container(
                              width: double.infinity,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    session.name ?? '',
                                    style: const TextStyle(
                                      fontSize: 17.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (startedAt != null)
                                    Text(
                                      utils.formatDatetime(startedAt),
                                      style: const TextStyle(
                                        color: Colors.black45,
                                      ),
                                    )
                                  else
                                    Container(),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: SafeArea(
                      top: false,
                      right: false,
                      left: false,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 10.0,
                          horizontal: 20.0,
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Theme.of(context).primaryColor,
                          ),
                          onPressed: _isLoading
                              ? null
                              : () => _createNewSession(context),
                          child: Container(
                            padding: const EdgeInsets.all(
                              15.0,
                            ),
                            child: Text(
                              'Start new session',
                              style: TextStyle(
                                color: utils.getThemeTextColor(context),
                                fontSize: 17.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _openSession(BuildContext context, Session session) async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    final Preferences preferences = context.read<Preferences>();
    preferences.activeSessionId = session.id;
    await updatePreferences(preferences);

    setState(() {
      Navigator.of(context).pushNamedAndRemoveUntil(
        SessionPage.routeName,
        (Route<dynamic> route) => false,
      );
    });
  }

  void _createNewSession(BuildContext context) {
    Navigator.of(context).pushNamed(CreateSessionPage.routeName);
  }
}
