import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Friend> friends = [
    Friend(name: 'Abdelrahman', profilePicture: 'assets/avatar.jpg', upcomingEvents: 2),
    Friend(name: 'Mohamed', profilePicture: 'assets/avatar.jpg', upcomingEvents: 0),
    Friend(name: 'Hamza', profilePicture: 'assets/avatar.jpg', upcomingEvents: 1),
  ];
  final Map<String, List<Gift>> giftDatabase = {
    'Abdelrahman': [
      Gift(name: 'Teddy Bear', category: 'Toys'),
      Gift(name: 'Necklace', category: 'Jewelry', isPledged: true),
    ],
    'Mohamed': [
      Gift(name: 'Football', category: 'Sports'),
    ],
    'Hamza': [
      Gift(name: 'Watch', category: 'Accessories', isPledged: true),
      Gift(name: 'Book', category: 'Education'),
    ],
  };

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
        builder: (context) => GiftListPage(
            friend: friend,
            gifts: giftDatabase[friend.name] ?? [],
        ),
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
      backgroundColor: Colors.grey[850],
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Friends List'),
        titleTextStyle: TextStyle(
          color: Colors.amber,
          fontSize: 28.0,
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.add,
              color: Colors.grey,
            ),
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
                hintStyle: TextStyle(
                  color: Colors.white,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.white,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Colors.amber, width: 2.0),
                ),
              ),
              onChanged: (query) {
                setState(() {
                  searchQuery = query;
                });
              },
              style: TextStyle(
                color: Colors.white,
              ),
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
              radius: 30.0,
            ),
            title: Text(friend.name),
            titleTextStyle: TextStyle(
              color: Colors.amber,
              fontSize: 20.0,
            ),
            subtitle: Text(friend.upcomingEvents > 0
                ? 'Upcoming Events: ${friend.upcomingEvents}'
                : 'No Upcoming Events'),
            subtitleTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 16.0,
            ),
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
class Gift {
  final String name;
  final String category;
  final bool isPledged;

  Gift({
    required this.name,
    required this.category,
    this.isPledged = false,
  });
}

// GiftListPage stub (for navigation demo)
class GiftListPage extends StatelessWidget {
  final Friend friend;
  final List<Gift> gifts;

  const GiftListPage({Key? key, required this.friend, required this.gifts}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[850],
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          '${friend.name}\'s Gift List',
          style: TextStyle(color: Colors.amber,fontSize: 28.0,),
        ),
      ),
      body: ListView.builder(
        itemCount: gifts.length,
        itemBuilder: (context, index) {
          final gift = gifts[index];
          return ListTile(
            leading: Icon(
              gift.isPledged ? Icons.check_circle : Icons.card_giftcard,
              color: gift.isPledged ? Colors.green : Colors.grey,
            ),
            title: Text(gift.name,style: TextStyle(color: Colors.white,fontSize: 20.0),),
            subtitle: Text('Category: ${gift.category}',style: TextStyle(color: Colors.white,fontSize: 16.0,),),
            trailing: gift.isPledged
                ? const Text('Pledged', style: TextStyle(color: Colors.green))
                : ElevatedButton(
              onPressed: () {
                // Pledge logic can be implemented here
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('You pledged ${gift.name} for ${friend.name}'),
                  ),
                );
              },
              child: const Text('Pledge'),
            ),
          );
        },
      ),
    );
  }
}
