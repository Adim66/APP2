import 'dart:async';

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

class _AdminclientState extends State<Adminclient>
    with TickerProviderStateMixin {
  List<String> descriptions = ["Awesome quality", "Durable", "Best in class"];
  List<QueryDocumentSnapshot> list = [];
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  late AnimationController _marqueeController;
  late ScrollController _scrollController;

  loadproducts() async {
    await PoductsManager.getdata();
    list = PoductsManager.listproducts;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);

    _scaleController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _scaleAnimation =
        CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut);

    _scrollController = ScrollController();
    _marqueeController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    loadproducts();

    Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_scrollController.hasClients) {
        _scrollController
            .animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(seconds: 5),
          curve: Curves.linear,
        )
            .then((_) {
          _scrollController.jumpTo(_scrollController.position.minScrollExtent);
        });
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _marqueeController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PoductsManager>(
      builder: (context, model, child) => Scaffold(
        appBar: AppBar(
          elevation: 4,
          title: Text(
            " Hi ${FirebaseAuth.instance.currentUser!.email} !",
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: Colors.blueGrey,
          actions: [
            IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed("profil");
              },
              icon: Icon(Icons.person_4_outlined),
            ),
          ],
        ),
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                      "lib/assets/Knauf-usine-belgique-1319x800.jpg"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Column(
              children: [
                Container(
                  height: 50,
                  color: Color.fromARGB(255, 179, 236, 238),
                  child: AnimatedBuilder(
                    animation: _marqueeController,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(
                          -_marqueeController.value *
                              MediaQuery.of(context).size.width *
                              2,
                          0,
                        ),
                        child: child,
                      );
                    },
                    child: Center(
                      child: Text(
                        "KNAUF Maknessy",
                        style: TextStyle(
                          fontSize: 24,
                          color: Color.fromARGB(255, 230, 86, 39),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: PoductsManager.listproducts.length,
                    itemBuilder: (BuildContext context, int index) {
                      _fadeController.forward();
                      _scaleController.forward();

                      return FadeTransition(
                        opacity: _fadeAnimation,
                        child: ScaleTransition(
                          scale: _scaleAnimation,
                          child: Card(
                            elevation: 4,
                            margin: EdgeInsets.all(10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: InkWell(
                              onLongPress: () {
                                print(PoductsManager.listproducts[index]
                                    ['img_url']);

                                model.history(
                                    name: PoductsManager.listproducts[index]
                                        ["name"],
                                    user: FirebaseAuth
                                        .instance.currentUser!.email!,
                                    url: PoductsManager.listproducts[index]
                                        ["img_url"]);
                              },
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ReservationPage(
                                      idproduct:
                                          PoductsManager.listproducts[index].id,
                                    ),
                                  ),
                                );
                              },
                              child: Column(
                                children: [
                                  Container(
                                    height: 200,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(15),
                                        topRight: Radius.circular(15),
                                      ),
                                      image: DecorationImage(
                                        image: NetworkImage(
                                          PoductsManager.listproducts[index]
                                              ['img_url'],
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          PoductsManager.listproducts[index]
                                              ['name'],
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blueGrey[800],
                                          ),
                                        ),
                                        SizedBox(height: 10),
                                        Text(
                                          descriptions[
                                              index % descriptions.length],
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.blueGrey[600],
                                          ),
                                        ),
                                        SizedBox(height: 10),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            IconButton(
                                              onPressed: () {
                                                AwesomeDialog(
                                                  context: context,
                                                  dialogType: DialogType.info,
                                                  animType: AnimType.topSlide,
                                                  title: PoductsManager
                                                          .listproducts[index]
                                                      ['name'],
                                                  desc: PoductsManager
                                                          .listproducts[index]
                                                      ['desc'],
                                                ).show();
                                              },
                                              icon: Icon(Icons.description,
                                                  color: Colors.blueGrey),
                                            ),
                                            Icon(Icons.construction,
                                                color: Colors.blueGrey),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
