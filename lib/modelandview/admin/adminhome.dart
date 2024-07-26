import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/modelandview/projects/produits.dart';
import 'package:provider/provider.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  List<QueryDocumentSnapshot> list = [];
  bool isloading = true;
  List<String> screens = ["addProduct", "addproject"];

  getdata() async {
    await PoductsManager.getdata();
    list = PoductsManager.listproducts;
    isloading = false;
    setState(() {}); //faire le build  ssi data is loaded;
  }

  @override
  void initState() {
    getdata();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PoductsManager>(
        builder: (context, model, child) => isloading
            ? Center(child: CircularProgressIndicator(color: Colors.blue))
            : Scaffold(
                appBar: AppBar(
                  elevation: 10,
                  title: Text(
                    "Admin Home ",
                    style: TextStyle(color: Colors.blue),
                  ),
                  centerTitle: true,
                  backgroundColor: Color.fromARGB(221, 237, 236, 233),
                ),
                body: ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (BuildContext context, int index) {
                    if (list.isEmpty) {
                      AwesomeDialog(
                        context: context,
                        dialogType: DialogType.info,
                        animType: AnimType.scale,
                        title: 'There is no Product now ',
                        desc: 'vide',
                      ).show();
                    }
                    return Product(
                      image: PoductsManager.listproducts[index]['url'],
                      productname: PoductsManager.listproducts[index]['name'],
                    );
                  },
                ),
                floatingActionButton: FloatingActionButton(onPressed: () {
                  Navigator.of(context).pushNamed("addProduct");

                  //print(model.listproducts.length);
                }),
                bottomNavigationBar: BottomNavigationBar(
                  items: [
                    BottomNavigationBarItem(
                        icon: Icon(Icons.production_quantity_limits,
                            color: Colors.black),
                        label: "Add Product"),
                    BottomNavigationBarItem(
                        icon: Icon(Icons.group, color: Colors.black),
                        label: "Add Project")
                  ],
                  currentIndex: 0,
                  onTap: (indice) {
                    print(indice);
                    Navigator.of(context).pushNamed(screens[indice]);
                  },
                  backgroundColor: Colors.grey,
                )));
  }
}
