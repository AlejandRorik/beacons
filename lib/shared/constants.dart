import 'package:flutter/material.dart';

const appBarColor = Color.fromARGB(255, 235, 235, 235);
const appButtonColor = Color.fromARGB(255, 120, 123, 140);
const appBackgroundColor1 = Color.fromARGB(255, 74, 224, 211);
const appBackgroundColor2 = Color.fromARGB(255, 71, 112, 214);

const textInputDecoration= InputDecoration(
  fillColor: Colors.transparent, filled: true,
  enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.white, width: 2.0)
  ),
  focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: appBackgroundColor1, width: 2.0)
  ),
  errorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.red, width: 2.0)
  ),
  focusedErrorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.pink, width: 2.0)
  ),
);