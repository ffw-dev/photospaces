import 'dart:io';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:ffw_photospaces/data_transfer_objects/file_data_transfer_object.dart';
import 'package:ffw_photospaces/widgets/base_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AnimatedPhotoDialogBox extends StatefulWidget {
  final FileDataTransferObject<XFile> photoDTO;
  final VoidCallback callback;

  const AnimatedPhotoDialogBox({Key? key, required this.photoDTO, required this.callback}) : super(key: key);

  @override
  _AnimatedPhotoDialogBoxState createState() => _AnimatedPhotoDialogBoxState();
}

class _AnimatedPhotoDialogBoxState extends State<AnimatedPhotoDialogBox> {
  var RADIUS = const BorderRadius.all(Radius.circular(20));
  double MEDIAQUERY_HEIGHT_ADJUSTED = 10;
  double MEDIAQUERY_WIDTH_ADJUSTED = 10;

  var isFullScreenMode = false;

  @override
  void initState() {
    Future.delayed(Duration(milliseconds: 100), () {
      setState(() {
        MEDIAQUERY_HEIGHT_ADJUSTED = 500;
        MEDIAQUERY_WIDTH_ADJUSTED = 500;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: GestureDetector(
        onVerticalDragStart: (_) => Navigator.pop(context),
        child: Dialog(
          insetPadding: isFullScreenMode ? const EdgeInsets.symmetric(vertical: 0, horizontal: 4) : const EdgeInsets.symmetric(horizontal:0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Padding(padding: isFullScreenMode ? const EdgeInsets.symmetric(vertical: 0, horizontal: 4) : const EdgeInsets.symmetric(horizontal:20),
          child: contentBox(context)),
        ),
      ),
    );
  }

  contentBox(context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          height: MEDIAQUERY_HEIGHT_ADJUSTED,
          width: MEDIAQUERY_WIDTH_ADJUSTED,
          child: GestureDetector(
            onVerticalDragStart: (_) => Navigator.of(context).pop(),
            onVerticalDragCancel: () => setState(() {
              isFullScreenMode = !isFullScreenMode;
              MEDIAQUERY_HEIGHT_ADJUSTED == 500 ? MEDIAQUERY_HEIGHT_ADJUSTED = 700 : MEDIAQUERY_HEIGHT_ADJUSTED = 500;
              MEDIAQUERY_WIDTH_ADJUSTED == 500 ? MEDIAQUERY_WIDTH_ADJUSTED = 700 : MEDIAQUERY_WIDTH_ADJUSTED = 500;
            }),
            child: Material(
              elevation: 0,
              borderRadius: RADIUS,
              color: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: RADIUS,
                  color: Colors.transparent,
                  image: DecorationImage(image: FileImage(File(widget.photoDTO.file.path)), fit: BoxFit.fill),
                ),
                child: null,
              ),
            ),
          ),
        ),
        Flexible(
          child: Visibility(
            visible: !isFullScreenMode,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.delete,
                      color: Theme.of(context).primaryColor.withGreen(240),
                    ),
                    BaseButton(
                      'Remove image',
                      null,
                      () {
                        widget.callback();
                        Navigator.pop(context);
                      },
                      textColour: Theme.of(context).primaryColor.withGreen(240),
                      fontSize: 14,
                      padding: 0,
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
