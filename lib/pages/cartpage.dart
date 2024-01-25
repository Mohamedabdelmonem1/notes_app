import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  getData2() async {
    var response = await FirebaseFirestore.instance
        .collection("cart")
        .where("userid", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get();
    return response;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cartpage"),
      ),
      body: FutureBuilder(
          future: getData2(),
          builder: (context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (context, i) {
                    return Dismissible(
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding:const EdgeInsets.all(10.0),
                          child:const Icon(
                            Icons.delete,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        onDismissed: (direction) async {
                          await FirebaseFirestore.instance
                              .collection("cart")
                              .doc(snapshot.data.docs[i].id)
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
                                    "${snapshot.data.docs[i]['title']}",
                                    style:
                                        TextStyle(
                                            fontSize: 18,fontWeight: FontWeight.bold),
                                  ),
                                  subtitle:
                                      Text("${snapshot.data.docs[i]['notes']}",style:

                                        TextStyle(fontWeight: FontWeight.bold),),
                                )),
                          ],
                        )));
                  });
            }
            if (snapshot.hasError) {
              return Text("exist error");
            }
            return Center(child: CircularProgressIndicator());
          }),
    );
  }
}
