import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
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

  saveDis() async {
    print(
        "vvvvvvvvvvvvvvvvvvvvvvvvvvooooooooooooooiiiiiiiiiiiiiidddddddddddddddd");
    await FirebaseFirestore.instance.collection("distributers").add({
      "latitude": _currentPosition!.latitude,
      "longitude": _currentPosition!.longitude,
      "email": FirebaseAuth.instance.currentUser!.email,
      "id": FirebaseAuth.instance.currentUser!.uid
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
      ),
      body: Center(
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
            ),
          ],
        ),
      ),
    );
  }
}
