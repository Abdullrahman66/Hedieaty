import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project_2/db_helper2.dart';
import 'package:sqflite/sqflite.dart';
import './EventModel.dart';
import './GiftModel.dart';

class UserModel {
  final int? id;
  final String uid;
  final String name;
  final String email;
  final String? phoneNumber;
  String preferences;

  UserModel({this.id, required this.uid, required this.name, required this.email, this.phoneNumber, this.preferences=''});

  // Convert User to a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uid': uid,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'preferences': preferences,
    };
  }

  // Create a User from a Map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      uid: map['uid'],
      name: map['name'],
      email: map['email'],
      phoneNumber: map['phoneNumber'],
      preferences: map['preferences'] ?? '',
    );
  }
  // Parse preferences JSON string into a Map
  Map<String, dynamic> getPreferences() {
    return preferences.isNotEmpty ? jsonDecode(preferences) : {};
  }

  // Set preferences as a JSON string
  void setPreferences(Map<String, dynamic> prefs) {
    preferences = jsonEncode(prefs);
  }

  // SQLite Operations
  // Save user in sqlite
  static Future<int> insertToSQLite(UserModel user) async {
    final db = await DBHelper().database;
    return await db.insert(
      'Users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  // Query all users in sqlite
  static Future<List<UserModel>> getFromSQLite() async {
    final db = await DBHelper().database;
    final users = await db.query('Users'); // Query the Users table
    return users.map((map) => UserModel.fromMap(map)).toList();
  }

  // Update User in SQLite
  static Future<void> updateUserInSQLite(UserModel user) async {
    final db = await DBHelper().database;
    try {
      await db.update(
        'Users',
        user.toMap(),
        where: 'id = ?', // Filter by local SQLite ID
        whereArgs: [user.id],
      );
      print('User updated in SQLite: ${user.name}');
    } catch (e) {
      throw Exception('Error updating user in SQLite: ${e.toString()}');
    }
  }

  static Future<int?> getIdByFirestoreID(String firestoreID) async {
    final db = await DBHelper().database;
    final List<Map<String, dynamic>> result = await db.query(
      'Users', // Your table name
      columns: ['id'], // Only fetch the 'id' column
      where: 'uid = ?', // Condition
      whereArgs: [firestoreID], // Replace '?' with this value
      limit: 1, // Fetch only 1 result for efficiency
    );

    if (result.isNotEmpty) {
      return result.first['id'] as int?; // Return the 'id' field
    } else {
      return null; // No matching record found
    }
  }

  static Future<UserModel?> getUserWithEmail(String email) async {
    try {
      final db = await DBHelper().database;
      UserModel? user;
      final List<Map<String, dynamic>> localUsers = await db.query(
        'Users',
        where: 'email = ?',
        whereArgs: [email],
      );
      if (localUsers.isNotEmpty) {
        // Step 2: User exists in SQLite
        final userMap = localUsers.first;
        print('User found in SQLite: $userMap');

        // Convert the SQLite data to a UserModel
        user = UserModel.fromMap(userMap);
      }
      return user; // Return the user (null if not found)
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }

  // Firestore operations
  // Inserting into firestore
  Future<void> saveToFirestore(UserModel user) async {
    try {
      final firestore = FirebaseFirestore.instance;
      await firestore.collection('users').doc(user.uid).set({
        'name': user.name,
        'email': user.email,
        'phoneNumber': user.phoneNumber,
        'preferences': user.getPreferences(),
      });
    } catch (e) {
      print('Error: ${e}');
      throw Exception('Error saving user to Firestore: ${e.toString()}');
    }
  }

  // Update User in Firestore
  static Future<void> updateUserInFirestore(UserModel user) async {
    try {
      final firestore = FirebaseFirestore.instance;

      await firestore.collection('users').doc(user.uid).update({
        'name': user.name,
        'email': user.email,
        'phoneNumber': user.phoneNumber,
        'preferences': user.getPreferences(),
      });
      print('User updated in Firestore: ${user.name}');
    } catch (e) {
      throw Exception('Error updating user in Firestore: ${e.toString()}');
    }
  }

  Future<void> updateEmailAndPassword(String newEmail, String newPassword) async {
    final db = await DBHelper().database;

    try {
      // Update SQLite
      await db.update(
        'Users',
        {'email': newEmail}, // Update email only (password management depends on Firebase)
        where: 'id = ?',
        whereArgs: [id],
      );

    } catch (e) {
      throw Exception('Error updating email: $e');
    }

    try {
      // Update email in Firebase Authentication
      final auth = FirebaseAuth.instance;
      User? firebaseUser = auth.currentUser;
      if (firebaseUser != null) {
        await firebaseUser.updateEmail(newEmail);
        if (newPassword.isNotEmpty) {
          await firebaseUser.updatePassword(newPassword);
        }
      }

      // Update email in Firestore
      final firestore = FirebaseFirestore.instance;
      await firestore.collection('users').doc(uid).update({'email': newEmail});
      print('Email and password updated successfully.');
    } catch (e) {
      throw Exception('Error updating email and password: ${e.toString()}');
    }
  }

  static Future<void> updateEmail(String newEmail) async {
    final db = await DBHelper().database;

    try {
      // Update SQLite
      // await db.update(
      //   'Users',
      //   {'email': newEmail}, // Update email only
      //   where: 'id = ?',
      //   whereArgs: [id],
      // );

      // Update email in Firebase Authentication
      final auth = FirebaseAuth.instance;
      User? firebaseUser = auth.currentUser;
      if (firebaseUser != null) {
        await firebaseUser.updateEmail(newEmail);
        print('Entered the forbidden if cond.');
      } else{
        print('firebase user is null');
      }

      // Update email in Firestore
      // final firestore = FirebaseFirestore.instance;
      // await firestore.collection('users').doc(uid).update({'email': newEmail});

      print('Email updated successfully.');
    } catch (e) {
      print(e.toString());
      throw Exception('Error updating email: $e');
    }
  }

  static Future<void> updatePassword(String newPassword) async {
    if (newPassword.isEmpty) {
      throw Exception('Password cannot be empty.');
    }

    try {
      final auth = FirebaseAuth.instance;
      User? firebaseUser = auth.currentUser;
      if (firebaseUser != null) {
        await firebaseUser.updatePassword(newPassword);
      }

      print('Password updated successfully.');
    } catch (e) {
      throw Exception('Error updating password: $e');
    }
  }

  static Future<List<UserModel>> getFromFirestore() async {
    try {
      final firestore = FirebaseFirestore.instance;

      // Fetch all documents in the 'users' collection
      final querySnapshot = await firestore.collection('users').get();

      // Map Firestore documents to a list of UserModel instances
      return querySnapshot.docs.map((doc) {
        final data = doc.data();

        // Parse preferences if they exist
        final preferences = data['preferences'] != null ? jsonEncode(data['preferences']) : '';

        return UserModel(
          uid: doc.id,
          name: data['name'],
          email: data['email'],
          phoneNumber: data['phoneNumber'],
          preferences: preferences,
        );
      }).toList();
    } catch (e) {
      print('Error fetching users from Firestore: $e');
      throw Exception('Error fetching users from Firestore: $e');
    }
  }

  /// Retrieve User by Firestore UID
  static Future<UserModel?> getUserByFirestoreId(String uid) async {
    try {
      final firestore = FirebaseFirestore.instance;

      // Fetch the user document from Firestore by its document ID
      final doc = await firestore.collection('users').doc(uid).get();

      if (doc.exists) {
        final data = doc.data();
        if (data != null) {
          return UserModel(
            uid: doc.id,
            name: data['name'],
            email: data['email'],
            phoneNumber: data['phoneNumber'],
            preferences: jsonEncode(data['preferences'] ?? {}),
          );
        }
      }

      return null; // Return null if the user does not exist
    } catch (e) {
      print('Error retrieving user by Firestore UID: $e');
      throw Exception('Error retrieving user: $e');
    }
  }

  /// Retrieve friends of the user from Firestore
  static Future<List<UserModel>> getFriendsFromFirestore(String userId) async {
    try {
      final firestore = FirebaseFirestore.instance;

      // Query the Friends collection for documents where the user is either userId or friendId
      final querySnapshot = await firestore.collection('friends').where('userId', isEqualTo: userId).get();

      final friendIds = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return data['friendId'];
      }).toList();

      // If no friends are found, return an empty list
      if (friendIds.isEmpty) {
        return [];
      }

      // Fetch user details for all friend IDs
      final friendsQuery = await firestore.collection('users').where(FieldPath.documentId, whereIn: friendIds).get();

      return friendsQuery.docs.map((doc) {
        final data = doc.data();
        return UserModel(
          uid: doc.id,
          name: data['name'],
          email: data['email'],
          phoneNumber: data['phoneNumber'],
          preferences: jsonEncode(data['preferences'] ?? {}),
        );
      }).toList();
    } catch (e) {
      print('Error fetching friends: $e');
      throw Exception('Error fetching friends: $e');
    }
  }

  static Future<void> syncUserAndRelatedData(UserModel user) async {
    final db = await DBHelper().database;

    try {
      // Check if the user exists in SQLite
      final existingUser = await db.query(
        'Users',
        where: 'uid = ?',
        whereArgs: [user.uid],
      );

      if (existingUser.isNotEmpty) {
        // Update user if they exist
        final id = await getIdByFirestoreID(user.uid);
        final newUser = UserModel(
            id: id,
            uid: user.uid,
            name: user.name,
            email: user.email,
          phoneNumber: user.phoneNumber,
          preferences: user.preferences
        );
        await updateUserInSQLite(newUser);
        print('User updated in SQLite: ${user.name}');
      } else {
        // Insert user if they don't exist
        await insertToSQLite(user);
        print('User inserted into SQLite: ${user.name}');
      }

      // Retrieve events specific to this user
      final events = await Event.getEventsFromFirestoreByUser(user.uid);

      for (final event in events) {
        final existingEvent = await db.query(
          'Events',
          where: 'firestoreID = ?',
          whereArgs: [event.firestoreID],
        );

        if (existingEvent.isNotEmpty) {
          final id = await Event.getIdByFirestoreID(event.firestoreID!);
          final newEvent = Event(
              id: id ,
              firestoreID: event.firestoreID,
              name: event.name,
              date: event.date,
              location: event.location,
              category: event.category,
              description: event.description,
              userId: event.userId,
              isPublished: event.isPublished
          );
          await Event.updateEventInSQLite(newEvent);
        } else {
          await Event.insertEventToSQLite(event);
        }

        // Retrieve gifts specific to this event
        final gifts = await Gift.getGiftsByFirestoreEventId(event.firestoreID!);

        for (final gift in gifts) {
          final existingGift = await db.query(
            'Gifts',
            where: 'firestoreID = ?',
            whereArgs: [gift.firestoreID],
          );

          if (existingGift.isNotEmpty) {
            final id = await Gift.getIdByFirestoreID(gift.firestoreID!);
            final newGift = Gift(
                id: id,
                firestoreID: gift.firestoreID,
                name: gift.name,
                description: gift.description,
                category: gift.category,
                price: gift.price,
                status: gift.status,
                imageURL: gift.imageURL ?? '',
                eventId: gift.eventId,
                firestoreEventId: gift.firestoreEventId,
                isPublished: gift.isPublished
            );
            await Gift.updateGiftWithFirestoreIdInSQlite(newGift);
          } else {
            await Gift.insertGiftToSQLite(gift);
          }
        }
      }

      print('User and related data synchronized successfully.');
    } catch (e) {
      throw Exception('Error synchronizing user and related data: ${e.toString()}');
    }
  }

  static Future<void> addNotification(String userId, String message) async {
    final notificationData = {
      'userId': userId,
      'message': message,
      'timestamp': DateTime.now().toIso8601String(),
      'isRead': false,
    };

    await FirebaseFirestore.instance.collection('notifications').add(notificationData);
  }


}
