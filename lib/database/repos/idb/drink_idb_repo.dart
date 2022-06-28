import 'package:count_me_down/models/drink.dart';

Future<Drink?> getDrink(int id, {List<String>? preloadArgs}) {
  throw UnimplementedError();
}

Future<List<Drink>> getDrinks({int? sessionId, List<String>? preloadArgs}) {
  throw UnimplementedError();
}

Future<List<Drink>> getDrinkTemplates({List<String>? preloadArgs}) {
  throw UnimplementedError();
}

Future<int> insertDrink(Drink drink) {
  throw UnimplementedError();
}

Future<List<int>> insertDrinks(List<Drink> drinks) {
  throw UnimplementedError();
}

Future<int> updateDrink(Drink drink, {bool insertMissing = false}) {
  throw UnimplementedError();
}

Future<List<int>> updateDrinks(
  List<Drink> drinks, {
  int? sessionId,
  bool insertMissing = false,
  bool removeDeleted = false,
}) {
  throw UnimplementedError();
}

Future<int> deleteDrink(Drink drink) {
  throw UnimplementedError();
}

Future<int> deleteDrinks({int? sessionId}) {
  throw UnimplementedError();
}
