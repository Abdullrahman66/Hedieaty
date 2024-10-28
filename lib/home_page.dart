import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Friend> friends = [
    Friend(name: 'Alice', profilePicture: 'assets/alice.jpg', upcomingEvents: 2),
    Friend(name: 'Bob', profilePicture: 'assets/bob.jpg', upcomingEvents: 0),
    Friend(name: 'Charlie', profilePicture: 'assets/charlie.jpg', upcomingEvents: 1),
  ];

  String searchQuery = '';

  // This method filters friends based on the search query.
  List<Friend> get filteredFriends {
    if (searchQuery.isEmpty) return friends;
    return friends
        .where((friend) =>
        friend.name.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
  }

  // Navigate to friend’s gift list page
  void navigateToGiftList(Friend friend) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GiftListPage(friend: friend),
      ),
    );
  }

  // Handle adding new friend (manually or from contacts)
  void addNewFriend() {
    // Implement manual add or contacts integration here.
    print("Add new friend");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Friends List'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: addNewFriend,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search Friends...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onChanged: (query) {
                setState(() {
                  searchQuery = query;
                });
              },
            ),
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: filteredFriends.length,
        itemBuilder: (context, index) {
          final friend = filteredFriends[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: AssetImage(friend.profilePicture),
            ),
            title: Text(friend.name),
            subtitle: Text(friend.upcomingEvents > 0
                ? 'Upcoming Events: ${friend.upcomingEvents}'
                : 'No Upcoming Events'),
            trailing: friend.upcomingEvents > 0
                ? CircleAvatar(
              radius: 12,
              backgroundColor: Colors.red,
              child: Text(
                '${friend.upcomingEvents}',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            )
                : null,
            onTap: () => navigateToGiftList(friend),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigate to the event/list creation page
          print("Navigate to Create Event/List Page");
        },
        label: Text('Create Your Own Event/List'),
        icon: Icon(Icons.add),
      ),
    );
  }
}

// Friend model to hold friend details
class Friend {
  final String name;
  final String profilePicture;
  final int upcomingEvents;

  Friend({
    required this.name,
    required this.profilePicture,
    required this.upcomingEvents,
  });
}

// GiftListPage stub (for navigation demo)
class GiftListPage extends StatelessWidget {
  final Friend friend;

  const GiftListPage({Key? key, required this.friend}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${friend.name}\'s Gift List')),
      body: Center(
        child: Text('Gift List Details for ${friend.name}'),
      ),
    );
  }
}
