import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:testproject/pages/homepage.dart';

class ViewPage extends StatefulWidget {
  final viewnote;
  const ViewPage({Key? key, this.viewnote}) : super(key: key);

  @override
  State<ViewPage> createState() => _ViewPageState();
}

class _ViewPageState extends State<ViewPage> {
  @override
  Widget build(BuildContext context) {
    bool visible = false;

    return Scaffold(
      appBar: AppBar(
        title: Text("View note"),
      ),

      body: Container(
          child: Column(
        children: [
          Container(
              width: double.infinity,
              height: 330,
              child: Image.network("${widget.viewnote['imageurl']}",
                  fit: BoxFit.fill)),
          SizedBox(
            height: 20,
          ),
          Center(
              child: Container(
            child: Text(
              "${widget.viewnote['title']}",
              style: TextStyle(
                  color: Colors.blue,
                  fontSize: 30,
                  fontWeight: FontWeight.bold),
            ),
          )),
          SizedBox(
            height: 20,
          ),
          Center(
              child: Container(
            child: Text("${widget.viewnote['notes']}",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
          )),
          SizedBox(
            height: 150,
          ),
          MaterialButton(
            height: 50,
            minWidth: 200,
            color: Colors.blue,
            onPressed: () async {
              await FirebaseFirestore.instance.collection("cart").add({
                "title": widget.viewnote['title'],
                "notes": widget.viewnote['notes'],
                "imageurl": widget.viewnote['imageurl'],
                "userid": FirebaseAuth.instance.currentUser!.uid
              });
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => HomePage()));
            },
            child: Text("Add to cart"),
          )
        ],
      )),
    );
  }
}
