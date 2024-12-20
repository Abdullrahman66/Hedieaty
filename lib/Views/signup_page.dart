import 'package:flutter/material.dart';
import '../Controllers/user_controller.dart';
import './nav_bar.dart';

class SignupPage extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _preferencesController = TextEditingController();

  final UserController _userController = UserController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[800],
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
            'Sign Up',
            style: TextStyle(color: Colors.amber, fontSize: 28.0),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Create an Account!",
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 26, color: Colors.white),
              ),
              Text(
                "Let us know more about yourself!",
                style: TextStyle(fontWeight: FontWeight.w400, fontSize: 18, color: Colors.white),
              ),
              SizedBox(height: 10,),
              // Name Field
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.description),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(height: 15),

              // Email Field
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.email),
                  ),
                  validator: (value) {
                    if (value == null || !value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(height: 15),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextFormField(
                  controller: _phoneNumberController,
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

              SizedBox(height: 15),

              // Password Field
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return 'Password must be at least 6 characters long';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(height: 15),
              // Preferences Field
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextFormField(
                  controller: _preferencesController,
                  decoration: InputDecoration(
                    labelText: 'Preferences (e.g., Watches, Perfumes)',
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.category),
                  ),
                ),
              ),
              SizedBox(height: 15),

              // Sign Up Button
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.amber),
                  // Button background color
                  foregroundColor: MaterialStateProperty.all(Colors.white),
                  // Button text color
                  elevation: MaterialStateProperty.all(5),
                  minimumSize: MaterialStateProperty.all(Size(40, 40.0)),
                  // Button elevation
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          20.0), // Round button corners
                    ),
                  ),
                ),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    try {
                      final user = await _userController.SignUp(
                        _nameController.text,
                        _emailController.text,
                        _passwordController.text,
                        _phoneNumberController.text,
                        {
                          'categories': _preferencesController.text
                              .split(',')
                              .map((e) => e.trim())
                              .toList(),
                        },
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('User signed up: ${user.name}'),
                          backgroundColor: Colors.blue,
                        ),
                      );
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => BottomNavBar(user: user)),
                            (route) => false, // Remove all previous routes
                      );
                    } catch (e) {
                      print(e);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: ${e.toString()}')),
                      );
                    }
                  }
                },
                child: Text('Sign Up',style: TextStyle(fontSize: 18),),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
