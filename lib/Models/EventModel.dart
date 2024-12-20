import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_2/db_helper2.dart';
import 'package:sqflite/sqflite.dart';
import './GiftModel.dart';

class Event {
  final int? id;
  final String? firestoreID;
  final String name;
  final String date;
  final String location;
  final String category;
  final String description;
  final String userId;
  bool isPublished;

  Event({this.id, this.firestoreID, required this.name, required this.date, required this.location, required this.category, required this.description, required this.userId, this.isPublished=false});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firestoreID': firestoreID,
      'name': name,
      'date': date,
      'location': location,
      'category': category,
      'description': description,
      'userId': userId,
      'isPublished': isPublished ? 1 : 0
    };
  }

  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'],
      firestoreID: map['firestoreID'],
      name: map['name'],
      date: map['date'],
      location: map['location'],
      category: map['category'],
      description: map['description'],
      userId: map['userId'],
      isPublished: map['isPublished'] == 1
    );
  }

  static Future<void> insertEventToSQLite(Event event) async {
    final db = await DBHelper().database;
    try{
      await db.insert(
        'Events',
        event.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('Event inserted into SQLite: ${event.name}');
    } catch(e) {
      throw Exception('Error inserting Event to sqlite: ${e.toString()}');
    }

  }

  static Future<int?> getIdByFirestoreID(String firestoreID) async {
    final db = await DBHelper().database;
    final List<Map<String, dynamic>> result = await db.query(
      'Events', // Your table name
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

  // Get Events from SQLite
  static Future<List<Event>> getEventsFromSQLite() async {
    final db = await DBHelper().database;
    final List<Map<String, dynamic>> maps = await db.query('Events');
    try {
      return maps.map((map) => Event.fromMap(map)).toList();

    } catch(e) {
      throw Exception('Error retrieving Events from SQLite: ${e.toString()}');
    }
  }

  // Get Events by User ID
  static Future<List<Event>> getEventsByUserId(String userId) async {
    final db = await DBHelper().database;
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        'Events',
        where: 'userId = ?',
        whereArgs: [userId],
      );
      return maps.map((map) => Event.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Error fetching Events for user ID $userId: ${e.toString()}');
    }
  }


  // Update Event in SQLite
  static Future<void> updateEventInSQLite(Event event) async {
    final db = await DBHelper().database;
    try {
      await db.update(
        'Events',
        event.toMap(),
        where: 'id = ?',
        whereArgs: [event.id],
      );
      print('Event updated in SQLite: ${event.name}');
    } catch (e) {
      throw Exception('Error updating Event in SQLite: ${e.toString()}');
    }
  }

  static Future<void> updateEventWithFirestorIDInSQlite(Event event) async {
    final db = await DBHelper().database;

    try{
      await db.update(
        'Events',
        event.toMap(),
        where: 'firestoreID = ?',
        whereArgs: [event.firestoreID],
      );
      print('Event updated in SQLite: ${event.name}');
    } catch (e) {
      throw Exception('Error updating Event in SQLite: ${e.toString()}');
    }

  }

  // Delete Event from SQLite
  static Future<void> deleteEventFromSQLite(int? eventId, String? firestoreEventID) async {
    if (eventId == null && firestoreEventID == null) {
      throw ArgumentError('Either eventId or firestoreEventId must be provided.');
    }
    final db = await DBHelper().database;

    try {
      // Delete associated gifts (matching either eventID or firestoreEventID)
      if (firestoreEventID != null) {
        await db.delete(
          'Gifts',
          where: 'eventId = ? OR firestoreEventId = ?',
          whereArgs: [eventId, firestoreEventID],
        );
      } else {
        await db.delete(
          'Gifts',
          where: 'eventId = ?',
          whereArgs: [eventId],
        );
      }
      print('Associated gifts deleted for event ID: $eventId and Firestore ID: $firestoreEventID.');

      // Delete event
      await db.delete(
        'Events',
        where: 'id = ?',
        whereArgs: [eventId],
      );
      print('Event deleted from SQLite with ID: $eventId.');
    } catch (e) {
      throw Exception('Error deleting event and associated gifts: ${e.toString()}');
    }
  }

  /// Publish Event and Update Associated Gifts
  static Future<void> publishEventToFirestore(Event event) async {
    final firestore = FirebaseFirestore.instance;
    final db = await DBHelper().database;

    try {
      // Publish event to Firestore
      DocumentReference docRef = await firestore.collection('events').add({
        'name': event.name,
        'date': event.date,
        'location': event.location,
        'category': event.category,
        'description': event.description,
        'userId': event.userId,
      });

      // Update event in SQLite with Firestore ID and set as published
      await db.update(
        'Events',
        {'firestoreID': docRef.id, 'isPublished': 1},
        where: 'id = ?',
        whereArgs: [event.id],
      );

      print('Event published to Firestore and updated in SQLite.');

      // Fetch associated gifts and update their Firestore Event ID
      final List<Map<String, dynamic>> giftMaps = await db.query(
        'Gifts',
        where: 'eventId = ?',
        whereArgs: [event.id],
      );

      for (var giftMap in giftMaps) {
        Gift gift = Gift.fromMap(giftMap);
        // Update gift in SQLite
        await db.update(
          'Gifts',
          {'firestoreEventId': docRef.id},
          where: 'id = ?',
          whereArgs: [gift.id],
        );

        print('Gift updated with Firestore Event ID: ${gift.name}');
      }
    } catch (e) {
      throw Exception('Error publishing event and updating gifts: ${e.toString()}');
    }
  }

  // Get Events from Firestore
  static Future<List<Event>> getEventsFromFirestore() async {
    final firestore = FirebaseFirestore.instance;
    try{
      final querySnapshot = await firestore.collection('events').get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return Event(
          firestoreID: doc.id,
          name: data['name'],
          date: data['date'],
          location: data['location'],
          category: data['category'],
          description: data['description'],
          userId: data['userId'],
          isPublished: true,
        );
      }).toList();
    } catch(e) {
      throw Exception('Error fetching Events from Firestore: ${e.toString()}');
    }

  }

  /// Fetch Events from Firestore for a Specific User
  static Future<List<Event>> getEventsFromFirestoreByUser(String userId) async {
    final firestore = FirebaseFirestore.instance;

    try {
      // Query Firestore for events with the specified userId
      final querySnapshot = await firestore
          .collection('events')
          .where('userId', isEqualTo: userId)
          .get();

      // Map Firestore documents to Event instances
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return Event(
          firestoreID: doc.id,
          name: data['name'],
          date: data['date'],
          location: data['location'],
          category: data['category'],
          description: data['description'],
          userId: data['userId'],
          isPublished: true,
        );
      }).toList();
    } catch (e) {
      throw Exception('Error fetching events for user $userId from Firestore: ${e.toString()}');
    }
  }

  // Update Event in Firestore
  static Future<void> updateEventInFirestore(Event event) async {
    final firestore = FirebaseFirestore.instance;
    try {
      await firestore.collection('events').doc(event.firestoreID).update({
        'name': event.name,
        'date': event.date,
        'location': event.location,
        'category': event.category,
        'description': event.description,
        'userId': event.userId,
      });
      print('Event updated in Firestore: ${event.name}');
    } catch (e) {
      throw Exception('Error updating Event in Firestore: ${e.toString()}');
    }
  }
  // Delete Event and Associated Gifts from Firestore
  static Future<void> deleteEventFromFirestore(String firestoreId) async {
    final firestore = FirebaseFirestore.instance;

    try {
      // Delete associated gifts in Firestore based on Firestore Event ID
      final querySnapshot = await firestore
          .collection('gifts')
          .where('firestoreEventId', isEqualTo: firestoreId)
          .get();

      for (var doc in querySnapshot.docs) {
        await firestore.collection('gifts').doc(doc.id).delete();
        print('Deleted gift from Firestore with ID: ${doc.id}');
      }
      print('All gifts associated with Firestore Event ID: $firestoreId deleted.');

      // Delete the event from Firestore
      await firestore.collection('events').doc(firestoreId).delete();
      print('Event deleted from Firestore with ID: $firestoreId.');
    } catch (e) {
      throw Exception('Error deleting Event and associated gifts from Firestore: ${e.toString()}');
    }
  }

  Future<bool> hasPledgedGifts() async {
    final db = await DBHelper().database;

    try {
      // Query the gifts associated with this event
      final List<Map<String, dynamic>> giftMaps = await db.query(
        'Gifts',
        where: 'eventId = ? AND status = ?',
        whereArgs: [id, 'Pledged'],
      );

      // Return true if any gifts have the status 'Pledged', otherwise false
      return giftMaps.isNotEmpty;
    } catch (e) {
      throw Exception('Error checking for pledged gifts: ${e.toString()}');
    }
  }

}


