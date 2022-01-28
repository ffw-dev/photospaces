import 'dart:io';

import 'package:ffw_photospaces/data_transfer_objects/selectable_photo_wrapper.dart';
import 'package:flutter/cupertino.dart';

class PhotoAnimatedContainer extends StatefulWidget {
  final SelectablePhotoWrapper photoWrapper;
  final double gridTileWidth;
  final double gridTileHeight;

  const PhotoAnimatedContainer({Key? key, required this.photoWrapper, required this.gridTileWidth, required this.gridTileHeight}) : super(key: key);

  @override
  State<PhotoAnimatedContainer> createState() => _PhotoAnimatedContainerState();
}

class _PhotoAnimatedContainerState extends State<PhotoAnimatedContainer> {
  @override
  Widget build(BuildContext context) {
    return Positioned(
        child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: widget.gridTileWidth,
            height: widget.gridTileHeight,
            child: Image.file(
              File(widget.photoWrapper.photo.path),
              fit: BoxFit.cover,
            )));
  }
}
