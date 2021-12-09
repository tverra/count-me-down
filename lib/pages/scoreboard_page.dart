import 'dart:convert';

import 'package:count_me_down/models/preferences.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class ScoreboardPage extends StatefulWidget {
  ScoreboardPage();

  @override
  _ScoreboardPageState createState() => _ScoreboardPageState();
}

class _ScoreboardPageState extends State<ScoreboardPage> {
  Stream _getScoreboardStream;
  String _title = 'Scoreboard';

  @override
  void initState() {
    _getScoreboardStream = _getScoreboard();

    super.initState();
  }

  @override
  void dispose() {
    _getScoreboardStream = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
      ),
      body: StreamBuilder<List>(
          initialData: [],
          stream: _getScoreboardStream,
          builder: (
            BuildContext context,
            AsyncSnapshot<List> snapshot,
          ) {
            final List users = snapshot.data != null ? snapshot.data : null;

            return Container(
              width: double.infinity,
              child: _Scoreboard(users: users),
            );
          }),
    );
  }

  Stream<List> _getScoreboard() async* {
    final Preferences preferences = context.read<Preferences>();
    final Map<String, String> headers = <String, String>{
      'Accept': 'application/json',
    };

    for (; mounted && preferences.drinkWebHook != null;) {
      final http.Response response = await http.get(
        preferences.drinkWebHook,
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        setState(() {
          _title = data['title'];
        });

        yield data['scoreboard'];
      }

      await Future<void>.delayed(Duration(seconds: 30));
    }
  }
}

class _Scoreboard extends StatelessWidget {
  final List users;

  _Scoreboard({@required this.users});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double columnWidth =
        (screenWidth / 3) > 100 ? 100 : (screenWidth / 3);

    final List<Widget> rows = users != null
        ? users.map((user) {
            final StringBuffer buffer = StringBuffer();
            final Map<String, dynamic> units = user['units'];

            for (int i = 0; i < units.length; i++) {
              if (i > 0) buffer.write(', ');

              buffer.write(units.keys.elementAt(i) +
                  ' (' +
                  units[units.keys.elementAt(i)].toString() +
                  ')');
            }

            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    children: <Widget>[
                      SizedBox(
                        width: columnWidth,
                        child: Text(
                          user['username'],
                        ),
                      ),
                      SizedBox(
                        width: columnWidth,
                        child: Text(
                          user['per_mille'],
                        ),
                      ),
                      Flexible(
                        child: Text(
                          buffer.toString(),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(
                  thickness: 1,
                ),
              ],
            );
          }).toList()
        : [];

    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 10.0, right: 20.0, left: 20.0),
          child: Row(
            children: [
              SizedBox(
                width: columnWidth,
                child: Text(
                  'Name',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(
                width: columnWidth,
                child: Text(
                  'Per mil',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                'Units',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Divider(
          thickness: 1,
        ),
      ]..addAll(rows),
    );
  }
}
