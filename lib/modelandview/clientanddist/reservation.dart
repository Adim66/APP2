import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

// ignore: must_be_immutable
class ReservationPage extends StatefulWidget {
  String? idproduct;

  ReservationPage({super.key, required this.idproduct});
  @override
  _ReservationPageState createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage> {
  List<Marker> _markers = [];
  final Location _loc = Location();
  LatLng? _initialPos;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _loadDistributors();
  }

  List<LatLng> distributorPositions = [];
  List<QueryDocumentSnapshot> dists = [];

  void _loadDistributors() async {
    distributorPositions.clear();
    QuerySnapshot users = await FirebaseFirestore.instance
        .collection("Users")
        .where("type", isEqualTo: "Distributor")
        .get();
    ;
    dists.addAll(users.docs);

    for (int i = 0; i < dists.length; i++) {
      distributorPositions
          .add(LatLng(dists[i]["latitude"], dists[i]["longitude"]));
      print(distributorPositions[i].latitude);
    }

    setState(() {
      _markers = distributorPositions.map((position) {
        return Marker(
          point: position,
          child: IconButton(
              onPressed: () {
                _showReservationDialog(position);
              },
              icon: Icon(Icons.location_on_rounded, color: Colors.red)),
        );
      }).toList();
    });
  }

  void ajouterPanier(LatLng pos) async {
    final now = DateTime.now();
    QuerySnapshot q = await FirebaseFirestore.instance
        .collection("Users")
        .where("latitude", isEqualTo: pos.latitude)
        .where("longitude", isEqualTo: pos.longitude)
        .get();

    List<QueryDocumentSnapshot> distrid = q.docs;
    print(distrid[0].id);

    DocumentReference doc =
        FirebaseFirestore.instance.collection("Users").doc(distrid[0].id);
    print("aaaaaaaaaaaaaaaaaaaa");

    DocumentReference docc = await doc.collection("reservation").add({
      "Client": FirebaseAuth.instance.currentUser!.email,
      "product": widget.idproduct,
      "Date": "${now.day}/${now.month}/${now.year}",
      "Time": "${now.hour}:${now.minute}:${now.second}",
      "dest_phone": "${distrid[0]["Phone_Number"]}",
      "des_lat": "${distrid[0]["latitude"]}",
      "des_long": "${distrid[0]["longitude"]}"
    });
    print("hhhhhhhhhhhhhhhhhhhhh");
  }

  Future _getCurrentLocation() async {
    try {
      final locationData = await _loc.getLocation();
      setState(() {
        _initialPos = LatLng(locationData.latitude!, locationData.longitude!);
      });
    } catch (e) {
      print("Erreur lors de l'obtention de la position: $e");
    }
  }

  void _showReservationDialog(LatLng position) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Ajouter une réservation'),
          content: Text('Voulez-vous ajouter cette réservation au panier?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                ajouterPanier(position);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Demande Added')),
                );
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Demande'),
        ),
        body: _initialPos == null
            ? Center(child: CircularProgressIndicator())
            : FlutterMap(
                options: MapOptions(
                  initialCenter: _initialPos!,
                  initialZoom: 10,
                ),
                children: [
                  TileLayer(
                      urlTemplate:
                          "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                      userAgentPackageName:
                          'com.example.flutter_application_2'),
                  MarkerLayer(markers: _markers),
                ],
              ));
  }
}
/// users fih el localisations w kol user ypointy 3al tab d
/// e reservations elly 3amlouh les clients 
/// nthbtou f liste des reservations fil page mte3 el admindist , 
/// wnsalla7 tsawer w profil w c bon