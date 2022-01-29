import 'dart:io';
import 'dart:ui';

import 'package:ffw_photospaces/data_transfer_objects/selectable_photo_wrapper.dart';
import 'package:ffw_photospaces/widgets/base_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SwipableAnimatedPhotosDialogBox extends StatefulWidget {
  final List<SelectablePhotoWrapper> photos;
  final Function(SelectablePhotoWrapper s) callback;

  final int startingIndex;

  const SwipableAnimatedPhotosDialogBox({Key? key, required this.photos, required this.callback, required this.startingIndex}) : super(key: key);

  @override
  _SwipableAnimatedPhotosDialogBoxState createState() => _SwipableAnimatedPhotosDialogBoxState();
}

class _SwipableAnimatedPhotosDialogBoxState extends State<SwipableAnimatedPhotosDialogBox> {
  var RADIUS = const BorderRadius.all(Radius.circular(20));
  double MEDIAQUERY_HEIGHT_ADJUSTED = 10;
  double MEDIAQUERY_WIDTH_ADJUSTED = 10;
  int photoIndex = 0;

  var isFullScreenMode = false;

  @override
  void initState() {
    photoIndex = widget.startingIndex;

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
          insetPadding: isFullScreenMode
              ? const EdgeInsets.symmetric(vertical: 0, horizontal: 4)
              : const EdgeInsets.symmetric(horizontal: 0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Padding(
              padding: isFullScreenMode
                  ? const EdgeInsets.symmetric(vertical: 0, horizontal: 4)
                  : const EdgeInsets.symmetric(horizontal: 20),
              child: contentBox(context)),
        ),
      ),
    );
  }

  contentBox(context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ...widget.photos
                  .map((e) => Padding(
                        padding: widget.photos.indexOf(e) == photoIndex
                            ? const EdgeInsets.symmetric(horizontal: 4)
                            : const EdgeInsets.symmetric(horizontal: 2),
                        child: Opacity(
                            opacity: widget.photos.indexOf(e) == photoIndex ? 1 : 0.5,
                            child: Icon(
                              Icons.circle,
                              size: widget.photos.indexOf(e) == photoIndex ? 11 : 9,
                              color: Colors.white,
                            )),
                      ))
                  .toList()
            ],
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          height: MEDIAQUERY_HEIGHT_ADJUSTED,
          width: MEDIAQUERY_WIDTH_ADJUSTED,
          child: GestureDetector(
            onHorizontalDragEnd: (details) {
              // Swiping in right direction.
              if (details.primaryVelocity! > 0 && photoIndex > 0) {
                setState(() {
                  photoIndex--;
                });
              }

              // Swiping in left direction.
              else if (details.primaryVelocity! < 0 && photoIndex < widget.photos.length - 1) {
                setState(() {
                  photoIndex++;
                });
              }
            },
            onVerticalDragStart: (_) => Navigator.of(context).pop(),
            onVerticalDragEnd: (_) => setState(() {
              isFullScreenMode = !isFullScreenMode;
              MEDIAQUERY_HEIGHT_ADJUSTED == 500 ? MEDIAQUERY_HEIGHT_ADJUSTED = 700 : MEDIAQUERY_HEIGHT_ADJUSTED = 500;
              MEDIAQUERY_WIDTH_ADJUSTED == 500 ? MEDIAQUERY_WIDTH_ADJUSTED = 700 : MEDIAQUERY_WIDTH_ADJUSTED = 500;
            }),
            child: Material(
              elevation: 0,
              borderRadius: RADIUS,
              color: Colors.transparent,
              child: widget.photos.isEmpty ? null : Container(
                decoration: BoxDecoration(
                  borderRadius: RADIUS,
                  color: Colors.transparent,
                  image:
                  DecorationImage(image: FileImage(File(widget.photos[photoIndex].photo.path)), fit: BoxFit.fill),
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
                        setState(() {
                          widget.callback(widget.photos[photoIndex]);
                          widget.photos.isEmpty
                              ? Navigator.pushNamedAndRemoveUntil(context, '/mockHomeScreen', (route) => false)
                              : null;
                          photoIndex != 0 ? photoIndex-- : photoIndex = 0;
                        });
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
