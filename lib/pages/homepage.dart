import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:testproject/pages/addnote.dart';
import 'package:testproject/pages/cartpage.dart';
import 'package:testproject/pages/editnote.dart';
import 'package:testproject/auth/signin.dart';
import 'package:testproject/pages/viewpage.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  getdata() async {
    var response = await FirebaseFirestore.instance
        .collection("notes")
        .where("userid", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get();
    return response;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => Add()));
        },
        child: Icon(Icons.add),
      ),
      appBar: AppBar(
        title: Text("Homepage"),
        actions: [
          Row(
            children: [
              IconButton(onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>CartPage()));
              }, icon: Icon(Icons.add_shopping_cart)),
              IconButton(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.pushReplacement(
                        context, MaterialPageRoute(builder: (context) => SignIn()));
                  },
                  icon: Icon(Icons.exit_to_app)),
            ],
          )
        ],
      ),
      drawer: Drawer(),
      body: FutureBuilder(
          future: getdata(),
          builder: (context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (context, i) {
                    return MaterialButton(
                      onPressed: () {
                       Navigator.push(
                           context,
                            MaterialPageRoute(
                                builder: (context) => ViewPage(
                                      viewnote: snapshot.data.docs[i],
                                     )
                                   )
                         );
                      },
                      child: Dismissible(
                          onDismissed: (direction) async {
                            await FirebaseFirestore.instance
                                .collection("notes")
                                .doc(snapshot.data.docs[i].id)
                                .delete();
                            await FirebaseStorage.instance
                                .refFromURL(snapshot.data.docs[i]['imageurl'])
                                .delete();
                          },
                          key: UniqueKey(),
                          child: Card(
                              child: Row(
                            children: [
                              Expanded(
                                  flex: 1,
                                  child: Image.network(
                                    "${snapshot.data.docs[i]['imageurl']}",
                                    fit: BoxFit.fill,
                                    height: 80,
                                  )),
                              Expanded(
                                  flex: 3,
                                  child: ListTile(
                                    title: Text(
                                        "${snapshot.data.docs[i]['title']}",style: TextStyle(fontWeight: FontWeight.bold),),
                                    subtitle: Text(
                                        "${snapshot.data.docs[i]['notes']}"),
                                    trailing: IconButton(
                                      icon: Icon(Icons.edit),
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => Edit(
                                                      docid: snapshot
                                                          .data.docs[i].id,
                                                      list:
                                                          snapshot.data.docs[i],
                                                    )));
                                      },
                                    ),
                                  )),
                            ],
                          ))),
                    );
                  });
            }
            if (snapshot.hasError) {
              return Text("exist error");
            }
            return CircularProgressIndicator();
          }),
    );
  }
}
