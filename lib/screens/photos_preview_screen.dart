import 'dart:io';

import 'package:camera/camera.dart';
import 'package:dev_eza_api/main.dart';
import 'package:dio/dio.dart';
import 'package:ffw_photospaces/screens/photo_preview_screen.dart';
import 'package:flutter/material.dart';

class PhotosPreviewScreen extends StatefulWidget {
  final List<XFile> _photos;

  PhotosPreviewScreen(this._photos, {Key? key}) : super(key: key);

  @override
  State<PhotosPreviewScreen> createState() => _PhotosPreviewScreenState();
}

class _PhotosPreviewScreenState extends State<PhotosPreviewScreen> {
  final List<XFile> _selectedPhotos = [];

  bool isSelectMode = false;

  var successFullUploadsCount = 0;

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
            ...widget._photos
                .map(
                  (photo) => GestureDetector(
                    onTap: () => togglePhotoSelect(photo),
                    onDoubleTap: () =>
                        Navigator.push(context, MaterialPageRoute(builder: (_) => PhotoPreviewScreen(photo))),
                    onLongPress: () => setState(() {
                      isSelectMode = true;
                      _selectedPhotos.add(photo);
                    }),
                    child: Stack(children: [
                      Positioned(
                           child: SizedBox(width: 100, height: 100,child: FittedBox( fit: BoxFit.fill,child: Image.file(File(photo.path))))),
                      if (isSelectMode)
                        _selectedPhotos.contains(photo)
                            ? const Positioned(
                                top: 0,
                                right: 0,
                                child: Icon(
                                  Icons.check_circle,
                                  color: Colors.white,
                                ))
                            : const Positioned(
                                top: 0,
                                right: 0,
                                child: Icon(
                                  Icons.radio_button_unchecked,
                                  color: Colors.white,
                                ))
                    ]),
                  ),
                )
                .toList(),
            Align(
              alignment: Alignment.bottomCenter,
              child: GestureDetector(
                child: const Icon(
                  Icons.save,
                  color: Colors.red,
                ),
                onTap: () async {
                  successFullUploadsCount = 0;
                  ScaffoldMessenger.of(context).showSnackBar(uploadingSnackBar());
                  for (var file in _selectedPhotos) {
                    await DevEzaApi.ezFileEndpoints
                        .uploadPost(FormData.fromMap({
                      "assetId": "c37744ff-938d-4614-a29e-a386d1db3d63",
                      "Type": "3",
                      "File": await MultipartFile.fromFile(file.path)
                    }))
                        .then((value) {
                      print(value);
                      setState(() {
                        successFullUploadsCount++;
                      });
                    }).catchError((e) => print(e));
                  }
                  ScaffoldMessenger.of(context).showSnackBar(successfulUploadSnackBar());
                },
              ),
            )
          ],
        ));
  }

  void togglePhotoSelect(XFile photo) => isSelectMode
      ? setState(() {
          !_selectedPhotos.contains(photo) ? _selectedPhotos.add(photo) : _selectedPhotos.remove(photo);
        })
      : null;

  SnackBar successfulUploadSnackBar() {
    return SnackBar(
      content: Text('Successfully uploaded $successFullUploadsCount  of ${_selectedPhotos.length} pictures.'),
      action: SnackBarAction(
        label: 'Ok',
        onPressed: () {},
      ),
    );
  }

  SnackBar uploadingSnackBar() {
    return const SnackBar(
      content: Text('Uploading, please wait.'),
    );
  }
}
