import 'package:count_me_down/database/db_repos.dart';
import 'package:count_me_down/database/db_utils.dart';
import 'package:count_me_down/models/drink.dart';
import 'package:count_me_down/models/session.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../data_generator.dart' as generator;
import '../../test_db_utils.dart' as db_utils;
import '../../test_utils.dart' as test_utils;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  if (useSqfLiteDb) {
    sqfliteFfiInit();
  }

  setUp(() async {
    await test_utils.loadTestDb();
  });

  tearDown(() async {
    await test_utils.clearDb();
  });

  group('getDrink', () {
    late Drink _drink;

    setUp(() async {
      _drink = await generator.insertDrink();
    });

    test('rows are inserted in setup', () async {
      final Drink drink = (await db_utils.getDrinks()).single;

      expect(drink, _drink);
    });

    test('returns row on given id', () async {
      final Drink drink = (await getDrink(_drink.id!))!;
      expect(drink, _drink);
    });

    test('return null if no rows exists', () async {
      await test_utils.clearDb();

      final Drink? drink = await getDrink(_drink.id!);
      expect(drink, null);
    });

    test('returns null if id is invalid', () async {
      final Drink? drink = await getDrink(-1);
      expect(drink, null);
    });

    test('preloading session includes session', () async {
      final Drink drink = (await getDrink(
        _drink.id!,
        preloadArgs: <String>[Drink.relSession],
      ))!;

      expect(drink.session, _drink.session);
    });

    test('preloading non-existing session returns null', () async {
      final Drink drink = await generator.insertDrink(sessionId: -1);

      final Drink insertedDrink = (await getDrink(
        drink.id!,
        preloadArgs: <String>[Drink.relSession],
      ))!;

      expect(insertedDrink.session, null);
    });

    test('invalid preload returns no preloads', () async {
      final Drink drink = (await getDrink(
        _drink.id!,
        preloadArgs: <String>['invalid'],
      ))!;

      expect(drink.session, null);
    });

    test('preloading empty row returns null', () async {
      final Drink? drink = await getDrink(
        _drink.id! + 1,
        preloadArgs: <String>[Drink.relSession],
      );
      expect(drink, null);
    });
  });

  group('getDrinkTemplates', () {
    late List<Drink> _drinks;

    setUp(() async {
      _drinks = <Drink>[];

      for (int i = 0; i < 10; i++) {
        _drinks.add(await generator.insertDrink(sessionId: 0));
      }
    });

    test('rows are inserted in setup', () async {
      final List<Drink> drinks = (await db_utils.getDrinks()).toList();

      expect(drinks, _drinks);
    });

    test('returns all rows without session id', () async {
      for (int i = 0; i < 10; i++) {
        await generator.insertDrink();
      }

      final List<Drink> templates = await getDrinkTemplates();
      expect(templates, _drinks);
    });

    test('returns empty list if no templates exists', () async {
      await test_utils.clearDb();

      for (int i = 0; i < 10; i++) {
        await generator.insertDrink();
      }

      final List<Drink> templates = await getDrinkTemplates();
      expect(templates, <Drink>[]);
    });
  });

  group('getDrinks', () {
    late List<Drink> _drinks;

    setUp(() async {
      _drinks = <Drink>[];

      for (int i = 0; i < 10; i++) {
        _drinks.add(await generator.insertDrink());
      }
    });

    test('rows are inserted in setup', () async {
      final List<Drink> drinks = (await db_utils.getDrinks()).toList();

      expect(drinks, _drinks);
    });

    test('returns all rows', () async {
      final List<Drink> drinks = await getDrinks();
      expect(drinks, _drinks);
    });

    test('returns all rows on session id', () async {
      final List<Drink> drinks = <Drink>[];
      drinks.add(_drinks[2]);

      for (int i = 0; i < 3; i++) {
        final Drink drink = generator.getDrink(sessionId: _drinks[2].sessionId);
        drinks.add(drink);
      }
      await insertDrinks(drinks);

      final List<Drink> insertedDrinks =
          await getDrinks(sessionId: _drinks[2].sessionId);
      expect(insertedDrinks, drinks);
    });

    test('returns empty list if no rows', () async {
      await test_utils.clearDb();

      final List<Drink> drinks = await getDrinks();
      expect(drinks, <Drink>[]);
    });

    test('preloading children on empty row returns empty list', () async {
      await test_utils.clearDb();

      final List<Drink> drinks = await getDrinks(
        preloadArgs: <String>[Drink.relSession],
      );

      expect(drinks, <Drink>[]);
    });

    test('preloading session includes session', () async {
      final List<Drink> drinks =
          await getDrinks(preloadArgs: <String>[Drink.relSession]);

      for (int i = 0; i < _drinks.length; i++) {
        expect(drinks[i].session, _drinks[i].session);
      }
    });

    test('preloading parent on session id includes session', () async {
      final List<Drink> drinks = await getDrinks(
        sessionId: _drinks[4].sessionId,
        preloadArgs: <String>[Drink.relSession],
      );

      expect(drinks[0].session, _drinks[4].session);
    });

    test('preloading non-existing parent returns null', () async {
      await test_utils.clearDb();
      final List<Drink> drinks = <Drink>[];

      for (int i = 0; i < 5; i++) {
        final Drink drink = generator.getDrink();
        drinks.add(drink);
      }
      await insertDrinks(drinks);

      final List<Drink> insertedDrinks = await getDrinks(
        preloadArgs: <String>[Drink.relSession],
      );

      for (final Drink drink in insertedDrinks) {
        expect(drink.session, null);
      }
    });

    test('invalid preload returns no preloads', () async {
      final List<Drink> drinks =
          await getDrinks(preloadArgs: <String>['invalid']);

      for (final Drink drink in drinks) {
        expect(drink.session, null);
      }
    });

    test('preloading parent on empty row returns empty list', () async {
      await test_utils.clearDb();

      final List<Drink> drinks = await getDrinks(
        preloadArgs: <String>[Drink.relSession],
      );

      for (final Drink drink in drinks) {
        expect(drink, <Drink>[]);
      }
    });
  });

  group('insertDrink', () {
    late Drink _drink;

    setUp(() async {
      _drink = generator.getDrink();
    });

    test('no rows are inserted in setup', () async {
      final List<Drink> drinks = await db_utils.getDrinks();
      expect(drinks.length, 0);
    });

    test('inserts row into table', () async {
      await insertDrink(_drink);

      final Drink drink = (await getDrink(_drink.id!))!;
      expect(drink, _drink);
    });

    test('id is auto-incremented', () async {
      final Drink drink = generator.getDrink();
      drink.id = null;
      final int? id = (await insertDrink(drink)).id;
      final List<Drink> insertedDrinks = await getDrinks();
      expect(id == null, false);
      expect(insertedDrinks.length, 1);
    });

    test('correct id is returned after insertion', () async {
      _drink.id = 1000;
      final Drink updated = await insertDrink(_drink);
      final Drink inserted = (await getDrink(_drink.id!))!;

      expect(updated.id, 1000);
      expect(inserted.id, 1000);
    });

    test('inserting on existing id replaces previous data', () async {
      await insertDrink(_drink);
      _drink.name = 'test';
      await insertDrink(_drink);

      final Drink drink = (await getDrink(_drink.id!))!;
      expect(drink, _drink);
    });
  });

  group('insertDrinks', () {
    late List<Drink> _drinks;

    setUp(() async {
      _drinks = <Drink>[];

      for (int i = 0; i < 10; i++) {
        _drinks.add(generator.getDrink());
      }
    });

    test('no rows are inserted in setup', () async {
      final List<Drink> drinks = await db_utils.getDrinks();
      expect(drinks.length, 0);
    });

    test('rows are inserted', () async {
      await insertDrinks(_drinks);

      final List<Drink> drinks = await getDrinks();
      expect(drinks, _drinks);
    });

    test('inserts no row if empty list is given', () async {
      await insertDrinks(<Drink>[]);

      final List<Drink> drinks = await getDrinks();
      expect(drinks, <Drink>[]);
    });

    test('correct ids are returned after inserting', () async {
      final List<int> expected = <int>[];

      for (int i = 0; i < _drinks.length; i++) {
        _drinks[i].id = 1000 + i;
        expected.add(1000 + i);
      }
      final List<Drink> updated = await insertDrinks(_drinks);

      final List<int> actual = updated.map((Drink s) => s.id!).toList();

      expect(actual, expected);
    });

    test('inserting on existing id replaces previous data', () async {
      final List<Drink> result = await insertDrinks(_drinks);

      for (int i = 0; i < result.length; i++) {
        _drinks[i].name = 'test';
      }
      await insertDrinks(_drinks);

      final List<Drink> drinks = await getDrinks();
      for (int i = 0; i < _drinks.length; i++) {
        expect(_drinks[i], drinks[i]);
      }
    });

    test('inserting the same row multiple times returns correct result',
        () async {
      final List<Drink> drinks = <Drink>[];
      for (int i = 0; i < 10; i++) {
        final Drink drink = _drinks[0].copy();
        drink.id = 1;
        drinks.add(drink);
      }
      final List<Drink> result = await insertDrinks(drinks);

      expect(result, drinks);
    });
  });

  group('updateDrink', () {
    late Drink _drink;

    setUp(() async {
      _drink = await generator.insertDrink();
    });

    test('row is inserted in setup', () async {
      final Drink drink = (await db_utils.getDrinks()).single;

      expect(drink, _drink);
    });

    test('drinks are updated', () async {
      _drink.name = 'test';
      await updateDrink(_drink);

      final Drink drink = (await getDrink(_drink.id!))!;
      expect(drink, _drink);
    });

    test('returns the updated row', () async {
      _drink.name = 'test';
      final Drink? result = await updateDrink(_drink);

      expect(result, _drink);
    });

    test('no rows are updated if id is invalid', () async {
      _drink.id = -1;

      final Drink? result = await updateDrink(_drink);

      expect(result, null);
    });

    test('updates existing row if insertMissing is true', () async {
      _drink.name = 'test';
      await updateDrink(_drink, insertMissing: true);

      final Drink? drink = await getDrink(_drink.id!);
      expect(drink, _drink);
    });

    test('updating non-existing row inserts row if insertMissing is true',
        () async {
      final Drink nonInserted = generator.getDrink();
      final Drink? updated =
          await updateDrink(nonInserted, insertMissing: true);

      final Drink? inserted = await getDrink(updated!.id!);
      expect(inserted, nonInserted);
    });

    test('updating non-existing row does nothing if insertMissing is false',
        () async {
      final Drink nonInserted = generator.getDrink();
      final Drink? result = await updateDrink(nonInserted);

      final Drink? updated = await getDrink(nonInserted.id!);
      expect(result, null);
      expect(updated, null);
    });

    test('updates on the correct id', () async {
      final String initialName = _drink.name!;
      _drink.id = _drink.id! + 1;
      await insertDrink(_drink);

      _drink.name = 'test';
      await updateDrink(_drink);

      final List<Drink> drinks = await getDrinks();

      expect(drinks[0].name, initialName);
      expect(drinks[1].name, _drink.name);
    });
  });

  group('updateDrinks', () {
    late List<Drink> _drinks;

    setUp(() async {
      _drinks = <Drink>[];

      for (int i = 0; i < 10; i++) {
        _drinks.add(await generator.insertDrink());
      }
    });

    test('rows are inserted in setup', () async {
      final List<Drink> drinks = await db_utils.getDrinks();

      expect(drinks, _drinks);
    });

    test('drinks are updated', () async {
      final List<Drink> toBeUpdated = <Drink>[];

      for (final Drink drink in _drinks) {
        final Drink copy = drink.copy();
        copy.name = 'test';
        toBeUpdated.add(copy);
      }
      await updateDrinks(toBeUpdated);
      final List<Drink> drinks = await getDrinks();

      for (int i = 0; i < _drinks.length; i++) {
        expect(drinks[i], toBeUpdated[i]);
      }
    });

    test('updates no rows if empty list is given', () async {
      await updateDrinks(<Drink>[]);

      final List<Drink> drinks = await getDrinks();
      expect(drinks, _drinks);
    });

    test('updating returns the affected rows', () async {
      final List<Drink?> result = await updateDrinks(_drinks);
      expect(result, _drinks);
    });

    test('updating does not return unaffected rows', () async {
      _drinks[2].id = -1;
      final List<Drink?> result = await updateDrinks(_drinks);

      final List<Drink> expected = List<Drink>.from(_drinks);
      expected.removeAt(2);

      expect(result, expected);
    });

    test('the correct row is updated', () async {
      _drinks[3].name = 'updated';
      await updateDrinks(_drinks);
      final List<Drink> drinks = await getDrinks();

      expect(drinks.length, _drinks.length);
      for (int i = 0; i < _drinks.length; i++) {
        expect(_drinks[i].name, drinks[i].name);
      }
    });

    test('updating non-existing row inserts row if insertMissing is true',
        () async {
      final Drink nonInserted = generator.getDrink();
      _drinks.add(nonInserted);

      await updateDrinks(_drinks, insertMissing: true);

      final List<Drink> drinks = await getDrinks();
      expect(drinks, _drinks);
    });

    test('updating non-existing row does nothing if insertMissing is false',
        () async {
      final Drink nonInserted = generator.getDrink();
      final List<Drink> nonUpdatedList = List<Drink>.from(_drinks);
      nonUpdatedList.add(nonInserted);
      await updateDrinks(nonUpdatedList);

      final List<Drink> drinks = await getDrinks();
      expect(drinks, _drinks);
    });

    test('updates rows in table if insertMissing is true', () async {
      final List<Drink> toBeUpdated = <Drink>[];

      for (final Drink drink in _drinks) {
        final Drink copy = drink.copy();
        copy.name = 'updated';
        toBeUpdated.add(copy);
      }
      await updateDrinks(toBeUpdated, insertMissing: true);
      final List<Drink> drinks = await getDrinks();

      for (int i = 0; i < _drinks.length; i++) {
        expect(drinks[i], toBeUpdated[i]);
      }
    });

    test('removes non-existing rows if removeDeleted is true', () async {
      _drinks.removeAt(6);
      await updateDrinks(_drinks, removeDeleted: true);

      final List<Drink> drinks = await getDrinks();
      expect(drinks, _drinks);
    });

    test('removes non-existing rows on session id', () async {
      final Session session = _drinks[6].session!;
      _drinks.removeAt(6);
      final List<Drink> expected = List<Drink>.from(_drinks).toList();
      _drinks.removeRange(1, 4);
      final List<Drink> drinks = <Drink>[];

      for (int i = 0; i < 5; i++) {
        drinks.add(generator.getDrink(sessionId: session.id));
      }
      await insertDrinks(drinks);
      await updateDrinks(_drinks, sessionId: session.id, removeDeleted: true);

      final List<Drink> actual = await getDrinks();
      expect(actual, expected);
    });

    test('does not change non-existing rows if removeDeleted is false',
        () async {
      final List<Drink> updatedDrinks = <Drink>[];
      for (int i = 0; i < _drinks.length; i++) {
        if (i != 6) updatedDrinks.add(_drinks[i]);
      }
      await updateDrinks(_drinks, removeDeleted: false);

      final List<Drink> drinks = await getDrinks();
      expect(drinks, _drinks);
    });

    test('updates rows in table when removeDeleted is true', () async {
      final List<Drink> toBeUpdated = <Drink>[];

      for (final Drink drink in _drinks) {
        final Drink copy = drink.copy();
        copy.name = 'updated';
        toBeUpdated.add(copy);
      }
      await updateDrinks(toBeUpdated, removeDeleted: true);
      final List<Drink> drinks = await getDrinks();

      for (int i = 0; i < _drinks.length; i++) {
        expect(drinks[i], toBeUpdated[i]);
      }
    });

    test('updating both inserts and removes rows', () async {
      final Drink nonInserted = generator.getDrink();
      _drinks.removeAt(6);
      _drinks.add(nonInserted);

      await updateDrinks(_drinks, insertMissing: true, removeDeleted: true);

      final List<Drink> drinks = await getDrinks();
      expect(drinks, _drinks);
    });
  });

  group('deleteDrink', () {
    late Drink _drink;

    setUp(() async {
      _drink = await generator.insertDrink();
    });

    test('row is inserted in setup', () async {
      final Drink drink = (await db_utils.getDrinks()).single;

      expect(drink, _drink);
    });

    test('row is deleted', () async {
      await deleteDrink(_drink);
      final List<Drink> drinks = await getDrinks();
      expect(drinks, <Drink>[]);
    });

    test('deletes only given row', () async {
      final Drink drink = generator.getDrink();
      await insertDrink(drink);
      await deleteDrink(_drink);

      final List<Drink> drinks = await getDrinks();
      expect(drinks, <Drink>[drink]);
    });

    test('returns number of rows affected', () async {
      final int result = await deleteDrink(_drink);
      expect(result, 1);
    });

    test('returns zero if no rows are affected ', () async {
      final Drink drink = generator.getDrink();

      final int result = await deleteDrink(drink);
      expect(result, 0);
    });
  });

  group('deleteDrinks', () {
    late List<Drink> _drinks;

    setUp(() async {
      _drinks = <Drink>[];

      for (int i = 0; i < 10; i++) {
        _drinks.add(await generator.insertDrink());
      }
    });

    test('rows are inserted in setup', () async {
      final List<Drink> drinks = await db_utils.getDrinks();

      expect(drinks, _drinks);
    });

    test('drinks are deleted', () async {
      await deleteDrinks();
      final List<Drink> drinks = await getDrinks();
      expect(drinks, <Drink>[]);
    });

    test('drinks are deleted on session id', () async {
      final Session session = _drinks[6].session!;
      _drinks.removeAt(6);
      final List<Drink> expected = List<Drink>.from(_drinks).toList();
      _drinks.removeRange(1, 4);
      final List<Drink> drinks = <Drink>[];

      for (int i = 0; i < 5; i++) {
        drinks.add(generator.getDrink(sessionId: session.id));
      }
      await insertDrinks(drinks);
      await deleteDrinks(sessionId: session.id);

      final List<Drink> actual = await getDrinks();
      expect(actual, expected);
    });

    test('no drinks are deleted if session id is invalid', () async {
      final int actual = await deleteDrinks(sessionId: 1000);

      expect(actual, 0);
    });

    test('returns number of rows affected', () async {
      final int actual = await deleteDrinks();
      expect(actual, _drinks.length);
    });

    test('deleting on empty table returns number of rows affected', () async {
      await test_utils.clearDb();
      final int actual = await deleteDrinks();

      expect(actual, 0);
    });
  });
}
