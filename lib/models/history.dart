import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _db;
  static const int _maxItems = 10;

  Future<Database> get db async {
    if (_db != null) {
      return _db!;
    }
    _db = await initDb();
    return _db!;
  }

  DatabaseHelper._internal();

  Future<Database> initDb() async {
    final databasePath = await getDatabasesPath();
    final path = databasePath.toString() + "/"+ "history.db";
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE history (path TEXT PRIMARY KEY, filename TEXT, time INTEGER)',
        );
      },
    );
  }

  Future<int> addItem(String path, filename, ) async {
    final db = await this.db;
    if (path.split('.').last == 'pdf') {
      final count = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM history'))!;
      if (count >= _maxItems) {
        final oldestItem = await db.query(
            'history', orderBy: 'time ASC', limit: 1);
        final oldestPath = oldestItem.first['path'];
        await db.delete('history', where: 'path = ?', whereArgs: [oldestPath]);
      }

      return await db.insert(
          'history', {'path': path, 'filename': filename, 'time': DateTime
          .now()
          .millisecondsSinceEpoch});
    } else {
      return 0;
    }
  }

  Future<int> updateItem(String path, String newFilename,) async {
    final db = await this.db;
    var updated = await db.update('history', {'filename': newFilename, 'time': DateTime.now().millisecondsSinceEpoch}, where: 'path = ?', whereArgs: [path]);
    return updated;
  }

  Future<List<Map<String, dynamic>>> getItems() async {
    final db = await this.db;
    return db.query('history', orderBy: "time");
  }
}
