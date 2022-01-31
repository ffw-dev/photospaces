import 'package:flutter/material.dart';

mixin SnackBarsMixin {
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSnackBarWithTextWithDuration(BuildContext context, String text,
      {int milliseconds = 500}) {
    return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      duration: Duration(milliseconds: milliseconds),
      content: Text(text),
    ));
  }


  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSnackBarPersistWithText(BuildContext context, String text) {
    return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      duration: const Duration(days: 1),
      content: Text(text),
    ));
  }
}