import 'package:flutter/material.dart';

mixin SnackBarsMixin {
  SnackBar showSnackBarWithText(String text) {
    return SnackBar(
      content: Text(text),
    );
  }
}