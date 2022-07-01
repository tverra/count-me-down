import 'dart:convert';

import 'package:count_me_down/models/preferences.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class ScoreboardPage extends StatefulWidget {
  static const String routeName = '/scoreboard';

  const ScoreboardPage();

  @override
  _ScoreboardPageState createState() => _ScoreboardPageState();
}

class _ScoreboardPageState extends State<ScoreboardPage> {
  Stream<List<dynamic>>? _getScoreboardStream;
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
    if (_getScoreboardStream == null) return const CircularProgressIndicator();

    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
      ),
      body: StreamBuilder<List<dynamic>>(
        initialData: const <dynamic>[],
        stream: _getScoreboardStream,
        builder: (
          BuildContext context,
          AsyncSnapshot<List<dynamic>> snapshot,
        ) {
          final List<dynamic>? users = snapshot.data;

          return SizedBox(
            width: double.infinity,
            child: _Scoreboard(users: users),
          );
        },
      ),
    );
  }

  Stream<List<dynamic>> _getScoreboard() async* {
    final Preferences preferences = context.read<Preferences>();
    final Map<String, String> headers = <String, String>{
      'Accept': 'application/json',
    };

    for (; mounted && preferences.drinkWebHook != null;) {
      final http.Response response = await http.get(
        Uri.parse(preferences.drinkWebHook ?? ''),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
            jsonDecode(response.body) as Map<String, dynamic>;

        setState(() {
          _title = data['title'] as String;
        });

        yield data['scoreboard'] as List<dynamic>;
      }

      await Future<void>.delayed(const Duration(seconds: 30));
    }
  }
}

class _Scoreboard extends StatelessWidget {
  final List<dynamic>? users;

  const _Scoreboard({required this.users});

  @override
  Widget build(BuildContext context) {
    final List<dynamic>? users = this.users;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double columnWidth =
        (screenWidth / 3) > 100 ? 100 : (screenWidth / 3);

    final List<Widget> rows = users != null
        ? users.map((dynamic u) {
            final Map<String, dynamic> user = u as Map<String, dynamic>;
            final StringBuffer buffer = StringBuffer();
            final Map<String, dynamic> units =
                user['units'] as Map<String, dynamic>;

            for (int i = 0; i < units.length; i++) {
              if (i > 0) buffer.write(', ');

              buffer.write(
                '${units.keys.elementAt(i)} '
                '(${units[units.keys.elementAt(i)].toString()} )',
              );
            }

            return Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    children: <Widget>[
                      SizedBox(
                        width: columnWidth,
                        child: Text(
                          user['username'] as String,
                        ),
                      ),
                      SizedBox(
                        width: columnWidth,
                        child: Text(
                          user['per_mille'] as String,
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
                const Divider(
                  thickness: 1,
                ),
              ],
            );
          }).toList()
        : <Widget>[];

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 10.0, right: 20.0, left: 20.0),
          child: Row(
            children: <Widget>[
              SizedBox(
                width: columnWidth,
                child: const Text(
                  'Name',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(
                width: columnWidth,
                child: const Text(
                  'Per mil',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Text(
                'Units',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const Divider(
          thickness: 1,
        ),
        ...rows,
      ],
    );
  }
}
