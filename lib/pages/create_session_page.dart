import 'package:count_me_down/database/db_repo.dart';
import 'package:count_me_down/models/preferences.dart';
import 'package:count_me_down/models/session.dart';
import 'package:count_me_down/pages/session_page.dart';
import 'package:count_me_down/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CreateSessionPage extends StatefulWidget {
  static const routeName = '/sessions/createSession';

  @override
  _CreateSessionPageState createState() => _CreateSessionPageState();
}

class _CreateSessionPageState extends State<CreateSessionPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Start new session'),
      ),
      body: Builder(builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20.0),
          child: Center(
              child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _nameController,
                    autofocus: true,
                    decoration: InputDecoration(hintText: 'Session name'),
                  ),
                  SizedBox(height: 40.0),
                  Container(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Theme.of(context).primaryColor,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(
                          15.0,
                        ),
                        child: Text(
                          'Start session',
                          style: TextStyle(
                            color: Utils.getThemeTextColor(context),
                            fontSize: 17.0,
                          ),
                        ),
                      ),
                      onPressed: () => _createNewSession(context),
                    ),
                  )
                ],
              ),
            ),
          )),
        );
      }),
    );
  }

  Future<void> _createNewSession(BuildContext context) async {
    if (!_formKey.currentState.validate()) {
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    final Preferences preferences = context.read<Preferences>();

    final Session session = Session(
      profileId: preferences.activeProfileId,
      name: _nameController.text,
      startedAt: DateTime.now(),
    );

    await SessionRepo.insertSession(session);
    preferences.activeSessionId = session.id;
    await preferences.save();

    Navigator.of(context)
        .pushNamedAndRemoveUntil(SessionPage.routeName, (route) => false);

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
