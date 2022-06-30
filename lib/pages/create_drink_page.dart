import 'package:count_me_down/database/db_repos.dart';
import 'package:count_me_down/models/drink.dart';
import 'package:count_me_down/models/preferences.dart';
import 'package:count_me_down/utils/percent.dart';
import 'package:count_me_down/utils/utils.dart' as utils;
import 'package:count_me_down/utils/volume.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CreateDrinkPage extends StatefulWidget {
  final VoidCallback? onCreateDrink;

  const CreateDrinkPage({this.onCreateDrink});

  @override
  _CreateDrinkPageState createState() => _CreateDrinkPageState();
}

class _CreateDrinkPageState extends State<CreateDrinkPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _volumeController = TextEditingController();
  final TextEditingController _alcoholConcentrationController =
      TextEditingController();
  final bool _isLoading = false;
  bool _addToTemplate = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add drink'),
      ),
      body: Builder(
        builder: (BuildContext context) {
          return Container(
            padding: const EdgeInsets.all(20.0),
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  child: Form(
                    child: Column(
                      children: <Widget>[
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                              hintText: 'Name',
                              helperText: 'The name of the drink',),
                        ),
                        TextFormField(
                          controller: _volumeController,
                          keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            hintText: 'Volume',
                            helperText: 'Volume in centilitres',
                          ),
                        ),
                        TextFormField(
                          controller: _alcoholConcentrationController,
                          keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            hintText: 'Alcohol content',
                            helperText: 'Alcohol content in percentage',
                          ),
                        ),
                        const SizedBox(height: 20.0),
                        CheckboxListTile(
                          title: const Text("Add drink to templates"),
                          contentPadding: EdgeInsets.zero,
                          value: _addToTemplate,
                          onChanged: (bool? newValue) {
                            if (newValue != null && mounted) {
                              setState(() {
                                _addToTemplate = newValue;
                              });
                            }
                          },
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
                                'Add',
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
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _submit(BuildContext context) async {
    final Preferences preferences = context.read<Preferences>();

    final String volume = _volumeController.text.replaceAll(',', '.');
    final String alcoholConcentration =
        _alcoholConcentrationController.text.replaceAll(',', '.');
    final double volumeDouble = double.tryParse(volume) ?? 0;
    final double alcoholDouble = double.tryParse(alcoholConcentration) ?? 0;

    if (_addToTemplate) {
      final Drink template = Drink(
        name: _nameController.text,
        volume: Volume((volumeDouble * 10).toInt()),
        alcoholConcentration: Percent.fromPercent(alcoholDouble),
        timestamp: DateTime.now(),
        color: Colors.black,
        drinkType: DrinkTypes.glassWhiskey,
      );

      await insertDrink(template);
    }

    final Drink drink = Drink(
      sessionId: preferences.activeSessionId,
      name: _nameController.text,
      volume: Volume((volumeDouble * 10).toInt()),
      alcoholConcentration: Percent.fromPercent(alcoholDouble),
      timestamp: DateTime.now(),
      color: Colors.black,
      drinkType: DrinkTypes.glassWhiskey,
    );

    await insertDrink(drink);
    utils.drinkWebHook(context);

    final VoidCallback? onCreateDrink = widget.onCreateDrink;

    if (onCreateDrink != null) {
      onCreateDrink();
    }
    Navigator.of(context).pop();
  }
}
