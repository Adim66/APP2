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
    QuerySnapshot query =
        await FirebaseFirestore.instance.collection("distributers").get();
    dists.clear();
    dists.addAll(query.docs);
    for (int i = 0; i < dists.length; i++) {
      distributorPositions
          .add(LatLng(dists[i]["latitude"], dists[i]["longitude"]));
    }
    setState(() {
      _markers = distributorPositions.map((position) {
        return Marker(
          point: position,
          child: const Icon(Icons.location_on, color: Colors.red, size: 30),
        );
      }).toList();
    });
  }

  void ajouterPanier(LatLng pos) async {
    DocumentReference doc =
        await FirebaseFirestore.instance.collection("reservation").add({
      "Reserver": FirebaseAuth.instance.currentUser!.uid,
      "product": widget.idproduct,
      "lat": pos.latitude,
      "long": pos.longitude
    });
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
                  SnackBar(content: Text('Réservation ajoutée au panier')),
                );
              },
              child: Text('Ajouter'),
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
          title: Text('Réservation'),
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
                        "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                    subdomains: ['a', 'b', 'c'],
                  ),
                  MarkerLayer(markers: _markers),
                ],
              ));
  }
}
