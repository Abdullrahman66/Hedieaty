// import 'dart:convert';
//
// import '../db_helper2.dart';
// import '../Models/UserModel.dart';
// import '../Models/GiftModel.dart';
// import '../Models/EventModel.dart';
// import '../Models/FriendsModel.dart';
//
//
// class DatabaseController {
//   final DBHelper _dbHelper = DBHelper();
//
//   // User operations
//   Future<int> insertUser(UserModel user) async => await _dbHelper.insert('Users', user.toMap());
//
//   Future<List<UserModel>> getUsers() async {
//     final result = await _dbHelper.queryAllRows('Users');
//     return result.map((row) => UserModel.fromMap(row)).toList();
//   }
//   Future<List<UserModel>> getUsersWithUpcomingEvents() async {
//     final db = await _dbHelper.database;
//     // final today = DateTime.now().toIso8601String();
//
//     final result = await db.rawQuery('''
//       SELECT u.id, u.name, u.email,u.preferences, COUNT(e.id) as upcomingEvents
//       FROM Users u
//       LEFT JOIN Events e ON u.id = e.userID
//       GROUP BY u.id
//     ''');
//
//     return result.map((row) {
//       return UserModel(
//         id: row['id'] as int,
//         name: row['name'] as String,
//         email: row['email'] as String,
//         preferences: jsonEncode(row['preferences'] ?? {}),
//       );
//     }).toList();
//   }
//
//   // Event operations
//   Future<int> insertEvent(Event event) async => await _dbHelper.insert('Events', event.toMap());
//
//   Future<List<Event>> getEventsByUserId(int userId) async {
//     final db = await _dbHelper.database;
//     final result = await db.query('Events', where: 'userId = ?', whereArgs: [userId]);
//     return result.map((row) => Event.fromMap(row)).toList();
//   }
//
//   // Gift operations
//   Future<int> insertGift(Gift gift) async => await _dbHelper.insert('Gifts', gift.toMap());
//
//   Future<List<Gift>> getGiftsByEventId(int eventId) async {
//     final db = await _dbHelper.database;
//     final result = await db.query('Gifts', where: 'eventId = ?', whereArgs: [eventId]);
//     return result.map((row) => Gift.fromMap(row)).toList();
//   }
//   // Friends operations
//   Future<int> addFriend(Friend friend) async {
//     return await _dbHelper.insert('Friends', friend.toMap());
//   }
//
//
//   Future<List<User>> getFriendsByUserId(int userId) async {
//     final db = await _dbHelper.database;
//     final result = await db.rawQuery('''
//     SELECT Users.* FROM Users
//     INNER JOIN Friends ON Users.id = Friends.friendId
//     WHERE Friends.userId = ?
//   ''', [userId]);
//
//     return result.map((row) => User.fromMap(row)).toList();
//   }
//   Future<int> removeFriend(Friend friend) async {
//     final db = await _dbHelper.database;
//     return await db.delete(
//       'Friends',
//       where: 'userId = ? AND friendId = ?',
//       whereArgs: [friend.userId, friend.friendId],
//     );
//   }
//
// }
