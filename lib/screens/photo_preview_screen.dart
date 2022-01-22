import 'dart:io';

import 'package:camera/camera.dart';
import 'package:ffw_photospaces/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PhotoPreviewScreen extends StatefulWidget {
  final List<XFile> photos;
  final int clickedImageIndex;

  const PhotoPreviewScreen(this.photos, this.clickedImageIndex, {Key? key}) : super(key: key);

  @override
  State<PhotoPreviewScreen> createState() => _PhotoPreviewScreenState();
}

class _PhotoPreviewScreenState extends State<PhotoPreviewScreen> {
  final TextEditingController _textEditingController = TextEditingController();
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
                      child: InteractiveViewer(child: Image.file(File(widget.photos[currentPhotoIndex].path)))))),
          ElevatedButton(
            onPressed: () {
              showModalBottomSheet(context: context, builder: buildAddDescriptionModal);
            },
            child: Text(currentLocalesService.photo_preview_screen['add_description']),
          ),
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

  Widget buildAddDescriptionModal(context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          Text(currentLocalesService.photo_preview_screen['description']),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: TextField(
              controller: _textEditingController,
              textAlign: TextAlign.center,
              maxLength: 60,
              maxLengthEnforcement: MaxLengthEnforcement.none,
            ),
          ),
          ElevatedButton(
              onPressed: () {
                if (_textEditingController.text.length > 60) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(currentLocalesService.photo_preview_screen['max_char_exceeded'])));
                  return;
                }
                setState(() {
                  _textEditingController.text = '';
                });
                Navigator.of(context).pop();
              },
              child: const Text('Add'))
        ],
      ),
    );
  }
}
