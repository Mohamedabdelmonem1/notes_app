import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:testproject/auth/signup.dart';

import '../pages/homepage.dart';

class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  bool visible = false;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  showLoading() async {
    return showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
            title: Text("please wait"),
            content: SizedBox(
              height: 50,
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        });
  }

  signIn() async {
    try {
      showLoading();
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text, password: passwordController.text);
      return credential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        Navigator.pop(context);
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        Navigator.pop(context);
        print('Wrong password provided for that user.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          body: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  margin: const EdgeInsets.only(top: 120, bottom: 60, left: 15),
                  child: const Text(
                    "Sign In",
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                  ),
                  //Image.asset("images/image.jpg"),
                ),
                const SizedBox(
                  height: 40,
                ),
                Container(
                  margin: const EdgeInsets.all(10),
                  child: TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      hintText: "enter your email",
                      prefixIcon: Icon(Icons.person),
                      border:
                          OutlineInputBorder(borderSide: BorderSide(width: 10)),
                      enabledBorder:
                          OutlineInputBorder(borderSide: BorderSide(width: 1)),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(10),
                  child: TextFormField(
                    controller: passwordController,
                    obscureText: visible,
                    decoration: InputDecoration(
                      hintText: "enter your password",
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        onPressed: () {
                          visible = !visible;
                          setState(() {});
                        },
                        icon: visible == false
                            ? const Icon(Icons.visibility)
                            : const Icon(Icons.visibility_off),
                      ),
                      border: const OutlineInputBorder(
                          borderSide: BorderSide(width: 10)),
                      enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(width: 1)),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 50,
                ),
                Container(
                  padding: EdgeInsets.all(20),
                  width: double.infinity,
                  height: 90,
                  child: MaterialButton(
                    color: Colors.blue,
                    onPressed: () async {
                      var user = await signIn();
                      if (user != null) {
                        Navigator.pushReplacement(context,
                            MaterialPageRoute(builder: (context) => HomePage()));
                      } else
                        print("signin failed");
                    },
                    child: const Text(
                      "Sign In",
                      style: TextStyle(fontSize: 35),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have account?"),
                    MaterialButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SignUp()));
                      },
                      child: const Text(
                        "Sign Up",
                        style: TextStyle(color: Colors.blue),
                      ),
                    )
                  ],
                )
              ],
            ),
          )),
    );
  }
}
