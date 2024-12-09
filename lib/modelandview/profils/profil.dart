import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class Profil extends StatefulWidget {
  @override
  State<Profil> createState() => _ProfilState();
}

class _ProfilState extends State<Profil> {
  Uint8List? _imageBytes;
  late String profileImageUrl;
  List<QueryDocumentSnapshot> list_licked = [];
  List<QueryDocumentSnapshot> list_des = [];
  bool contact_is_loading = true;
  bool liked_products_isloading = true;

  bool loaded = false;
  loadMLastDestriutors() async {
    List<QueryDocumentSnapshot> des = [];
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("Users")
        .where("type", isEqualTo: "Distributor")
        .get();
    des = querySnapshot.docs;
    print("jjjjjjjjjjjjjjjjj");
    print(des.length);
    print(des[0].get("Phone_Num"));
    List<QueryDocumentSnapshot> res = [];
    des.forEach((element) async {
      QuerySnapshot q = await FirebaseFirestore.instance
          .collection("Users")
          .doc(element.id)
          .collection("reservation")
          .where("Client", isEqualTo: FirebaseAuth.instance.currentUser!.email)
          .get();
      res.addAll(q.docs);
      print("hhhhhhh");
      print(res.length);
      list_des.addAll(res);
      contact_is_loading = false;
      setState(() {});
    });
  }

  Future<void> _pickImage() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null) {
      _imageBytes = result.files.single.bytes;
      if (_imageBytes != null) {
        Reference storage = FirebaseStorage.instance
            .ref("profile_images")
            .child("${FirebaseAuth.instance.currentUser!.uid}.png");

        var uploadTask = await storage.putData(
            _imageBytes!, SettableMetadata(contentType: 'image/png'));
        profileImageUrl = await storage.getDownloadURL();
        await FirebaseFirestore.instance.collection("profils").add(
          {
            "id": FirebaseAuth.instance.currentUser!.uid,
            "img_url": profileImageUrl
          },
        );
      }
    }

    setState(() {});
  }

  Future<void> loadProfileImage() async {
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection("profils")
        .where("id", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get();
    print(query.docs.length);
    if (query.docs.isNotEmpty) {
      profileImageUrl = query.docs[0]["img_url"];
      print(query.docs[0].id);
      print(profileImageUrl);
      loaded = true;
      setState(() {});
    }
  }

  LoadLickedProduct() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("history")
        .where("user", isEqualTo: FirebaseAuth.instance.currentUser!.email)
        .get();
    list_licked = querySnapshot.docs;
    liked_products_isloading = false;
    print("gggggggggggggggggggggggg");
    print(list_licked.length);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    loadProfileImage();

    LoadLickedProduct();

    loadMLastDestriutors();
  }

  void _showPicker(context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Photo Library'),
                onTap: () {
                  _pickImage();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(loaded ? 'Profil ' : 'Loading Profil...'),
        backgroundColor: Colors.blue,
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            }),
        actions: [
          IconButton(
            onPressed: () async {
              try {
                await FirebaseAuth.instance.signOut();

                Navigator.of(context).pushReplacementNamed('login');
              } catch (e) {
                print('Error signing out: $e');
              }
            },
            icon: Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // User Image
                GestureDetector(
                  onTap: () {
                    _showPicker(context);
                  },
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: _imageBytes != null
                        ? MemoryImage(_imageBytes!)
                        : loaded && profileImageUrl.isNotEmpty
                            ? NetworkImage("${profileImageUrl}")
                                as ImageProvider
                            : NetworkImage("url"),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'User Information',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  "${FirebaseAuth.instance.currentUser!.email}",
                  style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                ),
                SizedBox(height: 32),

                // Liked Products Section
                Text(
                  'Liked Products',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                SizedBox(height: 16),
                Text("${list_licked.length} Liked Products"),
                liked_products_isloading
                    ? CircularProgressIndicator()
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: list_licked.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: ListTile(
                                leading:
                                    Image.network(list_licked[index]['url']!),
                                title:
                                    Text(list_licked[index]['product-name']!),
                              ),
                            ),
                          );
                        },
                      ),
                SizedBox(height: 32),

                // Recent Distributors Contacts Section
                Text(
                  'Recent Distributors Contacts',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                SizedBox(height: 16),
                contact_is_loading
                    ? CircularProgressIndicator()
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: list_des.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: ListTile(
                                leading: Icon(
                                  Icons.contact_mail,
                                  color: Colors.blue,
                                ),
                                title: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(list_des[index]['dest_mail']),
                                    ]),
                                subtitle: Text(list_des[index]['dest_phone']),
                              ),
                            ),
                          );
                        },
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
