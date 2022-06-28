import 'package:count_me_down/database/database.dart';
import 'package:count_me_down/database/db_repo.dart';
import 'package:count_me_down/models/drink.dart';
import 'package:count_me_down/models/session.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_ffi_test/sqflite_ffi_test.dart';

import '../data_generator.dart';
import '../test_utils.dart';

main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiTestInit();
  Database _db;
  DataGenerator _generator;

  setUp(() async {
    _db = await DBProvider.db.getDatabase(inMemory: true, seed: false);
    _generator = DataGenerator(_db);
  });

  tearDown(() async {
    await TestUtils.clearDb(_db);
  });

  group('getDrink', () {
    Drink _drink;

    setUp(() async {
      _drink = await _generator.insertDrink();
    });

    test('rows are inserted in setup', () async {
      final List<Map<String, dynamic>> res = await _db.query(Drink.tableName);
      final Drink drink = res.map((p) => Drink.fromMap(p)).single;

      expect(drink, _drink);
    });

    test('returns row on given id', () async {
      final Drink drink = await DrinkRepo.getDrink(_drink.id);
      expect(drink, _drink);
    });

    test('return null if no rows exists', () async {
      await TestUtils.clearDb(_db);

      final Drink drink = await DrinkRepo.getDrink(_drink.id);
      expect(drink, null);
    });

    test('preloading drinks returns null if no drinks exists', () async {
      await TestUtils.clearDb(_db);

      final Drink drink = await DrinkRepo.getDrink(_drink.id);
      expect(drink, null);
    });

    test('returns null if id is invalid', () async {
      final Drink drink = await DrinkRepo.getDrink(-1);
      expect(drink, null);
    });

    test('preloading session includes session', () async {
      final Drink drink =
          await DrinkRepo.getDrink(_drink.id, preloadArgs: [Drink.relSession]);

      expect(drink.session, _drink.session);
    });

    test('preloading non-existing session returns null', () async {
      final Drink drink = _generator.getDrink();
      drink.sessionId = null;
      await DrinkRepo.insertDrink(drink);

      final Drink insertedDrink =
          await DrinkRepo.getDrink(drink.id, preloadArgs: [Drink.relSession]);

      expect(insertedDrink.session, null);
    });

    test('preloading empty row returns null', () async {
      final Drink drink = await DrinkRepo.getDrink(_drink.id + 1,
          preloadArgs: [Drink.relSession]);
      expect(drink, null);
    });
  });

  group('getDrinks', () {
    List<Drink> _drinks;

    setUp(() async {
      _drinks = <Drink>[];

      for (int i = 0; i < 10; i++) {
        _drinks.add(await _generator.insertDrink());
      }
    });

    test('rows are inserted in setup', () async {
      final List<Map<String, dynamic>> res = await _db.query(Drink.tableName);
      final List<Drink> drinks = res.map((p) => Drink.fromMap(p)).toList();

      expect(drinks, _drinks);
    });

    test('returns all rows', () async {
      final List<Drink> drinks = await DrinkRepo.getDrinks();
      expect(drinks, _drinks);
    });

    test('returns all rows on session id', () async {
      final List<Drink> drinks = <Drink>[];
      drinks.add(_drinks[2]);

      for (int i = 0; i < 3; i++) {
        final Drink drink = _generator.getDrink();
        drink.sessionId = _drinks[2].sessionId;
        drinks.add(drink);
      }
      await DrinkRepo.insertDrinks(drinks);

      final List<Drink> insertedDrinks =
          await DrinkRepo.getDrinks(sessionId: _drinks[2].sessionId);
      expect(insertedDrinks, drinks);
    });

    test('returns empty list if no rows', () async {
      await TestUtils.clearDb(_db);

      final List<Drink> drinks = await DrinkRepo.getDrinks();
      expect(drinks, []);
    });

    test('preloading session includes session', () async {
      final List<Drink> drinks =
          await DrinkRepo.getDrinks(preloadArgs: [Drink.relSession]);

      for (int i = 0; i < _drinks.length; i++) {
        expect(drinks[i].session, _drinks[i].session);
      }
    });

    test('preloading parent on session id includes session', () async {
      final List<Drink> drinks = await DrinkRepo.getDrinks(
          sessionId: _drinks[4].sessionId, preloadArgs: [Drink.relSession]);

      expect(drinks[0].session, _drinks[4].session);
    });

    test('preloading non-existing parent returns null', () async {
      await TestUtils.clearDb(_db);
      final List<Drink> drinks = <Drink>[];

      for (int i = 0; i < 5; i++) {
        final Drink drink = _generator.getDrink();
        drink.sessionId = null;
        drinks.add(drink);
      }
      await DrinkRepo.insertDrinks(drinks);

      final List<Drink> insertedDrinks =
          await DrinkRepo.getDrinks(preloadArgs: [Drink.relSession]);

      insertedDrinks.forEach((drink) => expect(drink.session, null));
    });

    test('preloading parent on empty row returns empty list', () async {
      await TestUtils.clearDb(_db);

      final List<Drink> drinks =
          await DrinkRepo.getDrinks(preloadArgs: [Drink.relSession]);

      drinks.forEach((drink) => expect(drink, []));
    });
  });

  group('getDrinkTemplates', () {
    List<Drink> _drinks;

    setUp(() async {
      _drinks = <Drink>[];

      for (int i = 0; i < 10; i++) {
        _drinks.add(await _generator.insertDrink(sessionId: 0));
      }
    });

    test('rows are inserted in setup', () async {
      final List<Map<String, dynamic>> res = await _db.query(Drink.tableName);
      final List<Drink> drinks = res.map((p) => Drink.fromMap(p)).toList();

      expect(drinks, _drinks);
    });

    test('returns all rows without session id', () async {
      for (int i = 0; i < 10; i++) {
        await _generator.insertDrink();
      }

      final List<Drink> templates = await DrinkRepo.getDrinkTemplates();
      expect(templates, _drinks);
    });
  });

  group('insertDrink', () {
    Drink _drink;

    setUp(() {
      _drink = _generator.getDrink();
    });

    test('no rows are inserted in setup', () async {
      final List<Map<String, dynamic>> res = await _db.query(Drink.tableName);
      expect(res, []);
    });

    test('inserts row into table', () async {
      await DrinkRepo.insertDrink(_drink);

      final Drink drink = await DrinkRepo.getDrink(_drink.id);
      expect(drink, _drink);
    });

    test('id is auto-incremented', () async {
      final Drink drink = _generator.getDrink();
      drink.id = null;
      final int id = await DrinkRepo.insertDrink(drink);
      final Drink insertedDrink = await DrinkRepo.getDrink(null);

      expect(id == null, false);
      expect(insertedDrink, null);
    });

    test('correct id is returned after insertion', () async {
      _drink.id = 10;
      final int actual = await DrinkRepo.insertDrink(_drink);
      final Drink insertedDrink = await DrinkRepo.getDrink(_drink.id);
      final int expected = insertedDrink.id;

      expect(actual, expected);
    });

    test('inserting on existing id replaces previous data', () async {
      await DrinkRepo.insertDrink(_drink);
      _drink.name = 'test';
      await DrinkRepo.insertDrink(_drink);

      final Drink drink = await DrinkRepo.getDrink(_drink.id);
      expect(drink, _drink);
    });
  });

  group('insertDrinks', () {
    List<Drink> _drinks;

    setUp(() {
      _drinks = <Drink>[];

      for (int i = 0; i < 10; i++) {
        _drinks.add(_generator.getDrink());
      }
    });

    test('no rows are inserted in setup', () async {
      final List<Map<String, dynamic>> res = await _db.query(Drink.tableName);
      expect(res, []);
    });

    test('rows are inserted', () async {
      await DrinkRepo.insertDrinks(_drinks);

      final List<Drink> drinks = await DrinkRepo.getDrinks();
      expect(drinks, _drinks);
    });

    test('inserts no row if empty list is given', () async {
      await DrinkRepo.insertDrinks([]);

      final List<Drink> drinks = await DrinkRepo.getDrinks();
      expect(drinks, []);
    });

    test('correct ids are returned after inserting', () async {
      for (int i = 0; i < _drinks.length; i++) {
        _drinks[i].id = i + 10;
      }
      final List actual = await DrinkRepo.insertDrinks(_drinks);

      final List<Drink> drinks = await DrinkRepo.getDrinks();
      final List expected = drinks.map((p) => p.id).toList();

      expect(actual, expected);
    });

    test('inserting on existing id replaces previous data', () async {
      final List<int> result = await DrinkRepo.insertDrinks(_drinks);

      for (int i = 0; i < result.length; i++) {
        _drinks[i].name = 'test';
      }
      await DrinkRepo.insertDrinks(_drinks);

      final List<Drink> drinks = await DrinkRepo.getDrinks();
      for (int i = 0; i < _drinks.length; i++) {
        expect(_drinks[i], drinks[i]);
      }
    });

    test('inserting the same row multiple times returns correct result',
        () async {
      final List<Drink> drinks = <Drink>[];
      for (int i = 0; i < 10; i++) {
        final Drink drink = _drinks[0];
        drink.id = 1;
        drinks.add(drink);
      }
      final List<int> result = await DrinkRepo.insertDrinks(drinks);

      expect(result, [1, 1, 1, 1, 1, 1, 1, 1, 1, 1]);
    });
  });

  group('updateDrink', () {
    Drink _drink;

    setUp(() async {
      _drink = await _generator.insertDrink();
    });

    test('row is inserted in setup', () async {
      final List<Map<String, dynamic>> res = await _db.query(Drink.tableName);
      final Drink drink = res.map((p) => Drink.fromMap(p)).single;

      expect(drink, _drink);
    });

    test('drinks are updated', () async {
      _drink.name = 'test';
      await DrinkRepo.updateDrink(_drink);

      final Drink drink = await DrinkRepo.getDrink(_drink.id);
      expect(drink, _drink);
    });

    test('number of updated rows are correct', () async {
      _drink.name = 'test';
      final int result = await DrinkRepo.updateDrink(_drink);

      expect(result, 1);
    });

    test('no rows are updated if id is invalid', () async {
      _drink.id = null;

      final int result = await DrinkRepo.updateDrink(_drink);
      expect(result, 0);
    });

    test('updates existing row if insertMissing is true', () async {
      _drink.name = 'test';
      await DrinkRepo.updateDrink(_drink, insertMissing: true);

      final Drink drink = await DrinkRepo.getDrink(_drink.id);
      expect(drink, _drink);
    });

    test('updating non-existing row inserts row if insertMissing is true',
        () async {
      final Drink nonInserted = _generator.getDrink();
      nonInserted.id = _drink.id + 1;
      await DrinkRepo.updateDrink(nonInserted, insertMissing: true);

      final Drink updated = await DrinkRepo.getDrink(nonInserted.id);
      expect(updated, nonInserted);
    });

    test('updating non-existing row does nothing if insertMissing is false',
        () async {
      final Drink nonInserted = _generator.getDrink();
      nonInserted.id = _drink.id + 1;
      final int result = await DrinkRepo.updateDrink(nonInserted);

      final Drink updated = await DrinkRepo.getDrink(nonInserted.id);
      expect(result, 0);
      expect(updated, null);
    });

    test('updates on the correct id', () async {
      final String initialName = _drink.name;
      _drink.id = _drink.id + 1;
      await DrinkRepo.insertDrink(_drink);
      _drink.name = 'test';
      await DrinkRepo.updateDrink(_drink);

      final List<Drink> drinks = await DrinkRepo.getDrinks();
      expect(drinks[0].name, initialName);
      expect(drinks[1].name, _drink.name);
    });
  });

  group('updateDrinks', () {
    List<Drink> _drinks;

    setUp(() async {
      _drinks = <Drink>[];

      for (int i = 0; i < 10; i++) {
        _drinks.add(await _generator.insertDrink());
      }
    });

    test('rows are inserted in setup', () async {
      final List<Map<String, dynamic>> res = await _db.query(Drink.tableName);
      final List<Drink> drinks = res.map((p) => Drink.fromMap(p)).toList();

      expect(drinks, _drinks);
    });

    test('drinks are updated', () async {
      for (final Drink drink in _drinks) {
        drink.name = 'test';
      }
      await DrinkRepo.updateDrinks(_drinks);
      final List<Drink> drinks = await DrinkRepo.getDrinks();

      for (int i = 0; i < _drinks.length; i++) {
        expect(drinks[i], _drinks[i]);
      }
    });

    test('updates no rows if empty list is given', () async {
      await DrinkRepo.updateDrinks([]);

      final List<Drink> drinks = await DrinkRepo.getDrinks();
      expect(drinks, _drinks);
    });

    test('updating returns correct number of rows affected', () async {
      final List<int> actual = await DrinkRepo.updateDrinks(_drinks);
      expect(actual.length, _drinks.length);
    });

    test('updating returns the ids of the affected rows', () async {
      final List<int> actual = await DrinkRepo.updateDrinks(_drinks);
      expect(actual, [1, 1, 1, 1, 1, 1, 1, 1, 1, 1]);
    });

    test('the correct row is updated', () async {
      final Drink drink = _drinks[3];
      drink.name = 'updated';
      await DrinkRepo.updateDrinks(_drinks);
      final List<Drink> drinks = await DrinkRepo.getDrinks();

      expect(drinks.length, _drinks.length);
      for (int i = 0; i < _drinks.length; i++) {
        expect(_drinks[i].name, drinks[i].name);
      }
    });

    test('updating non-existing row inserts row if insertMissing is true',
        () async {
      final Drink nonInserted = _generator.getDrink();
      _drinks.add(nonInserted);

      await DrinkRepo.updateDrinks(_drinks, insertMissing: true);

      final List<Drink> drinks = await DrinkRepo.getDrinks();
      expect(drinks, _drinks);
    });

    test('updating non-existing row does nothing if insertMissing is false',
        () async {
      final Drink nonInserted = _generator.getDrink();
      final List<Drink> nonUpdatedList = List.from(_drinks);
      nonUpdatedList.add(nonInserted);
      await DrinkRepo.updateDrinks(nonUpdatedList);

      final List<Drink> drinks = await DrinkRepo.getDrinks();
      expect(drinks, _drinks);
    });

    test('updates rows in table if insertMissing is true', () async {
      for (Drink drink in _drinks) {
        drink.name = 'updated';
      }
      await DrinkRepo.updateDrinks(_drinks, insertMissing: true);
      final List<Drink> drinks = await DrinkRepo.getDrinks();

      for (int i = 0; i < _drinks.length; i++) {
        expect(drinks[i], _drinks[i]);
      }
    });

    test('removes non-existing rows if removeDeleted is true', () async {
      _drinks.removeAt(6);
      await DrinkRepo.updateDrinks(_drinks, removeDeleted: true);

      final List<Drink> drinks = await DrinkRepo.getDrinks();
      expect(drinks, _drinks);
    });

    test('removes non-existing rows on session id', () async {
      final Session session = _drinks[6].session;
      _drinks.removeAt(6);
      List<Drink> expected = List<Drink>.from(_drinks).toList();
      _drinks.removeRange(1, 4);
      final List<Drink> drinks = <Drink>[];

      for (int i = 0; i < 5; i++) {
        drinks.add(_generator.getDrink(sessionId: session.id));
      }
      await DrinkRepo.insertDrinks(drinks);
      await DrinkRepo.updateDrinks(_drinks,
          sessionId: session.id, removeDeleted: true);

      final List<Drink> actual = await DrinkRepo.getDrinks();
      expect(actual, expected);
    });

    test('does not change non-existing rows if removeDeleted is false',
        () async {
      final List<Drink> updatedDrinks = <Drink>[];
      for (int i = 0; i < _drinks.length; i++) {
        if (i != 6) updatedDrinks.add(_drinks[i]);
      }
      await DrinkRepo.updateDrinks(_drinks, removeDeleted: false);

      final List<Drink> drinks = await DrinkRepo.getDrinks();
      expect(drinks, _drinks);
    });

    test('updates rows in table when removeDeleted is true', () async {
      for (Drink drink in _drinks) {
        drink.name = 'updated';
      }
      await DrinkRepo.updateDrinks(_drinks, removeDeleted: true);
      final List<Drink> drinks = await DrinkRepo.getDrinks();

      for (int i = 0; i < _drinks.length; i++) {
        expect(drinks[i], _drinks[i]);
      }
    });

    test('updating both inserts and removes rows', () async {
      final Drink nonInserted = _generator.getDrink();
      nonInserted.id = _drinks.last.id + 1;
      _drinks.removeAt(6);
      _drinks.add(nonInserted);

      await DrinkRepo.updateDrinks(_drinks,
          insertMissing: true, removeDeleted: true);

      final List<Drink> drinks = await DrinkRepo.getDrinks();
      expect(drinks, _drinks);
    });
  });

  group('deleteDrink', () {
    Drink _drink;

    setUp(() async {
      _drink = await _generator.insertDrink();
    });

    test('row is inserted in setup', () async {
      final List<Map<String, dynamic>> res = await _db.query(Drink.tableName);
      final Drink drink = res.map((p) => Drink.fromMap(p)).single;

      expect(drink, _drink);
    });

    test('row is deleted', () async {
      await DrinkRepo.deleteDrink(_drink);
      final List<Drink> drinks = await DrinkRepo.getDrinks();
      expect(drinks, []);
    });

    test('deletes only given row', () async {
      final Drink drink = _generator.getDrink();
      await DrinkRepo.insertDrink(drink);
      await DrinkRepo.deleteDrink(_drink);

      final List<Drink> drinks = await DrinkRepo.getDrinks();
      expect(drinks, [drink]);
    });

    test('returns number of rows affected', () async {
      _drink.id = _drink.id + 10;
      await DrinkRepo.insertDrink(_drink);

      final int result = await DrinkRepo.deleteDrink(_drink);
      expect(result, 1);
    });
  });

  group('deleteDrinks', () {
    List<Drink> _drinks;

    setUp(() async {
      _drinks = <Drink>[];

      for (int i = 0; i < 10; i++) {
        _drinks.add(await _generator.insertDrink());
      }
    });

    test('rows are inserted in setup', () async {
      final List<Map<String, dynamic>> res = await _db.query(Drink.tableName);
      final List<Drink> drinks = res.map((p) => Drink.fromMap(p)).toList();

      expect(drinks, _drinks);
    });

    test('drinks are deleted', () async {
      await DrinkRepo.deleteDrinks();
      final List<Drink> drinks = await DrinkRepo.getDrinks();
      expect(drinks, []);
    });

    test('drinks are deleted on session id', () async {
      final Session session = _drinks[6].session;
      _drinks.removeAt(6);
      List<Drink> expected = List<Drink>.from(_drinks).toList();
      _drinks.removeRange(1, 4);
      final List<Drink> drinks = <Drink>[];

      for (int i = 0; i < 5; i++) {
        drinks.add(_generator.getDrink(sessionId: session.id));
      }
      await DrinkRepo.insertDrinks(drinks);
      await DrinkRepo.deleteDrinks(sessionId: session.id);

      final List<Drink> actual = await DrinkRepo.getDrinks();
      expect(actual, expected);
    });

    test('returns number of rows affected', () async {
      final int actual = await DrinkRepo.deleteDrinks();
      expect(actual, _drinks.length);
    });

    test('deleting on empty table returns number of rows affected', () async {
      await TestUtils.clearDb(_db);
      final int actual = await DrinkRepo.deleteDrinks();

      expect(actual, 0);
    });
  });
}
