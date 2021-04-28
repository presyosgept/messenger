import 'package:flutter/material.dart';
import 'package:messenger/views/signin.dart';
import 'package:messenger/views/signup.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool userIsLoggedIn;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'PPB MESSENGER',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: Color(0xff145C9E),
          scaffoldBackgroundColor: Color(0xff1F1F1F),
          accentColor: Color(0xff007EF4),
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: SignIn());
  }
}
