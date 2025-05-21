import 'package:flutter/material.dart';

class HelperFunctions {
  static void showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  // Add more helper functions as needed
}
