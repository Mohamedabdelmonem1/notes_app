import 'dart:io';
import 'dart:math';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:testproject/pages/homepage.dart';

class Edit extends StatefulWidget {
  final docid;
  final list;
  const Edit({Key? key, this.docid,this.list}) : super(key: key);
  @override
  State<Edit> createState() => _EditState();
}

class _EditState extends State<Edit> {
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

  editnote(context) async {
    var formdata = formstate.currentState;
    if (image == null){
      if (formdata!.validate()) {
        showloading(context);
        formdata.save();
        var notesref = FirebaseFirestore.instance.collection("notes").doc(widget.docid).update({
          "title": title,
          "notes": notes,
          "imageurl": imageurl,

        }).then((value) {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => HomePage()));
        }).catchError((e){
          print(e);
        });
      }
    }else{
      if (formdata!.validate()) {
        showloading(context);
        formdata.save();
        await ref.putFile(image);
        imageurl = await ref.getDownloadURL();
        var notesref = FirebaseFirestore.instance.collection("notes").doc(widget.docid).update({
          "title": title,
          "notes": notes,
          "imageurl": imageurl,
        }).then((value) {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => HomePage()));
        }).catchError((e){
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
            decoration: InputDecoration(
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
            decoration: InputDecoration(
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
                    return Container(
                      height: 200,
                      child: Column(
                        children: [
                          Container(
                            child: Text(
                              "Choose photo from",
                              style: TextStyle(
                                  fontSize: 30, fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(
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
                            child: Row(
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
                          SizedBox(
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
                            child: Row(
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
            child: Text("Edit photo"),
          ),
          SizedBox(
            height: 30,
          ),
          MaterialButton(
            padding: EdgeInsets.symmetric(horizontal: 20),
            color: Colors.blue,
            onPressed: () async {
              await editnote(context);
            },
            child: Text(
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
