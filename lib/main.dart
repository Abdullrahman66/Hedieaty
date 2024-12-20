import 'package:flutter/material.dart';
import './Views/login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import './Views/gift_lists_page.dart';
import './Views/create_event_page.dart';
import './Views/profile_page.dart';
// import 'db_helper.dart';
import './Controllers/shared_prefs_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await SharedPrefsHelper().init();
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
      home: LoginPage(),
    );
  }
}


