import 'package:ffw_photospaces/services/current_locales_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EmptyDescriptionSnackBar extends SnackBar {
  EmptyDescriptionSnackBar.create(BuildContext context)
      : super(
          content: SnackBar(
              content: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                CurrentLocalesService.screenPhotosPreview.componentEmptyDescriptionModal.text,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
          )),
        );

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
