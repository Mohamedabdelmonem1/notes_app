import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'package:testproject/auth/signin.dart';
import 'package:testproject/pages/viewpage.dart';

import 'addnote.dart';
import 'cartpage.dart';
import 'editnote.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  getData() async {
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
            context,
            MaterialPageRoute(
              builder: (context) => const Add(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          "Homepage",
          style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
        ),
        actions: [
          Row(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => CartPage()));
                },
                icon: const Icon(Icons.add_shopping_cart),
              ),
              IconButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SignIn(),
                    ),
                  );
                },
                icon: const Icon(Icons.exit_to_app),
              ),
            ],
          )
        ],
      ),
      body: FutureBuilder(
          future: getData(),
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
                                    )));
                      },
                      child: Dismissible(
                        background: Container(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.all(10.0),
                          child:const Icon(
                            Icons.delete,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
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
                          margin: const EdgeInsets.symmetric(vertical: 10),
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
                                    "${snapshot.data.docs[i]['title']}",
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  subtitle:
                                      Text("${snapshot.data.docs[i]['notes']}",
                                        style: const TextStyle(
                                           
                                            fontWeight: FontWeight.bold),
                                      ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => Edit(
                                            docid: snapshot.data.docs[i].id,
                                            list: snapshot.data.docs[i],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  });
            }
            if (snapshot.hasError) {
              return const Text("exist error");
            }
            return const Center(child: const CircularProgressIndicator());
          }),
    );
  }
}
