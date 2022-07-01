import 'package:count_me_down/database/db_repos.dart';
import 'package:count_me_down/models/drink.dart';
import 'package:count_me_down/utils/utils.dart' as utils;
import 'package:flutter/material.dart';

class EditDrinkPage extends StatelessWidget {
  final Drink drink;
  final VoidCallback? onEditDrink;

  const EditDrinkPage({required this.drink, this.onEditDrink});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit drink'),
      ),
      body: Container(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Theme.of(context).primaryColor,
              ),
              onPressed: () => _deleteDrink(context),
              child: Container(
                padding: const EdgeInsets.all(15.0),
                child: Text(
                  'Delete drink',
                  style: TextStyle(
                    color: utils.getThemeTextColor(context),
                    fontSize: 18.0,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _deleteDrink(BuildContext context) async {
    final VoidCallback? onEditDrink = this.onEditDrink;
    await deleteDrink(drink);

    utils.drinkWebHook(context);

    if (onEditDrink != null) {
      onEditDrink();
    }

    Navigator.of(context).pop();
  }
}
