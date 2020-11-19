import 'package:count_me_down/database/db_repo.dart';
import 'package:count_me_down/models/preferences.dart';
import 'package:count_me_down/models/session.dart';
import 'package:count_me_down/pages/create_session_page.dart';
import 'package:count_me_down/pages/session_page.dart';
import 'package:count_me_down/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SessionsPage extends StatefulWidget {
  static const routeName = '/sessions';

  @override
  _SessionsPageState createState() => _SessionsPageState();
}

class _SessionsPageState extends State<SessionsPage> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sessions')),
      body: Builder(builder: (BuildContext context) {
        return FutureBuilder(
          future: SessionRepo.getSessions(),
          builder:
              (BuildContext context, AsyncSnapshot<List<Session>> snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            return SafeArea(
              child: Stack(
                children: [
                  ListView.builder(
                      padding: const EdgeInsets.only(bottom: 100.0),
                      itemCount:
                          snapshot.data != null ? snapshot.data.length : 0,
                      itemBuilder: (BuildContext context, int index) {
                        final Session session = snapshot.data[index];

                        return Container(
                          padding: EdgeInsets.symmetric(vertical: 4.0),
                          child: Material(
                            elevation: 2.0,
                            child: FlatButton(
                              onPressed: _isLoading
                                  ? null
                                  : () => _openSession(context, session),
                              child: Container(
                                width: double.infinity,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 20.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      session.name,
                                      style: TextStyle(
                                        fontSize: 17.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      Utils.formatDatetime(session.startedAt),
                                      style: TextStyle(
                                        color: Colors.black45,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: SafeArea(
                      top: false,
                      right: false,
                      left: false,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 20.0),
                        child: RaisedButton(
                          color: Theme.of(context).primaryColor,
                          child: Container(
                            padding: const EdgeInsets.all(
                              15.0,
                            ),
                            child: Text(
                              'Start new session',
                              style: TextStyle(
                                color: Utils.getThemeTextColor(context),
                                fontSize: 17.0,
                              ),
                            ),
                          ),
                          onPressed: _isLoading
                              ? null
                              : () => _createNewSession(context),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }),
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
    await preferences.save();

    Navigator.of(context)
        .pushNamedAndRemoveUntil(SessionPage.routeName, (route) => false);
  }

  void _createNewSession(BuildContext context) {
    Navigator.of(context).pushNamed(CreateSessionPage.routeName);
  }
}
