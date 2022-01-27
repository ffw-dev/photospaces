import 'dart:io';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:ffw_photospaces/data_transfer_objects/file_data_transfer_object.dart';
import 'package:ffw_photospaces/widgets/base_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomDialogBox extends StatefulWidget {
  final FileDataTransferObject<XFile> photoDTO;

  const CustomDialogBox(
      {Key? key, required this.photoDTO})
      : super(key: key);

  @override
  _CustomDialogBoxState createState() => _CustomDialogBoxState();
}

class _CustomDialogBoxState extends State<CustomDialogBox> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  contentBox(context) {
    var RADIUS = const BorderRadius.all(Radius.circular(20));
    var MEDIAQUERY_HEIGHT_ADJUSTED = MediaQuery.of(context).size.height * 0.4;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: SizedBox(
            height: MEDIAQUERY_HEIGHT_ADJUSTED,
            child: Material(
              elevation: 12,
              borderRadius: RADIUS,
              color: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: RADIUS,
                  color: Colors.red,
                  image: DecorationImage(image: FileImage(File(widget.photoDTO.file.path)), fit: BoxFit.fill),
                ),
                child: null,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.delete,
                    color: Theme.of(context).primaryColor,
                  ),
                  BaseButton(
                    'Remove image',
                    null,
                    () => Navigator.pop(context),
                    textColour: Theme.of(context).primaryColor,
                    fontSize: 14,
                    padding: 0,
                  )
                ],
              ),
              BaseButton(
                'Close',
                null,
                () => Navigator.pop(context),
                textColour: Colors.white,
                fontSize: 14,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
