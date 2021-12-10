import 'package:count_me_down/database/db_repo.dart';
import 'package:count_me_down/models/drink.dart';
import 'package:count_me_down/models/preferences.dart';
import 'package:count_me_down/utils/percentage.dart';
import 'package:count_me_down/utils/utils.dart';
import 'package:count_me_down/utils/volume.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CreateDrinkPage extends StatefulWidget {
  final VoidCallback onCreateDrink;

  CreateDrinkPage({this.onCreateDrink});

  @override
  _CreateDrinkPageState createState() => _CreateDrinkPageState();
}

class _CreateDrinkPageState extends State<CreateDrinkPage> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _volumeController = TextEditingController();
  TextEditingController _alcoholConcentrationController =
      TextEditingController();
  bool _isLoading = false;
  bool _addToTemplate = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add drink'),
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
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                              hintText: 'Name',
                              helperText: 'The name of the drink'),
                        ),
                        TextFormField(
                          controller: _volumeController,
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            hintText: 'Volume',
                            helperText: 'Volume in centilitres',
                          ),
                        ),
                        TextFormField(
                          controller: _alcoholConcentrationController,
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            hintText: 'Alcohol content',
                            helperText: 'Alcohol content in percentage',
                          ),
                        ),
                        SizedBox(height: 20.0),
                        CheckboxListTile(
                          title: Text("Add drink to templates"),
                          contentPadding: const EdgeInsets.all(0),
                          value: _addToTemplate,
                          onChanged: (bool newValue) {
                            setState(() {
                              _addToTemplate = newValue;
                            });
                          },
                        ),
                        SizedBox(height: 40.0),
                        RaisedButton(
                          color: Theme.of(context).primaryColor,
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
                                  color: Utils.getThemeTextColor(context),
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
    final double volumeDouble = double.tryParse(volume);
    final double alcoholDouble = double.tryParse(alcoholConcentration);

    if (_addToTemplate) {
      final Drink template = Drink(
        name: _nameController.text,
        volume: Volume((volumeDouble * 10).toInt()),
        alcoholConcentration: Percentage.fromPercentage(alcoholDouble),
        timestamp: DateTime.now(),
        color: Colors.black,
        drinkType: DrinkTypes.glass_whiskey,
      );

      await DrinkRepo.insertDrink(template);
    }

    final Drink drink = Drink(
      sessionId: preferences.activeSessionId,
      name: _nameController.text,
      volume: Volume((volumeDouble * 10).toInt()),
      alcoholConcentration: Percentage.fromPercentage(alcoholDouble),
      timestamp: DateTime.now(),
      color: Colors.black,
      drinkType: DrinkTypes.glass_whiskey,
    );

    await DrinkRepo.insertDrink(drink);
    Utils.drinkWebHook(context);

    if (widget.onCreateDrink != null) {
      widget.onCreateDrink();
    }
    Navigator.of(context).pop();
  }
}
