import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:file/file.dart';
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _db;

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
    final path = databasePath.toString() + "/"+ "my_database.db";
    print(path);
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE my_table (path TEXT PRIMARY KEY, filename TEXT)',
        );
      },
    );
  }

  Future<int> addItem(String path, filename, ) async {
    final db = await this.db;
    print(path+ " " + filename);
    return await db.insert('my_table', {'path': path, 'filename': filename});
  }

  Future<int> updateItem(String path, String newFilename) async {
    final db = await this.db;
    return await db.update('my_table', {'filename': newFilename}, where: 'path = ?', whereArgs: [path]);
  }

  Future<List<Map<String, dynamic>>> getItems() async {
    final db = await this.db;
    return db.query('my_table');
  }
}