import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:testproject/pages/homepage.dart';
import 'auth/splashscreen.dart';

bool? isLogin;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  var log = FirebaseAuth.instance.currentUser;
  if (log == null) {
    isLogin = false;
  } else {
    isLogin = true;
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
       home: isLogin==false?const SplashScreen():const HomePage(),
    );
  }
}
