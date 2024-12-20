import 'package:cloud_firestore/cloud_firestore.dart';

import '../Models/EventModel.dart';

class EventController {
  // Fetch all events from SQLite
  Future<List<Event>> getEvents(String userId) async {
    try {
      return await Event.getEventsByUserId(userId);
    } catch (e) {
      throw Exception('Error fetching events: ${e.toString()}');
    }
  }

  // Add a new event
  Future<void> addEvent(Event event) async {
    try {
      await Event.insertEventToSQLite(event);
    } catch (e) {
      throw Exception('Error adding event: ${e.toString()}');
    }
  }

  // Edit an existing event
  Future<void> editEvent(Event event) async {
    try {
      await Event.updateEventInSQLite(event);
    } catch (e) {
      throw Exception('Error editing event: ${e.toString()}');
    }
  }

  // Delete an event
  Future<void> deleteEvent(int? eventId, String? firestoreEventID) async {
    try {
      await Event.deleteEventFromSQLite(eventId, firestoreEventID);
    } catch (e) {
      throw Exception('Error deleting event: ${e.toString()}');
    }
  }

  // Publish an event to Firestore
  Future<void> publishEvent(Event event) async {
    try {
      await Event.publishEventToFirestore(event);
    } catch (e) {
      throw Exception('Error publishing event: ${e.toString()}');
    }
  }

  // Fetch events from Firestore
  Future<List<Event>> getPublishedEvents() async {
    try {
      return await Event.getEventsFromFirestore();
    } catch (e) {
      throw Exception('Error fetching published events: ${e.toString()}');
    }
  }



  Future<void> updateEventInFirestore(Event event) async {
    try{
      await Event.updateEventInFirestore(event);
    } catch (e) {
      throw Exception('Error updating event in Firestore: ${e.toString()}');
    }
  }

  Future<List<Event>> getEventsFromFirestoreByUser(String userId) async {
    try{
      return await Event.getEventsFromFirestoreByUser(userId);
    } catch(e) {
      throw Exception("Error fetching user's Events: ${e.toString()}");
    }
  }


  // Delete event from Firestore
  Future<void> deleteEventFromFirestore(String firestoreID) async {
    try {
      await Event.deleteEventFromFirestore(firestoreID);
    } catch (e) {
      throw Exception('Error deleting event from Firestore: ${e.toString()}');
    }
  }



}
