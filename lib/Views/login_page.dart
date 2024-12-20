import 'package:flutter/material.dart';
import '../Controllers/user_controller.dart';
import './signup_page.dart';
import './nav_bar.dart';
class LoginPage extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final UserController _userController = UserController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[800],
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
            'Login',
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
              // Email Field
              Text(
                "Welcome Back!",
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 26, color: Colors.white),
              ),
              // SizedBox(height: 5,),
              Text(
                "Please sign in to continue",
                style: TextStyle(fontWeight: FontWeight.w400, fontSize: 17, color: Colors.white),
              ),
              SizedBox(height: 10,),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),

                  // boxShadow: [
                    // BoxShadow(
                    //   offset: Offset(3, 3),
                    //   blurRadius: 6,
                    //   color: Colors.grey.shade400,
                    // )
                  // ]
                ),
                child: TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (value) {
                    if (value == null || !value.contains('@')) {
                      return 'Please enter a valid email address.';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(height: 16),

              // Password Field
              Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                  borderRadius: BorderRadius.circular(10),

                    // boxShadow: [
                    //   BoxShadow(
                    //     offset: Offset(3, 3),
                    //     blurRadius: 6,
                    //     color: Colors.grey.shade400,
                    //   )
                    // ]
                ),
                child: TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.lock_outline_rounded),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password.';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(height: 16),

              // Login Button
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
                      final user = await _userController.Login(
                        _emailController.text,
                        _passwordController.text,
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('Welcome back, ${user.name}!'),
                            backgroundColor: Colors.blue,
                        ),
                      );

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => BottomNavBar(user: user)),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Wrong Email or Password")),
                      );
                    }
                  }
                },
                child: Text('Login', style: TextStyle(fontSize: 18),),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignupPage()),
                  );
                },
                child: Text(
                    "Don't have an account? Sign Up",
                    style: TextStyle(color: Colors.amber, fontSize: 20.0),

              ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
