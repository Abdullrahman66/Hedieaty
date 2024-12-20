import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sqflite/sqflite.dart';
import '../db_helper2.dart';

class PledgeModel {
  final int? id; // Local SQLite ID
  final String? firestoreID; // Firestore Document ID
  final String pledgedBy; // User ID of the person who pledged
  final String pledgedTo; // User ID of the person receiving the pledge
  final String giftFirestoreId; // Gift Firestore ID

  PledgeModel({
    this.id,
    this.firestoreID,
    required this.pledgedBy,
    required this.pledgedTo,
    required this.giftFirestoreId,
  });

  /// Convert Pledge to Map for SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firestoreID': firestoreID,
      'pledgedBy': pledgedBy,
      'pledgedTo': pledgedTo,
      'giftFirestoreId': giftFirestoreId,
    };
  }

  /// Create a Pledge from SQLite Map
  factory PledgeModel.fromMap(Map<String, dynamic> map) {
    return PledgeModel(
      id: map['id'],
      firestoreID: map['firestoreID'],
      pledgedBy: map['pledgedBy'],
      pledgedTo: map['pledgedTo'],
      giftFirestoreId: map['giftFirestoreId'],
    );
  }

  /// Firestore Representation
  Map<String, dynamic> toFirestore() {
    return {
      'pledgedBy': pledgedBy,
      'pledgedTo': pledgedTo,
      'giftFirestoreId': giftFirestoreId,
    };
  }

  /// Create Pledge from Firestore Document
  factory PledgeModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PledgeModel(
      firestoreID: doc.id,
      pledgedBy: data['pledgedBy'],
      pledgedTo: data['pledgedTo'],
      giftFirestoreId: data['giftFirestoreId'],
    );
  }

  // SQLite CRUD Operations

  /// Insert Pledge into SQLite
  static Future<int> insertToSQLite(PledgeModel pledge) async {
    final db = await DBHelper().database;
    return await db.insert(
      'Pledge',
      pledge.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Retrieve All Pledges from SQLite
  static Future<List<PledgeModel>> getAllFromSQLite() async {
    final db = await DBHelper().database;
    final results = await db.query('Pledge');
    return results.map((map) => PledgeModel.fromMap(map)).toList();
  }

  /// Retrieve Pledge by ID from SQLite
  static Future<PledgeModel?> getByIdFromSQLite(int id) async {
    final db = await DBHelper().database;
    final results = await db.query(
      'Pledge',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (results.isNotEmpty) {
      return PledgeModel.fromMap(results.first);
    }
    return null;
  }

  /// Update Pledge in SQLite
  static Future<int> updateInSQLite(PledgeModel pledge) async {
    final db = await DBHelper().database;
    return await db.update(
      'Pledge',
      pledge.toMap(),
      where: 'id = ?',
      whereArgs: [pledge.id],
    );
  }

  /// Delete Pledge from SQLite
  static Future<int> deleteFromSQLite(int id) async {
    final db = await DBHelper().database;
    return await db.delete(
      'Pledge',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Firestore CRUD Operations

  /// Save Pledge to Firestore
  static Future<void> saveToFirestore(PledgeModel pledge) async {
    final firestore = FirebaseFirestore.instance;
    await firestore.collection('pledges').add(pledge.toFirestore());
  }

  /// Update Pledge in Firestore
  static Future<void> updateInFirestore(PledgeModel pledge) async {
    if (pledge.firestoreID == null) {
      throw Exception('Firestore ID is null. Cannot update.');
    }
    final firestore = FirebaseFirestore.instance;
    await firestore.collection('pledges').doc(pledge.firestoreID).update(pledge.toFirestore());
  }

  /// Delete Pledge from Firestore
  Future<void> deleteFromFirestore() async {
    if (firestoreID == null) {
      throw Exception('Firestore ID is null. Cannot delete.');
    }
    final firestore = FirebaseFirestore.instance;
    await firestore.collection('pledges').doc(firestoreID).delete();
  }

  /// Fetch Pledges from Firestore
  static Future<List<PledgeModel>> getAllFromFirestore() async {
    final firestore = FirebaseFirestore.instance;
    final querySnapshot = await firestore.collection('pledges').get();
    return querySnapshot.docs.map((doc) => PledgeModel.fromFirestore(doc)).toList();
  }

  /// Fetch pledges of a certain user
  static Future<List<PledgeModel>> getFromFirestoreByUserId(String pledgedTo) async {
    final firestore = FirebaseFirestore.instance;
    final querySnapshot = await firestore.collection('pledges').where('pledgedTo', isEqualTo: pledgedTo).get();
    return querySnapshot.docs.map((doc) => PledgeModel.fromFirestore(doc)).toList();
  }

}
