import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:project_2/Controllers/friends_controller.dart';
import '../Controllers/user_controller.dart';
import '../Models/NotificationService.dart';
import '../Models/UserModel.dart';
import '../Models/EventModel.dart';
import '../Models/FriendsModel.dart';
import '../Controllers/event_controller.dart';
import './friend_events_page.dart';
import 'package:another_flushbar/flushbar.dart';

class HomePage extends StatefulWidget {
  final UserModel user; // Logged-in user

  const HomePage({Key? key, required this.user}) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final UserController _userController = UserController();
  final EventController _eventController = EventController();
  final FriendController _friendController = FriendController();
  late Future<List<UserModel>> _friends;
  List<UserModel> _filteredFriends = [];
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _friends = _fetchFriends();
    _searchController.addListener(_updateSearchQuery);
    // _listenForNotifications(widget.user.uid);
    NotificationService().initialize(widget.user.uid, context);
  }

  @override
  void dispose() {
    NotificationService().dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<List<UserModel>> _fetchFriends() async {
    // Fetch friends of the logged-in user from local database
    return await _userController.getFriendsFromFirestore(widget.user.uid);
  }

  Future<List<UserModel>> _fetchAllUsersExceptLoggedIn() async {
    // Fetch all users except the logged-in user
    final users = await _userController.fetchAllUsers();
    return users.where((user) => user.uid != widget.user.uid).toList();
  }

  void _updateSearchQuery() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }

  List<UserModel> _filterFriends(List<UserModel> friends) {
    if (_searchQuery.isEmpty) {
      return friends;
    }
    return friends.where((friend) {
      return friend.name.toLowerCase().contains(_searchQuery);
    }).toList();
  }

  Future<int> _getUpcomingEventsCount(String userId) async {
    try {
      final List<Event> events = await _eventController.getEventsFromFirestoreByUser(userId);
      final now = DateTime.now();
      return events.where((event) {
        try {
          final eventDate = DateTime.parse(event.date);
          return eventDate.isAfter(now);
        } catch (e) {
          print("Error parsing date for event: ${e.toString()}");
          return false;
        }
      }).length;
    } catch (e) {
      print("Error fetching events: ${e.toString()}");
      return 0;
    }
  }

  // void _listenForNotifications(String userId) {
  //   FirebaseFirestore.instance
  //       .collection('notifications')
  //       .where('userId', isEqualTo: userId)
  //       .where('isRead', isEqualTo: false)
  //       .snapshots()
  //       .listen((snapshot) {
  //     for (var doc in snapshot.docs) {
  //       final notification = doc.data();
  //       _showNotification(notification['message']);
  //
  //       // Optionally mark notification as read
  //       FirebaseFirestore.instance.collection('notifications').doc(doc.id).update({'isRead': true});
  //     }
  //   });
  // }
  //
  // void _showNotification(String message) {
  //   Flushbar(
  //     message: message,
  //     backgroundColor: Colors.amber,
  //     icon: const Icon(Icons.notifications, color: Colors.black),
  //     duration: const Duration(seconds: 3),
  //     margin: const EdgeInsets.all(8),
  //     borderRadius: BorderRadius.circular(10),
  //     flushbarPosition: FlushbarPosition.TOP, // Display at the top
  //   ).show(context);
  // }

  void _addFriend() async {
    final allUsers = await _fetchAllUsersExceptLoggedIn();
    final currentFriends = await _fetchFriends();

    // Filter out already added friends
    final currentFriendIds = currentFriends.map((friend) => friend.uid).toSet();
    List<UserModel> filteredUsers = allUsers.where((user) => !currentFriendIds.contains(user.uid)).toList();

    TextEditingController searchController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.5, // Half of the screen height
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            void _filterUsers(String query) {
              query = query.toLowerCase();
              setModalState(() {
                filteredUsers = allUsers
                    .where((user) =>
                !currentFriendIds.contains(user.uid) &&
                    (user.name.toLowerCase().contains(query) || user.phoneNumber!.contains(query)))
                    .toList();
              });
            }

            return Container(
              color: Colors.grey[800],
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Search Bar
                  TextField(
                    controller: searchController,
                    onChanged: _filterUsers,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[800],
                      hintText: 'Search by name or phone number',
                      hintStyle: const TextStyle(color: Colors.grey),
                      prefixIcon: const Icon(Icons.search, color: Colors.amber),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  // User List
                  filteredUsers.isEmpty
                      ? const Center(
                    child: Text(
                      'No users found',
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                      : Expanded(
                    child: ListView.builder(
                      itemCount: filteredUsers.length,
                      itemBuilder: (context, index) {
                        final user = filteredUsers[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: const AssetImage("assets/avatar.jpg"),
                            radius: 25.0,
                          ),
                          title: Text(
                            user.name,
                            style: const TextStyle(color: Colors.amber, fontSize: 18.0),
                          ),
                          // subtitle: Text(
                          //   user.phoneNumber!,
                          //   style: const TextStyle(color: Colors.grey, fontSize: 16.0),
                          // ),
                          trailing: IconButton(
                            icon: const Icon(Icons.person_add, color: Colors.amber),
                            onPressed: () async {
                              await _friendController.addFriendToFirestore(widget.user.uid, user.uid);
                              await _friendController.addFriendToFirestore(user.uid, widget.user.uid);
                              await _friendController.addFriendToSQLite(widget.user.uid, user.uid);
                              await _userController.addNotification(user.uid, '${widget.user.name} added you as a friend!');
                              setState(() {
                                _friends = _fetchFriends();
                              });
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('Added ${user.name} as a friend!'),
                                  backgroundColor: Colors.blue,

                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[850],
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Friends List'),
        titleTextStyle: const TextStyle(
          color: Colors.amber,
          fontSize: 28.0,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: _addFriend,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50.0), // Height of the search bar
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.amber),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[800],
                hintText: 'Search friends...',
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Colors.amber),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<UserModel>>(
        future: _friends,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No friends found.',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final friends = _filterFriends(snapshot.data!);

          if (friends.isEmpty) {
            return const Center(
              child: Text(
                'No results found.',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return ListView.builder(
            itemCount: friends.length,
            itemBuilder: (context, index) {
              final friend = friends[index];
              return FutureBuilder<int>(
                future: _getUpcomingEventsCount(friend.uid),
                builder: (context, eventSnapshot) {
                  if (eventSnapshot.connectionState == ConnectionState.waiting) {
                    return ListTile(
                      leading: const CircleAvatar(
                        backgroundImage: AssetImage("assets/avatar.jpg"),
                        radius: 30.0,
                      ),
                      title: Text(
                        friend.name,
                        style: const TextStyle(color: Colors.amber, fontSize: 20.0),
                      ),
                      subtitle: const Text(
                        "Loading events...",
                        style: TextStyle(color: Colors.white, fontSize: 16.0),
                      ),
                    );
                  } else if (eventSnapshot.hasError) {
                    return ListTile(
                      leading: const CircleAvatar(
                        backgroundImage: AssetImage("assets/avatar.jpg"),
                        radius: 30.0,
                      ),
                      title: Text(
                        friend.name,
                        style: const TextStyle(color: Colors.amber, fontSize: 20.0),
                      ),
                      subtitle: const Text(
                        "Error loading events.",
                        style: TextStyle(color: Colors.white, fontSize: 16.0),
                      ),
                    );
                  }

                  final upcomingEvents = eventSnapshot.data!;
                  return ListTile(
                    leading: const CircleAvatar(
                      backgroundImage: AssetImage("assets/avatar.jpg"),
                      radius: 30.0,
                    ),
                    title: Text(
                      friend.name,
                      style: const TextStyle(color: Colors.amber, fontSize: 20.0),
                    ),
                    subtitle: Text(
                      upcomingEvents > 0
                          ? "Upcoming Events: $upcomingEvents"
                          : "No upcoming events.",
                      style: const TextStyle(color: Colors.white, fontSize: 16.0),
                    ),
                    trailing: upcomingEvents > 0
                        ? CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.amber,
                      child: Text(
                        '$upcomingEvents',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    )
                        : null,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FriendEventsPage(
                            friend: friend,
                            user: widget.user,
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
