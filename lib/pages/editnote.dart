import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'homepage.dart';

class Edit extends StatefulWidget {
  final docid;
  final list;
  const Edit({Key? key, this.docid, this.list}) : super(key: key);
  @override
  State<Edit> createState() => _EditState();
}

class _EditState extends State<Edit> {
  showLoading(context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
            title: Text("please wait"),
            content: SizedBox(
                height: 50, child: Center(child: CircularProgressIndicator())),
          );
        });
  }

  GlobalKey<FormState> formstate = GlobalKey<FormState>();

  var title;
  var notes;
  var image;
  var imageurl;
  var ref;

  editNote(context) async {
    var formdata = formstate.currentState;
    if (image == null) {
      if (formdata!.validate()) {
        showLoading(context);
        formdata.save();
        var notesref = FirebaseFirestore.instance
            .collection("notes")
            .doc(widget.docid)
            .update({
          "title": title,
          "notes": notes,
          "imageurl": imageurl,
        }).then((value) {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const HomePage()));
        }).catchError((e) {
          print(e);
        });
      }
    } else {
      if (formdata!.validate()) {
        showLoading(context);
        formdata.save();
        await ref.putFile(image);
        imageurl = await ref.getDownloadURL();
        var notesref = FirebaseFirestore.instance
            .collection("notes")
            .doc(widget.docid)
            .update({
          "title": title,
          "notes": notes,
          "imageurl": imageurl,
        }).then((value) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const HomePage(),
            ),
          );
        }).catchError((e) {
          print(e);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Notes"),
      ),
      body: Form(
        key: formstate,
        child: Column(children: [
          TextFormField(
            initialValue: widget.list['title'],
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
          SizedBox(
            height: 10,
          ),
          TextFormField(
            initialValue: widget.list['notes'],
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
            decoration: const InputDecoration(
                labelText: "notes", prefixIcon: Icon(Icons.note)),
          ),
          SizedBox(
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
                          const Text(
                            "Choose photo from",
                            style: TextStyle(
                                fontSize: 30, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
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
                            child: const Row(
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
                            child: const Row(
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
                width: 125,
                height: 40,
                decoration: const BoxDecoration(color: Colors.blue),
                child:const Center(
                    child: Text(
                  "Edit photo",
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ))),
          ),
          const SizedBox(
            height: 30,
          ),
          MaterialButton(
            padding: EdgeInsets.symmetric(horizontal: 20),
            color: Colors.blue,
            onPressed: () async {
              await editNote(context);
            },
            child: const Text(
              "Edit note",
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
