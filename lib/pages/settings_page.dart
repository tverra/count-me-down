import 'package:count_me_down/database/repos/preferences_repo.dart';
import 'package:count_me_down/models/preferences.dart';
import 'package:count_me_down/utils/utils.dart' as utils;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  static const String routeName = '/settings';

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  TextEditingController? _drinkHookController;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final Preferences preferences = context.watch<Preferences>();
    _drinkHookController ??=
        TextEditingController(text: preferences.drinkWebHook);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Container(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _drinkHookController,
                decoration: const InputDecoration(
                  hintText: 'Drink webhook',
                  helperText: 'POST-request for when adding drinks',
                ),
              ),
              const SizedBox(height: 40.0),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Theme.of(context).primaryColor,
                ),
                onPressed: _isLoading ? null : () => _submit(context),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15.0),
                  child: Center(
                    child: Text(
                      'Done',
                      style: TextStyle(
                        fontSize: 17.0,
                        fontWeight: FontWeight.bold,
                        color: utils.getThemeTextColor(context),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit(BuildContext context) async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    final Preferences preferences = context.read<Preferences>();
    preferences.drinkWebHook = _drinkHookController?.text;
    await updatePreferences(preferences);

    setState(() {
      Navigator.of(context).pop();
    });
  }
}
