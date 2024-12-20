import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sqflite/sqflite.dart';

import '../db_helper2.dart';

class Gift {
  final int? id;
  final String? firestoreID;
  final String name;
  final String description;
  final String category;
  final double price;
  final String status;
  final String? imageURL;
  final int? eventId;
  final String? firestoreEventId;
  bool isPublished;

  Gift({this.id, required this.firestoreID, required this.name, required this.description, required this.category, required this.price, required this.status, this.imageURL, this.eventId, this.firestoreEventId, this.isPublished=false});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firestoreID': firestoreID,
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'status': status,
      'imageURL': imageURL,
      'eventId': eventId,
      'firestoreEventId': firestoreEventId,
      'isPublished': isPublished ? 1 : 0
    };
  }

  factory Gift.fromMap(Map<String, dynamic> map) {
    return Gift(
      id: map['id'],
      firestoreID: map['firestoreID'],
      name: map['name'],
      description: map['description'],
      category: map['category'],
      price: map['price'],
      status: map['status'],
      imageURL: map['imageURL'],
      eventId: map['eventId'],
      firestoreEventId: map['firestoreEventId'],
      isPublished: map['isPublished'] == 1
    );
  }

  static Future<void> insertGiftToSQLite(Gift gift) async {
    final db = await DBHelper().database;
    try{
      await db.insert(
        'Gifts',
        gift.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('Gift inserted into SQLite: ${gift.name}');
    } catch(e) {
      throw Exception('Error inserting Gift to sqlite: ${e.toString()}');
    }
  }

// Get Gifts from SQLite
  static Future<List<Gift>> getGiftsFromSQLite() async {
    final db = await DBHelper().database;
    final List<Map<String, dynamic>> maps = await db.query('Gifts');
    try {
      return maps.map((map) => Gift.fromMap(map)).toList();

    } catch(e) {
      throw Exception('Error retrieving Gifts from SQLite: ${e.toString()}');
    }
  }

  // Retrieve Gifts by eventId or firestoreEventId
  static Future<List<Gift>> getGiftsByEventOrFirestoreEventId({int? eventId, String? firestoreEventId,}) async {
    if (eventId == null && firestoreEventId == null) {
      throw ArgumentError('Either eventId or firestoreEventId must be provided.');
    }

    final db = await DBHelper().database;

    try {
      String whereClause = '';
      List<dynamic> whereArgs = [];

      if (eventId != null) {
        whereClause = 'eventId = ?';
        whereArgs.add(eventId);
      }

      if (firestoreEventId != null) {
        if (whereClause.isNotEmpty) {
          whereClause += ' OR ';
        }
        whereClause += 'firestoreEventId = ?';
        whereArgs.add(firestoreEventId);
      }

      final List<Map<String, dynamic>> maps = await db.query(
        'Gifts',
        where: whereClause,
        whereArgs: whereArgs,
      );

      return maps.map((map) => Gift.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Error retrieving Gifts from SQLite: ${e.toString()}');
    }
  }

  static Future<int?> getIdByFirestoreID(String firestoreID) async {
    final db = await DBHelper().database;
    final List<Map<String, dynamic>> result = await db.query(
      'Gifts', // Your table name
      columns: ['id'], // Only fetch the 'id' column
      where: 'firestoreID = ?', // Condition
      whereArgs: [firestoreID], // Replace '?' with this value
      limit: 1, // Fetch only 1 result for efficiency
    );

    if (result.isNotEmpty) {
      return result.first['id'] as int?; // Return the 'id' field
    } else {
      return null; // No matching record found
    }
  }

  // Update Gift in SQLite
  static Future<void> updateGiftInSQLite(Gift gift) async {
    final db = await DBHelper().database;
    try {
      await db.update(
        'Gifts',
        gift.toMap(),
        where: 'id = ?',
        whereArgs: [gift.id],
      );
      print('Gift updated in SQLite: ${gift.name}');
    } catch (e) {
      throw Exception('Error updating Gift in SQLite: ${e.toString()}');
    }
  }

  static Future<void> updateGiftWithFirestoreIdInSQlite(Gift gift) async {
    final db = await DBHelper().database;
    try{
      await db.update(
        'Gifts',
        gift.toMap(),
        where: 'firestoreID = ?',
        whereArgs: [gift.firestoreID],
      );
      print('Gift updated in SQLite: ${gift.name}');
    } catch (e) {
      throw Exception('Error updating Gift in SQLite: ${e.toString()}');
    }
  }

  // Delete Gift from SQLite
  static Future<void> deleteGiftFromSQLite(int id) async {
    final db = await DBHelper().database;
    try {
      await db.delete(
        'Gifts',
        where: 'id = ?',
        whereArgs: [id],
      );
      print('Gift deleted from SQLite with id: $id');
    } catch (e) {
      throw Exception('Error deleting Gift from SQLite: ${e.toString()}');
    }
  }

  // Insert Gift into Firestore
  static Future<void> publishGiftToFirestore(Gift gift) async {
    final firestore = FirebaseFirestore.instance;
    try {
      DocumentReference docRef = await firestore.collection('gifts').add({
        'name': gift.name,
        'category': gift.category,
        'description': gift.description,
        'price': gift.price,
        'status': gift.status,
        'imageURL': gift.imageURL,
        'firestoreEventId': gift.firestoreEventId,
      });
      print('Gift inserted into Firestore: ${gift.name}');

      // Update sqlite with firestore document ID
      final db = await DBHelper().database;
      await db.update(
        'Gifts',
        {'firestoreID': docRef.id, 'isPublished': 1},
        where: 'id = ?',
        whereArgs: [gift.id],
      );
      print('Updated firestore id and ispublished');
    } catch(e) {
      throw Exception('Error inserting Gifts to Firestore: ${e.toString()}');
    }
  }

  static Future<List<Gift>> getGiftsFromFirestore() async {
    final firestore = FirebaseFirestore.instance;
    try{
      final querySnapshot = await firestore.collection('gifts').get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return Gift(
          firestoreID: doc.id,
          name: data['name'],
          category: data['category'],
          description: data['description'],
          price: data['price'],
          status: data['status'],
          imageURL: data['imageURL'] ?? '',
          firestoreEventId: data['firestoreEventId'],
          isPublished: true,
        );
      }).toList();
    } catch(e) {
      throw Exception('Error fetching Gifts from Firestore: ${e.toString()}');
    }
  }

  // Update Gift in Firestore
  static Future<void> updateGiftInFirestore(Gift gift) async {
    final firestore = FirebaseFirestore.instance;
    try {
      await firestore.collection('gifts').doc(gift.firestoreID).update({
        'name': gift.name,
        'category': gift.category,
        'description': gift.description,
        'price': gift.price,
        'status': gift.status,
        'imageURL': gift.imageURL,
        'firestoreEventId': gift.firestoreEventId,
      });
      print('Gift updated in Firestore: ${gift.name}');
    } catch (e) {
      throw Exception('Error updating Gift in Firestore: ${e.toString()}');
    }
  }

  // Fetch Gifts from Firestore based on Firestore Event ID
  static Future<List<Gift>> getGiftsByFirestoreEventId(String firestoreEventId) async {
    final firestore = FirebaseFirestore.instance;
    try {
      final querySnapshot = await firestore
          .collection('gifts')
          .where('firestoreEventId', isEqualTo: firestoreEventId)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return Gift(
          firestoreID: doc.id,
          name: data['name'],
          category: data['category'],
          description: data['description'],
          price: data['price'],
          status: data['status'],
          imageURL: data['imageURL'] ?? '',
          firestoreEventId: data['firestoreEventId'],
          isPublished: true,
        );
      }).toList();
    } catch (e) {
      throw Exception('Error fetching Gifts by Firestore Event ID: ${e.toString()}');
    }
  }

  /// Retrieve Gift by Firestore UID
  static Future<Gift?> getGiftByFirestoreId(String uid) async {
    try {
      final firestore = FirebaseFirestore.instance;

      // Fetch the user document from Firestore by its document ID
      final doc = await firestore.collection('gifts').doc(uid).get();

      if (doc.exists) {
        final data = doc.data();
        if (data != null) {
          return Gift(
            firestoreID: doc.id,
            name: data['name'],
            category: data['category'],
            description: data['description'],
            price: data['price'],
            status: data['status'],
            imageURL: data['imageURL'] ?? '',
            firestoreEventId: data['firestoreEventId'],
            isPublished: true,
          );
        }
      }

      return null; // Return null if the user does not exist
    } catch (e) {
      print('Error retrieving Gift by Firestore UID: $e');
      throw Exception('Error retrieving gift: $e');
    }
  }

  // Delete Gift from Firestore
  static Future<void> deleteGiftFromFirestore(String firestoreID) async {
    final firestore = FirebaseFirestore.instance;
    try {
      await firestore.collection('gifts').doc(firestoreID).delete();
      print('Gift deleted from Firestore with id: $firestoreID');
    } catch (e) {
      throw Exception('Error deleting Gift from Firestore: ${e.toString()}');
    }
  }

}
