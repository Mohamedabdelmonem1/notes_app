import 'dart:io';
import 'dart:math';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'homepage.dart';

class Add extends StatefulWidget {
  const Add({Key? key}) : super(key: key);
  @override
  State<Add> createState() => _AddState();
}

class _AddState extends State<Add> {
  showloading(context) async {
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

  GlobalKey<FormState> formstate = new GlobalKey<FormState>();

  var title;
  var notes;
  var image;
  var imageurl;
  var ref;

  addnote(context) async {
    if (image == null) {
      return AwesomeDialog(
          padding: EdgeInsets.all(30),
          context: context,
          title: "important",
          body: Text("please choose image"))
        ..show();
    }
    var formdata = formstate.currentState;
    if (formdata!.validate()) {
      showloading(context);
      formdata.save();
      await ref.putFile(image);
      imageurl = await ref.getDownloadURL();
      var notesref = FirebaseFirestore.instance.collection("notes").add({
        "title": title,
        "notes": notes,
        "imageurl": imageurl,
        "userid": FirebaseAuth.instance.currentUser!.uid
      }).then((value) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => HomePage()));
      }).catchError((e) {
        print(e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Notes"),
      ),
      body: Form(
        key: formstate,
        child: Column(children: [
          TextFormField(
            validator: (val) {
              if (val!.length > 50) {
                return "title should be less than 50 ";
              }
              if (val.length < 5) {
                return "title should be larger than 5 ";
              }
              return null;
            },
            onSaved: (val) {
              title = val;
            },
            maxLength: 30,
            minLines: 1,
            decoration: const InputDecoration(
                labelText: "title", prefixIcon: Icon(Icons.note)),
          ),
          const SizedBox(
            height: 10,
          ),
          TextFormField(
            validator: (val) {
              if (val!.length > 50) {
                return "notes should be less than 50 ";
              }
              if (val.length < 5) {
                return "notes should be larger than 5 ";
              }
              return null;
            },
            onSaved: (val) {
              notes = val;
            },
            maxLength: 200,
            minLines: 1,
            maxLines: 3,
            decoration:const InputDecoration(
                labelText: "notes", prefixIcon: Icon(Icons.note)),
          ),
          const  SizedBox(
            height: 10,
          ),
          MaterialButton(
            onPressed: () {
              showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return SizedBox(
                      height: 200,
                      child: Column(
                        children: [
                           Text(
                             "Choose photo from",
                             style: TextStyle(
                                 fontSize: 30, fontWeight: FontWeight.bold),
                           ),
                          const  SizedBox(
                            height: 20,
                          ),
                          MaterialButton(
                            onPressed: () async {
                              var pickedImage = await ImagePicker()
                                  .pickImage(source: ImageSource.camera);
                              if (pickedImage != null) {
                                image = File(pickedImage.path);
                                var random = Random().nextInt(1000000);
                                var nameimage = basename(pickedImage.path);
                                nameimage = "$random$nameimage";

                                ref = FirebaseStorage.instance
                                    .ref("images/$nameimage");
                                Navigator.pop(context);
                              }
                            },
                            child:const Row(
                              children: [
                                Icon(Icons.camera),
                                SizedBox(
                                  width: 20,
                                ),
                                Text(
                                  "open your camera",
                                  style: TextStyle(fontSize: 20),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          MaterialButton(
                            onPressed: () async {
                              var pickedImage = await ImagePicker()
                                  .pickImage(source: ImageSource.gallery);
                              if (pickedImage != null) {
                                image = File(pickedImage.path);
                                var random = Random().nextInt(1000000);
                                var nameimage = basename(pickedImage.path);
                                nameimage = "$random$nameimage";

                                ref = FirebaseStorage.instance
                                    .ref("images/$nameimage");
                                Navigator.pop(context);
                              }
                            },
                            child:const Row(
                              children: [
                                Icon(Icons.photo_outlined),
                                SizedBox(
                                  width: 20,
                                ),
                                Text(
                                  "open your gallery",
                                  style: TextStyle(fontSize: 20),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    );
                  });
            },
            child: Container(
                width: 145,
                height: 40,
                decoration: BoxDecoration(color: Colors.blue),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Add photo ",
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                    Icon(
                      Icons.photo,
                      color: Colors.white,
                    )
                  ],
                )),
          ),
          const   SizedBox(
            height: 30,
          ),
          MaterialButton(
            height: 50,
            padding: EdgeInsets.symmetric(horizontal: 35),
            color: Colors.blue,
            onPressed: () async {
              await addnote(context);
            },
            child:const Text(
              "Add note",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ]),
      ),
    );
  }
}
