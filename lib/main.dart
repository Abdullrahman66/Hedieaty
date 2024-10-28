import 'package:flutter/material.dart';
import 'home_page.dart';
import 'gift_lists_page.dart';
import 'create_event_page.dart';
import 'profile_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: BottomNavBar(),
    );
  }
}

class BottomNavBar extends StatefulWidget {
  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0; // Track the selected tab index

  // List of pages to navigate between
  final List<Widget> _pages = [
    HomePage(),
    GiftListsPage(),
    CreateEventPage(),
    ProfilePage(),
  ];

  // Update selected index on tap
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex], // Display the selected page
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_giftcard),
            label: 'Gifts Lists',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Events List',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle_sharp),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue, // Highlight selected item
        unselectedItemColor: Colors.grey[900],
        backgroundColor: Colors.white,
        showUnselectedLabels: true,
        onTap: _onItemTapped, // Handle tab selection
        unselectedLabelStyle: TextStyle(
          fontSize: 12.0,
        ),
        unselectedFontSize: 16.0,
      ),
    );
  }
}


