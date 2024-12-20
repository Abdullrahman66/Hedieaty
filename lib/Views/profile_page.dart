import 'package:flutter/material.dart';
import 'package:project_2/Models/NotificationService.dart';
import 'package:project_2/Views/login_page.dart';
import '../Controllers/shared_prefs_controller.dart';
import './my_pledged_gifts_page.dart';
import '../Controllers/user_controller.dart';
import './login_page.dart';
import '../Models/UserModel.dart';

class ProfilePage extends StatefulWidget {
  final UserModel user; // Logged-in user

  const ProfilePage({Key? key, required this.user}) : super(key: key);
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  final _formKey = GlobalKey<FormState>();

  // Form Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _preferencesController = TextEditingController();
  final NotificationService _notificationService = NotificationService();
  bool _notificationsEnabled = true; // Sample notification setting
  final UserController _userController = UserController();
  Map<String, dynamic> prefs = {};
  List<dynamic> decodedPrefs = [];

  @override
  void initState() {
    super.initState();
    if(SharedPrefsHelper().getBool('NotificationsEnable') != null){
      _notificationsEnabled = SharedPrefsHelper().getBool('NotificationsEnable')!;
    }
    // Preload user info
    _nameController.text = widget.user.name;
    // _emailController.text = widget.user.email;
    _phoneNumberController.text = widget.user.phoneNumber!;
    prefs = widget.user.getPreferences();
    decodedPrefs = prefs['categories'];
    _preferencesController.text = decodedPrefs.join(', ');
  }

