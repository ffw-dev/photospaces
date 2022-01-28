import 'dart:io';
import 'package:ffw_photospaces/data_transfer_objects/selectable_photo_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:ffw_photospaces/screens/photos_preview_screen.dart';

class LastPhotoIndicator extends StatelessWidget {
  final List<SelectablePhotoWrapper> photos;

  const LastPhotoIndicator({Key? key, required this.photos}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PhotosPreviewScreenConnector())),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: SizedBox(
            width: 70,
            height: 70,
            child: FittedBox(
                alignment: Alignment.center, fit: BoxFit.fill, child: Image.file(File(photos.last.photo.path)))),
      ),
    );
  }
}
