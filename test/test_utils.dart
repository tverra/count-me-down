import 'package:count_me_down/database/database.dart';
import 'package:count_me_down/models/drink.dart';
import 'package:count_me_down/models/profile.dart';
import 'package:count_me_down/models/session.dart';
import 'package:sqflite/sqflite.dart';

class TestUtils {
  static Future<Database> getDb() async {
    return DBProvider.db.getDatabase();
  }

  static Future<void> clearDb(Database db) async {
    await db.delete(Profile.tableName);
    await db.delete(Session.tableName);
    await db.delete(Drink.tableName);
  }

  static DateTime getDateTime() {
    final int milliseconds = DateTime.now().toUtc().millisecondsSinceEpoch;
    return DateTime.fromMillisecondsSinceEpoch(milliseconds, isUtc: true);
  }
}
