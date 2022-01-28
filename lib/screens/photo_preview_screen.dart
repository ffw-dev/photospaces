import 'dart:io';
import 'package:flutter/material.dart';

import 'package:ffw_photospaces/data_transfer_objects/selectable_photo_wrapper.dart';

class PhotoPreviewScreen extends StatefulWidget {
  final List<SelectablePhotoWrapper> photos;
  final int clickedImageIndex;
  final Function(String description) updateParentsDTOCallback;

  const PhotoPreviewScreen(this.photos, this.clickedImageIndex, {Key? key, required this.updateParentsDTOCallback}) : super(key: key);

  @override
  State<PhotoPreviewScreen> createState() => _PhotoPreviewScreenState();
}

class _PhotoPreviewScreenState extends State<PhotoPreviewScreen> {
  int currentPhotoIndex = 0;

  @override
  void initState() {
    super.initState();
    currentPhotoIndex = widget.clickedImageIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.6,
              child: FittedBox(
                  fit: MediaQuery.of(context).orientation == Orientation.landscape ? BoxFit.contain : BoxFit.fitWidth,
                  child: GestureDetector(
                      onHorizontalDragEnd: swipeHandler,
                      child: InteractiveViewer(child: Image.file(File(widget.photos[currentPhotoIndex].photo.file.path)))))),
        ],
      ),
    );
  }

  void swipeHandler(details) {
    // Swiping in right direction.
    if (details.primaryVelocity! < 0) {
      setState(() {
        if (currentPhotoIndex < widget.photos.length - 1) {
          currentPhotoIndex++;
        }
      });
    }

    // Swiping in left direction.
    if (details.primaryVelocity! > 0) {
      setState(() {
        if (currentPhotoIndex != 0) {
          currentPhotoIndex--;
        }
      });
    }
  }
}
