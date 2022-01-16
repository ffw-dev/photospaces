import 'dart:io';

import 'package:camera/camera.dart';
import 'package:ffw_photospaces/screens/photo_preview_screen.dart';
import 'package:flutter/material.dart';

class PhotosPreviewScreen extends StatelessWidget {
  final List<XFile> photos;

  const PhotosPreviewScreen(this.photos, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: GridView.count(
        primary: false,
        crossAxisCount: 4,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
        children: <Widget>[
          ...photos
              .map(
                (photo) => GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PhotoPreviewScreen(photo))),
              child: Container(
                child: FittedBox(fit: BoxFit.fill,child: Image.file(File(photo.path))),
              ),
            ),
          )
              .toList()
        ],
      )
    );
  }
}
