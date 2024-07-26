import 'package:flutter/material.dart';
import 'package:flutter_application_2/components/textforms.dart';
import 'package:flutter_application_2/modelandview/projects/produits.dart';
import 'package:provider/provider.dart';

class AddScreen extends StatefulWidget {
  const AddScreen({super.key});

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  TextEditingController url = TextEditingController();
  TextEditingController name = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Consumer<PoductsManager>(
        builder: (context, model, child) => Scaffold(
                body: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                  Text("Add Product"),
                  CostumTextForm(
                      mycontroller: url,
                      hint: "Enter image Url",
                      icon: Icon(Icons.web)),
                  Container(height: 10),
                  Text("Product Type"),
                  Container(height: 10),
                  CostumTextForm(
                      mycontroller: name,
                      hint: "Enter the product's title ",
                      icon: Icon(Icons.title)),
                  Container(height: 30),
                  ElevatedButton(
                      child: Text("onpressed"),
                      onPressed: () {
                        model.ajouterproduct(url: url.text, namep: name.text);
                      }),
                ])));
  }
}
