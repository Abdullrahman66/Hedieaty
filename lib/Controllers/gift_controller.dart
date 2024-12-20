import 'package:cloud_firestore/cloud_firestore.dart';
import '../Models/GiftModel.dart';

class GiftController {
  // Fetch gifts from SQLite
  Future<List<Gift>> getGifts() async {
    return await Gift.getGiftsFromSQLite();
  }

  Future<List<Gift>> getGiftsByEvents({int? eventId, String? firestoreEventId,}) async {
    return await Gift.getGiftsByEventOrFirestoreEventId(eventId: eventId, firestoreEventId: firestoreEventId);
  }

  // Add a new gift to SQLite
  Future<void> addGift(Gift gift) async {
    await Gift.insertGiftToSQLite(gift);
  }

  // Update a gift in SQLite
  Future<void> updateGift(Gift gift) async {
    await Gift.updateGiftInSQLite(gift);
  }

  // Delete a gift from SQLite
  Future<void> deleteGift(int id) async {
    await Gift.deleteGiftFromSQLite(id);
  }

  // Publish a gift to Firestore
  Future<void> publishGift(Gift gift) async {
    await Gift.publishGiftToFirestore(gift);
  }

  Future<List<Gift>> getGiftsByFirestoreEventId(String firestoreEventId) async{
    return await Gift.getGiftsByFirestoreEventId(firestoreEventId);
  }

  Future<void> updateGiftInFirestore (Gift gift) async {
    await Gift.updateGiftInFirestore(gift);
  }

  // Fetch event name associated with a gift
  Future<String> getEventName(int eventId) async {
    // Fetch event name from Firestore
    final firestore = FirebaseFirestore.instance;
    try {
      final eventSnapshot = await firestore.collection('events').doc(eventId.toString()).get();
      if (eventSnapshot.exists) {
        return eventSnapshot['name'];
      } else {
        return 'Unknown Event';
      }
    } catch (e) {
      throw Exception('Error fetching event name: $e');
    }
  }
}
