import 'package:sqflite/sqflite.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Models/FriendsModel.dart';

class FriendController {


  // Add a friend to SQLite
  Future<void> addFriendToSQLite(String userId, String friendId) async {
    Friend friend = Friend(userId: userId, friendId: friendId);
    await Friend.addFriendToSQLite(friend);
  }

  // Add a friend to Firestore
  Future<void> addFriendToFirestore(String userId, String friendId) async {
    Friend friend = Friend(userId: userId, friendId: friendId);
    await Friend.addFriendToFirestore(friend);
  }

  // Get all friends for a user from SQLite
  Future<List<Friend>> getFriendsFromSQLite(String userId) async {
    return await Friend.getFriendsFromSQLite(userId);
  }

  // Delete a friend from SQLite
  Future<void> deleteFriendFromSQLite(String userId, String friendId) async {
    await Friend.deleteFriendFromSQLite(userId, friendId);
  }

  // Delete a friend from Firestore
  Future<void> deleteFriendFromFirestore(String documentId) async {
    await Friend.deleteFriendFromFirestore(documentId);
  }

  // Update a friendship in SQLite
  Future<void> updateFriendInSQLite(Friend oldFriend, Friend newFriend) async {
    await Friend.updateFriendInSQLite(oldFriend, newFriend);
  }

  // Update a friendship in Firestore
  Future<void> updateFriendInFirestore(String documentId, Friend updatedFriend) async {
    await Friend.updateFriendInFirestore(documentId, updatedFriend);
  }
}
