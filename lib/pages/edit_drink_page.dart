import 'package:count_me_down/database/db_repo.dart';
import 'package:count_me_down/models/drink.dart';
import 'package:count_me_down/utils/utils.dart';
import 'package:flutter/material.dart';

class EditDrinkPage extends StatelessWidget {
  final Drink drink;
  final VoidCallback onEditDrink;

  EditDrinkPage({@required this.drink, this.onEditDrink});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit drink'),
      ),
      body: Container(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Container(
            width: double.infinity,
            child: RaisedButton(
              color: Theme.of(context).primaryColor,
              onPressed: () => _deleteDrink(context),
              child: Container(
                padding: const EdgeInsets.all(15.0),
                child: Text(
                  'Delete drink',
                  style: TextStyle(
                      color: Utils.getThemeTextColor(context), fontSize: 18.0),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _deleteDrink(BuildContext context) async {
    await DrinkRepo.deleteDrink(drink);

    if (onEditDrink != null) {
      onEditDrink();
    }

    Navigator.of(context).pop();
  }
}
