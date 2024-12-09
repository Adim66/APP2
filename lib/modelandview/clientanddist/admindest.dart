import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/modelandview/projects/produits.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class DistributorMainHomePage extends StatefulWidget {
  @override
  _DistributorMainHomePageState createState() =>
      _DistributorMainHomePageState();
}

class _DistributorMainHomePageState extends State<DistributorMainHomePage> {
  Location _location = Location();
  LatLng? _currentPosition;
  List<QueryDocumentSnapshot> list = [];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    loadReservation();
  }

  Future _getCurrentLocation() async {
    try {
      final locationData = await _location.getLocation();
      setState(() {
        _currentPosition =
            LatLng(locationData.latitude!, locationData.longitude!);
      });
    } catch (e) {
      print("Erreur lors de l'obtention de la position: $e");
    }
  }

  loadReservation() async {
    QuerySnapshot q = await FirebaseFirestore.instance
        .collection("Users")
        .where("id", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get();
    QueryDocumentSnapshot doc = q.docs[0];
    QuerySnapshot res = await FirebaseFirestore.instance
        .collection("Users")
        .doc(doc.id)
        .collection("reservation")
        .get();
    list.clear();
    list.addAll(res.docs);
    print(list.length);
    setState(() {});
  }

  void showSnackBar(BuildContext context,
      {required String name, required String url}) {
    final snackBar = SnackBar(
      content: Product(productname: name, image: url),
      action: SnackBarAction(
        label: 'OK',
        onPressed: () {
          // Some code to undo the change
        },
      ),
      width: 200,
      behavior: SnackBarBehavior.floating,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  saveDis() async {
    QuerySnapshot q = await FirebaseFirestore.instance
        .collection("Users")
        .where("id", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get();
    QueryDocumentSnapshot doc = q.docs[0];

    await FirebaseFirestore.instance.collection("Users").doc(doc.id).set({
      "id": FirebaseAuth.instance.currentUser!.uid,
      "type": "Distributor",
      "latitude": _currentPosition!.latitude,
      "longitude": _currentPosition!.longitude
    });

    /* QueryDocumentSnapshot thisdit = listdist.docs[0];
    await FirebaseFirestore.instance
        .collection("distributers")
        .doc(thisdit.id)
        .set({
      "latitude": _currentPosition!.latitude,
      "longitude": _currentPosition!.longitude,
      "email": FirebaseAuth.instance.currentUser!.email,
      "id": FirebaseAuth.instance.currentUser!.uid
    });
    print("coooooooooooooooooooooooooooooooooooool");*/
  }

  void _updatePosition() {
    // Logique pour envoyer la position mise à jour au serveur ou à Firestore
    print("Position mise à jour: $_currentPosition");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Position mise à jour')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Distributeur Main Home'),
          actions: [
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: () {
                FirebaseAuth.instance.signOut();
                Navigator.of(context).pushNamed("login");
              },
            ),
          ],
        ),
        body: list.isEmpty
            ? Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                    if (_currentPosition != null)
                      Text(
                          'Position actuelle: ${_currentPosition!.latitude}, ${_currentPosition!.longitude}'),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _getCurrentLocation,
                      child: Text('Mettre à jour ma position'),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        saveDis();
                      },
                      child: Text('Envoyer ma position'),
                    )
                  ]))
            : Center(
                child: ListView.builder(
                itemCount: list.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                      focusColor: Color.fromARGB(0, 39, 39, 173),
                      tileColor: Color.fromARGB(19, 6, 41, 132),
                      title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text(list[index]["Client"]),
                            Text(list[index]["Date"])
                          ]),
                      iconColor: Color.fromARGB(129, 19, 114, 192),
                      onTap: () async {
                        print(list[index]["product"]);
                        DocumentReference pro = await FirebaseFirestore.instance
                            .collection("produits")
                            .doc(list[index]["product"]);
                        DocumentSnapshot snapshot = await pro.get();
                        print("555555555555555555555");
                        print(snapshot["name"]);
                        showSnackBar(context,
                            name: snapshot["name"], url: snapshot["url"]);
                      });
                },
              ))
        ///// ajouter une fct pour loading des reservations et afficher un nelisteview pour ennumerv les reservations
        );
  }
}
