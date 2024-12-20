import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';


class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;

  static Database? _database;

  DBHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'user_app8.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        db.execute('''
          CREATE TABLE Users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            uid TEXT NULL,
            name TEXT NOT NULL,
            email TEXT NOT NULL UNIQUE,
            PhoneNumber TEXT NOT NULL UNIQUE,
            preferences TEXT
          )
        ''');
        db.execute('''
          CREATE TABLE Events (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            firestoreID TEXT NULL,
            name TEXT NOT NULL,
            date TEXT NOT NULL,
            location TEXT NOT NULL,
            category TEXT NOT NULL,
            description TEXT,
            userId TEXT NOT NULL,
            isPublished INTEGER DEFAULT 0,
            FOREIGN KEY (userId) REFERENCES Users (uid)
          )
         ''');
        db.execute('''
          CREATE TABLE Gifts (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            firestoreID TEXT NULL,
            name TEXT NOT NULL,
            description TEXT,
            category TEXT NOT NULL,
            price REAL NOT NULL,
            status TEXT NOT NULL,
            imageURL TEXT NULL,
            eventId INTEGER,
            firestoreEventId TEXT,
            isPublished INTEGER DEFAULT 0,
            FOREIGN KEY (eventId) REFERENCES Events (id),
            FOREIGN KEY (firestoreEventId) REFERENCES Events (firestoreID)
            
          )
        ''');
        db.execute('''
          CREATE TABLE Friends (
            userId INTEGER NOT NULL,
            friendId INTEGER NOT NULL,
            PRIMARY KEY (userId, friendId),
            FOREIGN KEY (userId) REFERENCES Users (id),
            FOREIGN KEY (friendId) REFERENCES Users (id)
          )
        ''');
        // db.execute('''
        //   CREATE TABLE Pledge (
        //     id INTEGER PRIMARY KEY AUTOINCREMENT,
        //     firestoreID TEXT NULL,
        //     pledgedBy TEXT NOT NULL,
        //     pledgedTo TEXT NOT NULL,
        //     giftFirestoreId  TEXT NOT NULL,
        //     FOREIGN KEY (pledgedBy) REFERENCES Users (id),
        //     FOREIGN KEY (pledgedTo) REFERENCES Users (id),
        //     FOREIGN KEY (giftFirestoreId) REFERENCES Gifts (firestoreID)
        //   )
        // ''');
      },
    );
  }

  Future<int> insert(String table, Map<String, dynamic> values) async {
    final db = await database;
    return await db.insert(table, values);
  }

  Future<List<Map<String, dynamic>>> queryAllRows(String table) async {
    final db = await database;
    return await db.query(table);
  }

  Future<int> update(String table, Map<String, dynamic> values, String where, List<dynamic> whereArgs) async {
    final db = await database;
    return await db.update(table, values, where: where, whereArgs: whereArgs);
  }

  Future<int> delete(String table, String where, List<dynamic> whereArgs) async {
    final db = await database;
    return await db.delete(table, where: where, whereArgs: whereArgs);
  }
}
