import 'package:flutter/material.dart';
import '../Models/EventModel.dart';
import '../Controllers/event_controller.dart';
import '../Models/UserModel.dart';
import './friend_gift_list.dart';

class FriendEventsPage extends StatefulWidget {
  final UserModel friend;
  final UserModel user;

  const FriendEventsPage({Key? key, required this.friend, required this.user}) : super(key: key);

  @override
  _FriendEventsPageState createState() => _FriendEventsPageState();
}

class _FriendEventsPageState extends State<FriendEventsPage> {
  final EventController _eventController = EventController();
  late Future<List<Event>> _friendEvents;

  @override
  void initState() {
    super.initState();
    _friendEvents = _fetchFriendEvents();
  }

  Future<List<Event>> _fetchFriendEvents() async {
    try {
      return await _eventController.getEventsFromFirestoreByUser(widget.friend.uid);
    } catch (e) {
      print("Error fetching friend's events: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("${widget.friend.name}'s Events"),
        titleTextStyle: const TextStyle(color: Colors.amber, fontSize: 24.0),
      ),
      backgroundColor: Colors.grey[850],
      body: FutureBuilder<List<Event>>(
        future: _friendEvents,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.white),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No events found.',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final events = snapshot.data!;
          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return Card(
                color: Colors.grey[700],
                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: ListTile(
                  title: Text(
                    event.name,
                    style: const TextStyle(color: Colors.amber, fontSize: 20.0),
                  ),
                  subtitle: Text(
                    "${event.category}\nDate: ${event.date}",
                    style: const TextStyle(color: Colors.white),
                  ),
                  isThreeLine: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EventGiftsPage(event: event,friend: widget.friend, user: widget.user,),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
