import 'package:count_me_down/database/db_repos.dart';
import 'package:count_me_down/models/drink.dart';
import 'package:count_me_down/models/preferences.dart';
import 'package:count_me_down/models/session.dart';
import 'package:count_me_down/pages/create_drink_page.dart';
import 'package:count_me_down/pages/edit_drink_page.dart';
import 'package:count_me_down/pages/edit_session_page.dart';
import 'package:count_me_down/pages/scoreboard_page.dart';
import 'package:count_me_down/pages/start_page.dart';
import 'package:count_me_down/utils/snack_bar_helper.dart';
import 'package:count_me_down/utils/utils.dart' as utils;
import 'package:count_me_down/widgets/profile_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';

class SessionPage extends StatefulWidget {
  static const routeName = 'session';
  final bool template;

  SessionPage({this.template = false});

  @override
  _SessionPageState createState() => _SessionPageState();
}

class _SessionPageState extends State<SessionPage> {
  Session? _session;
  List<Drink>? _templates;

  @override
  void initState() {
    super.initState();
    _getTemplates();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Session'),
      ),
      drawer: _Drawer(enabled: !widget.template),
      body: Builder(builder: (BuildContext context) {
        return Center(
          child: FutureBuilder<Session?>(
            future: widget.template
                ? _getTemplateSession(context)
                : _getActiveSession(context),
            builder: (BuildContext context, AsyncSnapshot<Session?> snapshot) {
              final Session? session = snapshot.data;
              final List<Drink>? drinks = session?.drinks;
              final List<Drink>? templates = _templates;
              _session = snapshot.data;

              if (session == null || drinks == null) {
                return Center(child: CircularProgressIndicator());
              }

              return Stack(
                children: [
                  ListView.builder(
                      padding: EdgeInsets.only(
                        bottom: 140.0 + MediaQuery.of(context).padding.bottom,
                      ),
                      itemCount: drinks.length,
                      itemBuilder: (BuildContext context, int index) {
                        final Drink drink = drinks[index];
                        final DateTime? timestamp = drink.timestamp;

                        return GestureDetector(
                          onTap: () => _editDrink(context, drink),
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 4.0),
                            child: Material(
                              elevation: 2.0,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(20.0),
                                child: Row(
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          drink.name ?? '',
                                          style: TextStyle(
                                            fontSize: 17.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        widget.template
                                            ? Text(
                                                'vol: ${drink.volume.toString()}, alc: ${drink.alcoholConcentration.toString()}',
                                                style: TextStyle(
                                                  color: Colors.black45,
                                                ),
                                              )
                                            : timestamp != null
                                                ? Text(
                                                    utils.formatDatetime(
                                                        timestamp),
                                                    style: TextStyle(
                                                      color: Colors.black45,
                                                    ),
                                                  )
                                                : Container(),
                                      ],
                                    ),
                                    Spacer(),
                                    FaIcon(
                                      drink.iconData,
                                      size: 30.0,
                                      color: drink.color,
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
                      left: false,
                      right: false,
                      child: Container(
                        height: 140.0,
                        color: Colors.white.withOpacity(0.9),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          shrinkWrap: true,
                          padding: EdgeInsets.all(20.0),
                          itemCount:
                              templates != null ? templates.length + 1 : 1,
                          itemBuilder: (BuildContext context, int index) {
                            if (index == 0) {
                              return GestureDetector(
                                onTap: () => _createDrink(context),
                                child: Container(
                                  width: 100.0,
                                  color: Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.25),
                                  child: Icon(
                                    Icons.add,
                                    size: 40.0,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              );
                            }

                            final Drink? drink = templates?[index - 1];

                            if (drink == null) return Container();

                            return GestureDetector(
                              onTap: () => _addDrink(context, drink),
                              child: Container(
                                height: 100,
                                width: 100,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(
                                      drink.iconData,
                                      color: drink.color,
                                      size: 60.0,
                                    ),
                                    Spacer(),
                                    Text(drink.name ?? ''),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      }),
    );
  }

  void _editDrink(BuildContext context, Drink drink) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) {
        return EditDrinkPage(
          drink: drink,
          onEditDrink: () => setState(() {}),
        );
      }),
    );
  }

  void _createDrink(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) {
        return CreateDrinkPage(
          onCreateDrink: () => setState(() {
            _getTemplates();
          }),
        );
      }),
    );
  }

  Future<void> _addDrink(BuildContext context, Drink drink) async {
    final Drink newDrink = drink.copy();

    newDrink.id = null;
    newDrink.sessionId = _session?.id;
    newDrink.timestamp = DateTime.now();

    await insertDrink(newDrink);
    utils.drinkWebHook(context);
    setState(() {});
  }

  Future<void> _getTemplates() async {
    final List<Drink> templates = await getDrinkTemplates();

    setState(() {
      _templates = templates;
    });
  }

  Future<Session?> _getActiveSession(BuildContext context) async {
    final Preferences preferences = context.watch<Preferences>();

    return getSession(preferences.activeSessionId ?? 0,
        preloadArgs: [Session.relProfile, Session.relDrinks]);
  }

  Future<Session> _getTemplateSession(BuildContext context) async {
    final Session session = Session();
    session.drinks = await getDrinkTemplates();

    return session;
  }
}

class _Drawer extends StatelessWidget {
  final bool enabled;

  _Drawer({this.enabled = false});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            padding: EdgeInsets.zero,
            margin: EdgeInsets.zero,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: SingleChildScrollView(
              child: ProfileView(header: false),
            ),
          ),
          Divider(height: 1.0, color: Color.fromRGBO(0, 0, 0, 0.4)),
          FutureBuilder<PackageInfo>(
              future: PackageInfo.fromPlatform(),
              builder:
                  (BuildContext context, AsyncSnapshot<PackageInfo> snapshot) {
                final PackageInfo? data = snapshot.data;
                final String version = data != null ? data.version : '';

                return Container(
                  padding: const EdgeInsets.all(4.0),
                  child: Center(
                    child: Text(
                      'version: $version',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  color: Colors.grey[200],
                );
              }),
          ListTile(
            title: Text('Back to start page'),
            onTap: () async {
              final Preferences preferences = context.read<Preferences>();
              preferences.activeSessionId = null;
              updatePreferences(preferences);
              Navigator.of(context).pushNamedAndRemoveUntil(
                  StartPage.routeName, (route) => false);
            },
            leading: Icon(Icons.arrow_back),
          ),
          Divider(height: 1.0),
          ListTile(
            title: Text('Copy drink list'),
            onTap: () async {
              final Preferences preferences = context.read<Preferences>();
              final Session? session = await getSession(
                preferences.activeSessionId ?? 0,
                preloadArgs: [Session.relDrinks],
              );
              final StringBuffer buffer = StringBuffer();
              final List<Drink>? drinks = session?.drinks;
              drinks?.forEach((d) => buffer.write('${d.toString()}\n'));

              Clipboard.setData(ClipboardData(text: buffer.toString()))
                  .then((result) {
                SnackBarHelper().show(context, 'Kopiert til utklippstavle');
                Navigator.of(context).pop();
              });
            },
            leading: Icon(Icons.copy),
          ),
          Divider(height: 1.0),
          ListTile(
            title: Text('Edit session'),
            enabled: enabled,
            onTap: () async {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) {
                  return EditSessionPage();
                }),
              );
            },
            leading: Icon(Icons.edit),
          ),
          Divider(height: 1.0),
          ListTile(
            title: Text('Edit drink templates'),
            enabled: enabled,
            onTap: () async {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) {
                  return SessionPage(template: true);
                }),
              );
            },
            leading: Icon(Icons.edit),
          ),
          Divider(height: 1.0),
          ListTile(
            title: Text('Scoreboard'),
            enabled: enabled,
            onTap: () async {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) {
                  return ScoreboardPage();
                }),
              );
            },
            leading: Icon(Icons.leaderboard),
          ),
          Divider(height: 1.0),
        ],
      ),
    );
  }
}
