import 'package:flutter/material.dart';
import 'my_pledged_gifts_page.dart';
class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Sample data for the user’s events and gifts
  List<Map<String, String>> events = [
    {'name': 'Birthday Party', 'status': 'Upcoming'},
    {'name': 'Christmas Dinner', 'status': 'Past'},
  ];

  List<Map<String, String>> gifts = [
    {'name': 'Teddy Bear', 'event': 'Birthday Party'},
    {'name': 'Chocolate Box', 'event': 'Christmas Dinner'},
  ];

  // Form Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _notificationsEnabled = true; // Sample notification setting

  @override
  void initState() {
    super.initState();
    // Preload user info
    _nameController.text = "John Doe";
    _emailController.text = "john.doe@example.com";
  }

  // Function to save profile updates
  void _saveProfileUpdates() {
    // Here you can handle the logic for updating the user's profile (e.g., saving to a database).
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Profile updated successfully!')),
    );
  }

  // Function to navigate to pledged gifts page
  void _goToPledgedGiftsPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MyPledgedGiftsPage(
          pledgedGifts: [
            Gift(
              name: 'Teddy Bear',
              category: 'Toys',
              isPledged: true,
              friendName: 'Alice',
              dueDate: DateTime.now().add(const Duration(days: 5)),
            ),
            Gift(
              name: 'Book',
              category: 'Education',
              isPledged: true,
              friendName: 'Charlie',
              dueDate: DateTime.now().add(const Duration(days: 10)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[850],
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Profile Page',
          style: TextStyle(color: Colors.amber, fontSize: 28.0),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text('Personal Information', style: TextStyle(color: Colors.amber, fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            TextField(
              controller: _nameController,
              style: TextStyle(color: Colors.white,fontSize: 18.0,),
              decoration: InputDecoration(
                labelText: 'Name',
                labelStyle: TextStyle(color: Colors.white,),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Colors.white,),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Colors.white,),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Colors.amber, width: 2.0,),
                ),
              ),

            ),
            SizedBox(height: 8.0,),
            TextField(
              controller: _emailController,
              style: TextStyle(color: Colors.white,fontSize: 18.0,),
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(color: Colors.white,),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Colors.white,),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: Colors.white,),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Colors.amber, width: 2.0,),
                ),

              ),
            ),
            SwitchListTile(
              title: Text(
                'Enable Notifications',
                style: TextStyle(color: Colors.white,),
              ),
              value: _notificationsEnabled,
              onChanged: (bool value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveProfileUpdates,
              child: Text('Save Changes'),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.amber), // Button background color
                foregroundColor: MaterialStateProperty.all(Colors.white), // Button text color
                elevation: MaterialStateProperty.all(5), // Button elevation
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0), // Round button corners
                  ),
                ),
              ),
            ),
            SizedBox(height: 30),
            Divider(color: Colors.white, height: 20.0,),
            Text('My Events', style: TextStyle(color:Colors.amber, fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                return ListTile(
                  title: Text(
                    event['name']!,
                    style: TextStyle(color: Colors.white,),
                  ),
                  subtitle: Text(
                    'Status: ${event['status']}',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              },
            ),
            SizedBox(height: 20),
            Divider(color: Colors.white,),
            Text('My Gifts', style: TextStyle(color:Colors.amber, fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: gifts.length,
              itemBuilder: (context, index) {
                final gift = gifts[index];
                return ListTile(
                  title: Text(
                    gift['name']!,
                    style: TextStyle(color: Colors.white,),
                  ),
                  subtitle: Text(
                    'For: ${gift['event']}',
                    style: TextStyle(color: Colors.white,),
                  ),
                );
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _goToPledgedGiftsPage,
              child: Text('View My Pledged Gifts'),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.amber), // Button background color
                foregroundColor: MaterialStateProperty.all(Colors.white), // Button text color
                elevation: MaterialStateProperty.all(5), // Button elevation
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0), // Round button corners
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Placeholder Pledged Gifts Page
class PledgedGiftsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pledged Gifts'),
      ),
      body: Center(
        child: Text('This is the Pledged Gifts Page'),
      ),
    );
  }
}
