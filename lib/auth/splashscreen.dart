import 'dart:async';
import 'package:flutter/material.dart';
import 'package:testproject/auth/signin.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    Timer(
        Duration(seconds: 3),
            () => Navigator.push(
            context, MaterialPageRoute(builder: (context) => SignIn())));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.deepOrange,
        body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Center(
              child: Text(
                "Welcome",
                style: TextStyle(fontSize: 30),
              )),
          SizedBox(height: 10,),
          CircularProgressIndicator(
            color: Colors.white,
          ),
        ]));
  }
}
