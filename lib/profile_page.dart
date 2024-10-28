import 'package:flutter/material.dart';

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
      MaterialPageRoute(builder: (context) => PledgedGiftsPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text('Personal Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            SwitchListTile(
              title: Text('Enable Notifications'),
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
            ),
            SizedBox(height: 30),
            Divider(),
            Text('My Events', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                return ListTile(
                  title: Text(event['name']!),
                  subtitle: Text('Status: ${event['status']}'),
                );
              },
            ),
            SizedBox(height: 20),
            Divider(),
            Text('My Gifts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: gifts.length,
              itemBuilder: (context, index) {
                final gift = gifts[index];
                return ListTile(
                  title: Text(gift['name']!),
                  subtitle: Text('For: ${gift['event']}'),
                );
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _goToPledgedGiftsPage,
              child: Text('View My Pledged Gifts'),
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
