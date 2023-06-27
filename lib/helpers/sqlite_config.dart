import 'package:sangu/models/sangu_model.dart';
import 'package:sqflite/sqflite.dart';

class SqliteConfig {
  static Database? _database;
  static const String _tableSangu = 'sangu';

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await initDB();
    return _database!;
  }

  initDB() async {
    var path = await getDatabasesPath();
    var db = openDatabase(
      "$path/sangu.db",
      onCreate: (Database db, int version) async {
        await db.execute(
            'CREATE TABLE $_tableSangu (id INTEGER PRIMARY KEY, image TEXT)'
        );
        print('DB Created');
      },
      version: 1,
    );
    return db;
  }

  Future insertSangu(SanguModel model) async{
    final Database db = await database;
    if (db != null) {
      try {
        await db.insert(_tableSangu, model.toMap());
        print('Data inserted');
      } catch (_) {
        print('Error inserting data');
      }
    } else {
      print('Error: Database is not initialized');
    }
  }

  Future<List<SanguModel>> getSangus() async {
    final Database db = await database;
    List<Map<String, dynamic>> results = await db.query(_tableSangu);
    return results.map((res) => SanguModel.fromMap(res)).toList();
  }

  /*
  Future<void> insertCatatan(CatatanModel catatanModel) async{
    final Database db = await database;
    if (db != null) {
      try {
        await db.insert(_TABLE_CATATAN, catatanModel.toMap());
        print('Data inserted');
      } catch (_) {
        print('Error inserting data');
      }
    } else {
      print('Error: Database is not initialized');
    }
  }

  Future<List<CatatanModel>> getCatatans(String owner) async {
    final Database db = await database;
    List<Map<String, dynamic>> results = await db.query(_TABLE_CATATAN, where: 'owner = ?', whereArgs: [owner]);
    return results.map((res) => CatatanModel.fromMap(res)).toList();
  }

  Future<void> deleteCatatan(CatatanModel catatanModel) async {
    final Database db = await database;
    await db.delete(_TABLE_CATATAN, where: 'id = ?', whereArgs: [catatanModel.id]);
  }

  Future<void> updateCatatan(CatatanModel catatanModel) async {
    final Database db = await database;
    await db.update(_TABLE_CATATAN, catatanModel.toMap(), where: 'id = ?', whereArgs: [catatanModel.id]);
  }*/
}