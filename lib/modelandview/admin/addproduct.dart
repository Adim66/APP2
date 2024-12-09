import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/components/textforms.dart';
import 'package:flutter_application_2/modelandview/projects/produits.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class AddScreen extends StatefulWidget {
  const AddScreen({super.key});

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  TextEditingController name = TextEditingController();
  TextEditingController desc = TextEditingController();
  Uint8List? _imageBytes;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _pickImage() async {
    //print(
    //  "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.image, withData: true);
    print(
        "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
    print(result);
    if (result != null) {
      _imageBytes = result.files.single.bytes;
      if (_imageBytes != null) {
        // Use a UUID to generate a unique filename
        String uniqueFileName = Uuid().v4();

        Reference storageRef = FirebaseStorage.instance
            .ref("products_images")
            .child("$uniqueFileName.png");

        try {
          var uploadTask = await storageRef.putData(
              _imageBytes!, SettableMetadata(contentType: 'image/png'));
          String imageUrl = await storageRef.getDownloadURL();

          await FirebaseFirestore.instance.collection("produits").add({
            "id": FirebaseAuth.instance.currentUser!.uid,
            "img_url": imageUrl,
            "name": name.text
          });

          setState(() {
            _imageBytes = null;
          });
        } catch (e) {
          print(e);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Product added successfully!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PoductsManager>(
      builder: (context, model, child) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Add Product"),
              SizedBox(height: 10),
              CostumTextForm(
                mycontroller: name,
                hint: "Enter the product's title",
                icon: Icon(Icons.title),
                keyboard: TextInputType.name,
                is_password: false,
              ),
              SizedBox(height: 10),
              CostumTextForm(
                  mycontroller: desc,
                  hint: "Enter Description",
                  icon: Icon(Icons.description),
                  keyboard: TextInputType.text,
                  is_password: false),
              SizedBox(height: 10),
              TextButton.icon(
                onPressed: _pickImage,
                icon: Icon(Icons.image),
                label: Text('Select Image'),
              ),
              SizedBox(height: 30),
              _isLoading ? CircularProgressIndicator() : Container(),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
