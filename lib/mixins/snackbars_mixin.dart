import 'package:flutter/material.dart';

mixin SnackBarsMixin {
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSnackBarWithText(BuildContext context, String text) {
    return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(text),
    ));
  }
}