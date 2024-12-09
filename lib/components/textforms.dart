import 'package:flutter/material.dart';

class CostumTextForm extends StatelessWidget {
  final String hint;
  final TextEditingController mycontroller;
  final Icon icon;
  final TextInputType? keyboard;
  final bool is_password;
  const CostumTextForm(
      {super.key,
      required this.mycontroller,
      required this.hint,
      required this.icon,
      required this.keyboard,
      required this.is_password});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
        controller: mycontroller,
        decoration: InputDecoration(
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50),
                borderSide: BorderSide(color: Colors.white)),
            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50),
                borderSide: BorderSide(color: Colors.black)),
            hintText: hint,
            hintStyle: TextStyle(
                color: Colors.blue,
                fontSize: 14,
                fontWeight: FontWeight.normal),
            icon: icon),
        keyboardType: keyboard!,
        obscureText: is_password);
  }
}
