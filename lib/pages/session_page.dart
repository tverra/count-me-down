import 'package:count_me_down/database/db_repo.dart';
import 'package:count_me_down/models/drink.dart';
import 'package:count_me_down/models/preferences.dart';
import 'package:count_me_down/models/session.dart';
import 'package:count_me_down/pages/create_drink_page.dart';
import 'package:count_me_down/pages/edit_drink_page.dart';
import 'package:count_me_down/pages/edit_session_page.dart';
import 'package:count_me_down/pages/start_page.dart';
import 'package:count_me_down/utils/snack_bar_helper.dart';
import 'package:count_me_down/utils/utils.dart';
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
  Session _session;
  List<Drink> _templates;

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
          child: FutureBuilder<Session>(
            future: widget.template
                ? _getTemplateSession(context)
                : _getActiveSession(context),
            builder: (BuildContext context, AsyncSnapshot<Session> snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              final Session session = snapshot.data;
              _session = snapshot.data;

              return Stack(
                children: [
                  ListView.builder(
                      padding: EdgeInsets.only(
                        bottom: 140.0 + MediaQuery.of(context).padding.bottom,
                      ),
                      itemCount:
                          session.drinks != null ? session.drinks.length : 0,
                      itemBuilder: (BuildContext context, int index) {
                        final Drink drink = session.drinks[index];

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
                                          drink.name,
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
                                            : drink.timestamp != null
                                                ? Text(
                                                    Utils.formatDatetime(
                                                        drink.timestamp),
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
                              _templates != null ? _templates.length + 1 : 1,
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

                            final Drink drink = _templates[index - 1];

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
                                    Text(
                                      drink.name,
                                    ),
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
    newDrink.sessionId = _session.id;
    newDrink.timestamp = DateTime.now();

    await DrinkRepo.insertDrink(newDrink);
    Utils.drinkWebHook(context);
    setState(() {});
  }

  Future<void> _getTemplates() async {
    final List<Drink> templates = await DrinkRepo.getDrinkTemplates();

    setState(() {
      _templates = templates;
    });
  }

  Future<Session> _getActiveSession(BuildContext context) async {
    final Preferences preferences = context.watch<Preferences>();

    return SessionRepo.getSession(preferences.activeSessionId,
        preloadArgs: [Session.relProfile, Session.relDrinks]);
  }

  Future<Session> _getTemplateSession(BuildContext context) async {
    final Session session = Session();
    session.drinks = await DrinkRepo.getDrinkTemplates();

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
                final String version =
                    snapshot.hasData ? snapshot.data.version : '';

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
              preferences.save();
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
              final Session session = await SessionRepo.getSession(
                preferences.activeSessionId,
                preloadArgs: [Session.relDrinks],
              );
              final StringBuffer buffer = StringBuffer();
              session.drinks.forEach((d) => buffer.write('${d.toString()}\n'));

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
        ],
      ),
    );
  }
}
