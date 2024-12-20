import 'package:flutter/material.dart';
import 'package:project_2/Models/UserModel.dart';
import './home_page2.dart';
import './gift_lists_page.dart';
import './create_event_page.dart';
import './profile_page.dart';

class BottomNavBar extends StatefulWidget {
  final UserModel user; // Example of data to pass

  const BottomNavBar({Key? key, required this.user}) : super(key: key);
  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0; // Track the selected tab index
  late List<Widget> _pages;
  @override
  void initState() {
    super.initState();

    // Initialize _pages inside initState
    _pages = [
      HomePage(user: widget.user),
      CreateEventPage(user: widget.user),
      // GiftListsPage(),
      ProfilePage(user: widget.user,),
    ];
  }


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
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.card_giftcard),
          //   label: 'Gifts Lists',
          // ),
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
        selectedItemColor: Colors.amber, // Highlight selected item
        unselectedItemColor: Colors.white,
        backgroundColor: Colors.black,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped, // Handle tab selection
        unselectedLabelStyle: TextStyle(
          fontSize: 12.0,
        ),
        unselectedFontSize: 16.0,
      ),
    );
  }
}
