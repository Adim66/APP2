import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Product extends StatefulWidget {
  final String productname;
  final String image;

  const Product({super.key, required this.productname, required this.image});

  @override
  State<Product> createState() => _ProductState();
}

class _ProductState extends State<Product> {
  late String productname;
  late String image;

  @override
  void initState() {
    super.initState();
    productname = widget.productname;
    image = widget.image;
  }

  @override
  Widget build(BuildContext context) {
    print(image);
    return Card(
      child: Column(
        children: [
          Image(
            image: NetworkImage(image),
            loadingBuilder: (BuildContext context, Widget child,
                ImageChunkEvent? loadingProgress) {
              if (loadingProgress == null) {
                return child;
              } else {
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            (loadingProgress.expectedTotalBytes ?? 1)
                        : null,
                  ),
                );
              }
            },
            errorBuilder:
                (BuildContext context, Object error, StackTrace? stackTrace) {
              return Center(
                child: Column(
                  children: [
                    Icon(Icons.error, color: Colors.red),
                    Text(
                      'Erreur de chargement de l\'image',
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              );
            },
          ),
          Text(
            productname,
            style: TextStyle(color: Colors.blue),
          ),
        ],
      ),
    );
  }
}

class PoductsManager with ChangeNotifier {
  static List<QueryDocumentSnapshot> listproducts = [];

  /* void ajouterproduct({required String url, required String namep}) async {
    DocumentReference doc = await FirebaseFirestore.instance
        .collection("produits")
        .add({"name": namep, "url": url});

    //notifyListeners();
  } //adimboubaker2020@gmail.com*/

  static getdata() async {
    QuerySnapshot list =
        await FirebaseFirestore.instance.collection("produits").get();
    listproducts.clear();
    listproducts.addAll(list.docs);

    //notifyListeners();
  }

  void Update() async {
    await PoductsManager.getdata();
    notifyListeners();
  }

  history(
      {required String name, required String user, required String url}) async {
    DocumentReference history = await FirebaseFirestore.instance
        .collection("history")
        .add({"product-name": name, "user": user, "url": url});
  }
}
