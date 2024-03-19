import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class SqliteHelper{
  Future<Database> getDatabase() async {
    String path = join(await getDatabasesPath(), 'database.db');
    return openDatabase(path, onCreate: (db, version) {
      return db.execute(
          "CREATE TABLE users(id INTEGER PRIMARY KEY, name TEXT, age TEXT)");
    }, version: 1);
  }
  Future<void> insertData(String name, String age) async {
    final Database db = await getDatabase();
    await db.insert('users', {'name': name, 'age': age});
  }

  Future<List<Map<String, dynamic>>> getData() async {
    final Database db = await getDatabase();
    return db.query('users');
  }

  Future<void> updateData(int id, String newName, String newAge) async {
    final Database db = await getDatabase();
    await db.update('users', {'name': newName, 'age': newAge},
        where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteData(int id) async {
    final Database db = await getDatabase();
    await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

}