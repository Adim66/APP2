import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/modelandview/clientanddist/reservation.dart';
import 'package:flutter_application_2/modelandview/projects/produits.dart';
import 'package:provider/provider.dart';

class Adminclient extends StatefulWidget {
  const Adminclient({super.key});

  @override
  State<Adminclient> createState() => _AdminclientState();
}

class _AdminclientState extends State<Adminclient> {
  List<String> descriptions = ["awesome quality ", "2", "3"];
  List<QueryDocumentSnapshot> list = [];
  loadproducts() async {
    await PoductsManager.getdata();
    list = PoductsManager.listproducts;
    setState(() {}); //faire le build  ssi data is loaded;
  }

  @override
  void initState() {
    loadproducts();
    //print(PoductsManager.listproducts.length);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PoductsManager>(
        builder: (context, model, child) => Scaffold(
            appBar: AppBar(
              elevation: 4,
              title: Text(
                "Client Home ",
                style: TextStyle(color: Colors.blue),
              ),
              centerTitle: true,
              actions: [
                IconButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed("staff");
                    },
                    icon: Icon(Icons.person_4_outlined))
              ],
              backgroundColor: Color.fromARGB(221, 237, 236, 233),
            ),
            body: ListView.builder(
                itemCount: PoductsManager.listproducts.length,
                itemBuilder: (BuildContext context, int index) {
                  return InkWell(
                      onLongPress: () {
                        model.history(
                            doc_id: PoductsManager.listproducts[index].id,
                            user_id: FirebaseAuth.instance.currentUser!.uid);
                      },
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ReservationPage(
                                    idproduct: PoductsManager
                                        .listproducts[index].id)));
                      },
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Product(
                              image: PoductsManager.listproducts[index]['url'],
                              productname: PoductsManager.listproducts[index]
                                  ['name'],
                            ),
                            IconButton(
                                onPressed: () {
                                  AwesomeDialog(
                                    context: context,
                                    dialogType: DialogType.info,
                                    animType: AnimType.topSlide,
                                    title: PoductsManager.listproducts[index]
                                        ['name'],
                                    desc: descriptions[0],
                                  ).show();
                                },
                                icon: Icon(Icons.description))
                          ]));
                })));
  }
}
