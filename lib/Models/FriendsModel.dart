import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_2/db_helper2.dart';
import 'package:sqflite/sqflite.dart';

class Friend {
  final String userId;
  final String friendId;

  Friend({required this.userId, required this.friendId});

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'friendId': friendId,
    };
  }

  factory Friend.fromMap(Map<String, dynamic> map) {
    return Friend(
      userId: map['userId'],
      friendId: map['friendId'],
    );
  }

  // Add a friend to SQLite
  static Future<void> addFriendToSQLite(Friend friend) async {
    try{
      final db = await DBHelper().database;
      await db.insert(
        'Friends',
        friend.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('Friend inserted into SQLite: ${friend.friendId}');
    } catch(e) {
     throw Exception('Error inserting Friend to sqlite: ${e.toString()}');
    }
  }

  // Get all friends for a user from SQLite
  static Future<List<Friend>> getFriendsFromSQLite(String userId) async {
    try{
      final db = await DBHelper().database;
      final List<Map<String, dynamic>> maps = await db.query(
        'Friends',
        where: 'userId = ?',
        whereArgs: [userId],
      );

      return List.generate(maps.length, (i) {
        return Friend.fromMap(maps[i]);
      });
    } catch(e) {
      throw Exception('Error fetching Friends from sqlite: ${e.toString()}');
    }
  }

  // Update a friendship in SQLite
  static Future<void> updateFriendInSQLite(Friend oldFriend, Friend newFriend) async {
    final db = await DBHelper().database;
    await db.update(
      'Friends',
      newFriend.toMap(),
      where: 'userId = ? AND friendId = ?',
      whereArgs: [oldFriend.userId, oldFriend.friendId],
    );
  }


  // Delete a friend from SQLite
  static Future<void> deleteFriendFromSQLite(String userId, String friendId) async {
    try{
      final db = await DBHelper().database;
      await db.delete(
        'Friends',
        where: 'userId = ? AND friendId = ?',
        whereArgs: [userId, friendId],
      );
    } catch(e){
      throw Exception('Error deleting Friend from sqlite: ${e.toString()}');
    }
  }

  // Add a friend to Firestore
  static Future<void> addFriendToFirestore(Friend friend) async {
    try {
      final firestore = FirebaseFirestore.instance;
      await firestore.collection('friends').add(friend.toMap());
    } catch(e) {
      throw Exception('Error Inserting Friend to firestore: ${e.toString()}');
    }
  }

  // Get all friends for a user from Firestore
  static Future<List<Friend>> getFriendsFromFirestore(String userId) async {
    try{
      final firestore = FirebaseFirestore.instance;
      final QuerySnapshot querySnapshot = await firestore.collection('friends')
          .where('userId', isEqualTo: userId)
          .get();

      return querySnapshot.docs.map((doc) {
        return Friend.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch(e) {
      throw Exception('Error fetching Friends from firestore: ${e.toString()}');
    }
  }

  // Update a friendship in Firestore
  static Future<void> updateFriendInFirestore(String documentId, Friend updatedFriend) async {
    final firestore = FirebaseFirestore.instance;
    await firestore.doc(documentId).update(updatedFriend.toMap());
  }

  // Delete a friend from Firestore
  static Future<void> deleteFriendFromFirestore(String documentId) async {
    final firestore = FirebaseFirestore.instance;
    await firestore.doc(documentId).delete();
  }
}
