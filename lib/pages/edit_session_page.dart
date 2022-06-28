import 'package:count_me_down/database/db_repos.dart';
import 'package:count_me_down/models/preferences.dart';
import 'package:count_me_down/models/session.dart';
import 'package:count_me_down/pages/start_page.dart';
import 'package:count_me_down/utils/utils.dart' as utils;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditSessionPage extends StatelessWidget {
  EditSessionPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit session'),
      ),
      body: Container(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: FutureBuilder<Session?>(
              future: _getSession(context),
              builder:
                  (BuildContext context, AsyncSnapshot<Session?> snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final Session? session = snapshot.data;

                return Container(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Theme.of(context).primaryColor,
                    ),
                    onPressed: session != null
                        ? () => _deleteSession(context, session)
                        : null,
                    child: Container(
                      padding: const EdgeInsets.all(15.0),
                      child: Text(
                        'Delete session',
                        style: TextStyle(
                            color: utils.getThemeTextColor(context),
                            fontSize: 18.0),
                      ),
                    ),
                  ),
                );
              }),
        ),
      ),
    );
  }

  Future<Session?> _getSession(BuildContext context) async {
    final Preferences preferences = context.watch<Preferences>();
    return getSession(preferences.activeSessionId ?? 0);
  }

  Future<void> _deleteSession(BuildContext context, Session session) async {
    await deleteSession(session);
    Navigator.of(context)
        .pushNamedAndRemoveUntil(StartPage.routeName, (route) => false);
  }
}
