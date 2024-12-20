import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project_2/Controllers/shared_prefs_controller.dart';
import '../Models/UserModel.dart';
import '../db_helper2.dart';
import 'package:crypto/crypto.dart';

class UserController {

  Future<UserModel> SignUp(String name,String email, String password, String phoneNumber, Map<String, dynamic> preferences) async{
     final FirebaseAuth _auth = FirebaseAuth.instance;
     try{
       final UserCredential credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
       print('Firebase Authentication successful. Credential: ${credential.user}');
       final User? firebaseUser  = credential.user;
       if (firebaseUser == null) {
         throw Exception('Firebase user is null after sign-up.');
       }
       final user = UserModel(
         uid: firebaseUser.uid,
         name: name,
         email: email,
         phoneNumber: phoneNumber,
       );
       user.setPreferences(preferences);
       await user.saveToFirestore(user);
       print("Data saved to Firestore successfully.");
       await UserModel.insertToSQLite(user);
       print("Data saved to sqlite successfully");
       return user;
     } catch(e) {
       throw Exception('Error signing up user: $e');
     }
  }

  Future<UserModel> Login(String email, String password) async {
    if(SharedPrefsHelper().getBool('NotificationsEnable') == null){
      SharedPrefsHelper().putBool('NotificationsEnable', true);
    }

    final FirebaseAuth _auth = FirebaseAuth.instance;
    try{
      final UserCredential credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      print('Firebase Authentication successful. Credential: ${credential.user}');

      // Extract user data from Firebase
      final User? firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw Exception('Firebase user is null after login.');
      }
      final userData = await FirebaseFirestore.instance.collection('users').doc(firebaseUser.uid).get();

      if (!userData.exists) {
        throw Exception('User data not found in Firestore.');
      }

      final data = userData.data()!;
      final user = UserModel(
        uid: firebaseUser.uid,
        name: data['name'] ?? '',
        email: data['email'] ?? email,
        phoneNumber: data['phoneNumber'],
        preferences: jsonEncode(data['preferences'] ?? {}),
      );
      print('User data retrieved successfully: ${user.toMap()}');
      await UserModel.syncUserAndRelatedData(user);
      return user;
    } catch (e) {
      throw Exception('Error logging in: $e');
    }
  }

  Future<List<UserModel>> fetchAllUsers() async {
    try {
      // Fetch the list of users from Firestore
      List<UserModel> users = await UserModel.getFromFirestore();

      print('Fetched ${users.length} users from Firestore.');
      return users;
    } catch (e) {
      throw Exception('Error fetching users from firestore: ${e.toString()}');
    }
  }

  Future<List<UserModel>> fetchUsersFromSqlite() async {
    try{
      List<UserModel> users = await UserModel.getFromSQLite();
      print('Fetched ${users.length} users from SQlite.');
      return users;
    } catch (e) {
      throw Exception('Error fetching users from sqlite: ${e.toString()}');
    }
  }

  Future<List<UserModel>> getFriendsFromFirestore(String userId) async {
    return await UserModel.getFriendsFromFirestore(userId);
  }

  String hashPassword(String password) {
    // Convert the password to a list of bytes
    final bytes = utf8.encode(password);

    // Compute the hash
    final digest = sha256.convert(bytes);

    // Return the hashed value as a hexadecimal string
    return digest.toString();
  }

  Future<void> logout() async {
    try{
      final FirebaseAuth _auth = FirebaseAuth.instance;
      await _auth.signOut();
    } catch(e){
      throw Exception('Error Signing out: ${e.toString()}');
    }

  }

  Future<void> addNotification(String userId, String message) async {
    await UserModel.addNotification(userId, message);
  }

}