  // Function to save profile updates
  void _saveProfileUpdates() async {
    final String newName = _nameController.text.trim();
    // final String newEmail = _emailController.text.trim();
    final String newPassword = _passwordController.text.trim();
    final String newPhone = _phoneNumberController.text.trim();
    final Map<String, dynamic> newprefs = {
      'categories': _preferencesController.text
          .split(',')
          .map((e) => e.trim())
          .toList(),
    };
    if (newPassword.isNotEmpty && newPassword.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Password must be at least 6 characters long'),
          backgroundColor: Colors.blue,

        ),
      );
      return;
    }
    try {
      // Update user information
      final userId = await UserModel.getIdByFirestoreID(widget.user.uid);
      final newUser = UserModel(
          id: userId,
          uid: widget.user.uid,
          name: newName,
          email: widget.user.email,
          phoneNumber: newPhone
      );
      newUser.setPreferences(newprefs);

      await UserModel.updateUserInSQLite(newUser);
      await UserModel.updateUserInFirestore(newUser);
      // await UserModel.updateEmail(newEmail);
      if (newPassword.isNotEmpty) {
        UserModel.updatePassword(newPassword);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Profile updated successfully!'),
          backgroundColor: Colors.blue,

        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: $e')),
      );
    }
  }

  // Function to navigate to pledged gifts page
  void _goToPledgedGiftsPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PledgedGiftsPage(user: widget.user),
      ),
    );
  }

  void _logout() async {
    try {
      await _userController.logout();
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Logged out successfully'),
            backgroundColor: Colors.blue,

          ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logout failed: $e')));
    }
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
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white,),
            onPressed: _logout,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey, // Form key to manage validation
          child: ListView(
            children: [
              Text(
                'Personal Information',
                style: TextStyle(color: Colors.amber,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              CircleAvatar(
                backgroundImage: AssetImage('assets/avatar.jpg'),
                radius: 100,
              ),
              SizedBox(height: 20),
              // Name Field
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextFormField(
                  controller: _nameController,
                  style: TextStyle(color: Colors.black, fontSize: 18.0),
                  decoration: InputDecoration(
                    labelText: 'Name',
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.description),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Name is required';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(height: 15.0),

              // Email Field
              // TextFormField(
              //   controller: _emailController,
              //   style: TextStyle(color: Colors.white, fontSize: 18.0),
              //   decoration: _inputDecoration('Email'),
              //   validator: (value) {
              //     if (value == null || value.isEmpty) {
              //       return 'Email is required';
              //     }
              //     if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
              //       return 'Enter a valid email address';
              //     }
              //     return null;
              //   },
              // ),
              // SizedBox(height: 15.0),

              // Password Field
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextFormField(
                  controller: _passwordController,
                  style: TextStyle(color: Colors.black, fontSize: 18.0),
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.lock),
                  ),
                  // validator: (value) {
                  //   if (value != null && value.isNotEmpty && value.length < 6) {
                  //     return 'Password must be at least 6 characters long';
                  //   }
                  //   return null;
                  // },
                ),
              ),
              SizedBox(height: 15.0),

              // Phone Number Field
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextFormField(
                  controller: _phoneNumberController,
                  style: TextStyle(color: Colors.black, fontSize: 18.0),
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.phone),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty ) {
                      return 'Phone number is required';
                    }
                    if (!RegExp(r'^\d+$').hasMatch(value) || value.length != 11) {
                      return 'Enter a valid phone number';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(height: 15.0),

              // Preferences Field
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextFormField(
                  controller: _preferencesController,
                  style: TextStyle(color: Colors.black, fontSize: 18.0),
                  decoration: InputDecoration(
                    labelText: 'Preferences (e.g., Watches, Perfumes)',
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.category),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Preferences are required';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(height: 15.0),

              // Notifications Toggle
              SwitchListTile(
                title: Text(
                  'Enable Notifications',
                  style: TextStyle(color: Colors.white),
                ),
                value: _notificationsEnabled,
                onChanged: (bool value) {
                  setState(() {
                    _notificationsEnabled = value;
                    print(value);
                    SharedPrefsHelper().putBool('NotificationsEnable', value);
                    _notificationService.dispose();
                    _notificationService.initialize(widget.user.uid, context);
                  });

                },
              ),
              SizedBox(height: 20),

              // Save Button
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _saveProfileUpdates();
                  }
                },
                child: Text('Save Changes'),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.amber),
                  // Button background color
                  foregroundColor: MaterialStateProperty.all(Colors.white),
                  // Button text color
                  elevation: MaterialStateProperty.all(5),
                  // Button elevation
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          20.0), // Round button corners
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30),

              Divider(color: Colors.white, height: 20.0),
              // Text(
              //   'My Events',
              //   style: TextStyle(color: Colors.amber,
              //       fontSize: 18,
              //       fontWeight: FontWeight.bold),
              // ),
              // SizedBox(height: 10),

              // Events List
              // ListView.builder(
              //   shrinkWrap: true,
              //   physics: NeverScrollableScrollPhysics(),
              //   itemCount: events.length,
              //   itemBuilder: (context, index) {
              //     final event = events[index];
              //     return ListTile(
              //       title: Text(
              //         event['name']!,
              //         style: TextStyle(color: Colors.white),
              //       ),
              //       subtitle: Text(
              //         'Status: ${event['status']}',
              //         style: TextStyle(color: Colors.white),
              //       ),
              //     );
              //   },
              // ),
              // SizedBox(height: 20),

              // Divider(color: Colors.white),
              // Text(
              //   'My Gifts',
              //   style: TextStyle(color: Colors.amber,
              //       fontSize: 18,
              //       fontWeight: FontWeight.bold),
              // ),
              // SizedBox(height: 10),
              //
              // // Gifts List
              // ListView.builder(
              //   shrinkWrap: true,
              //   physics: NeverScrollableScrollPhysics(),
              //   itemCount: gifts.length,
              //   itemBuilder: (context, index) {
              //     final gift = gifts[index];
              //     return ListTile(
              //       title: Text(
              //         gift['name']!,
              //         style: TextStyle(color: Colors.white),
              //       ),
              //       subtitle: Text(
              //         'For: ${gift['event']}',
              //         style: TextStyle(color: Colors.white),
              //       ),
              //     );
              //   },
              // ),
              // SizedBox(height: 20),

              ElevatedButton(
                onPressed: _goToPledgedGiftsPage,
                child: Text('View My Pledged Gifts'),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.amber),
                  // Button background color
                  foregroundColor: MaterialStateProperty.all(Colors.white),
                  // Button text color
                  elevation: MaterialStateProperty.all(5),
                  // Button elevation
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          20.0), // Round button corners
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

// Input decoration helper method
  InputDecoration _inputDecoration(String labelText) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: TextStyle(color: Colors.white),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: Colors.white),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(color: Colors.white),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: Colors.amber, width: 2.0),
      ),
    );
  }
}
