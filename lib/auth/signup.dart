import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:testproject/pages/homepage.dart';
import 'package:testproject/auth/signin.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  GlobalKey<FormState> formstate = new GlobalKey<FormState>();
  bool visible = false;
  var email;
  var password;

  showloading() async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("please wait"),
            content: Container(
                height: 50, child: Center(child: CircularProgressIndicator())),
          );
        });
  }

  signUP() async {
    var formdata = formstate.currentState;
    if (formdata!.validate()) {
      formdata.save();
      try {
        showloading();
        final credential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        return credential;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          Navigator.pop(context);
          print('The password provided is too weak.');
        } else if (e.code == 'email-already-in-use') {
          Navigator.pop(context);
          AwesomeDialog(
              context: context,
              title: "Error",
              body: Container(
                  height: 100,
                  child: Center(child: Text("email-already-in-use"))))
            ..show();
        }
      } catch (e) {
        print(e);
      }
    } else
      print("not vaild");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Form(
            key: formstate,
            child: Column(
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  margin: EdgeInsets.only(top: 40, bottom: 60, left: 15),
                  child: const Text(
                    "Sign Up",
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                  ),
                  //Image.asset("images/image.jpg"),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  margin: EdgeInsets.all(10),
                  child: TextFormField(
                    onSaved: (val) {
                      email = val;
                    },
                    validator: (val) {
                      if (val!.length > 50) {
                        return "email should be less than 50 ";
                      }
                      if (val.length < 5) {
                        return "email should be larger than 5 ";
                      }
                    },
                    decoration: InputDecoration(
                        hintText: "enter your email",
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(
                            borderSide: BorderSide(width: 10))),
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(10),
                  child: TextFormField(
                    onSaved: (val) {
                      password = val;
                    },
                    validator: (val) {
                      if (val!.length > 50) {
                        return "password should be less than 50 ";
                      }
                      if (val.length < 5) {
                        return "password should be larger than 5 ";
                      }
                    },
                    obscureText: visible,
                    decoration: InputDecoration(
                        hintText: "enter your password",
                        prefixIcon: Icon(Icons.lock),
                        suffixIcon: IconButton(
                          onPressed: () {
                            visible = !visible;
                            setState(() {});
                          },
                          icon: visible == false
                              ? Icon(Icons.visibility)
                              : Icon(Icons.visibility_off),
                        ),
                        border: OutlineInputBorder(
                            borderSide: BorderSide(width: 10))),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  padding: EdgeInsets.all(20),
                  width: double.infinity,
                  child: MaterialButton(
                    color: Colors.blue,
                    onPressed: () async {
                      var res = await signUP();
                      if (res != null) {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => HomePage()));
                      } else
                        print("signup failed");
                    },
                    child: Text(
                      "Sign Up",
                      style: TextStyle(fontSize: 35),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("you have account?"),
                    MaterialButton(
                      onPressed: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => SignIn()));
                      },
                      child: Text(
                        "Sign In",
                        style: TextStyle(color: Colors.blue),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ));
  }
}
