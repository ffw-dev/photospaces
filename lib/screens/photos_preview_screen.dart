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
  List<XFile> _selectedPhotos = [];

  bool isSelectMode = false;

  var successFullUploadsCount = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Column(children: [
          Expanded(
            child: GridView.count(
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
                              child: SizedBox(
                                  width: 100,
                                  height: 100,
                                  child: FittedBox(fit: BoxFit.fill, child: Image.file(File(photo.path))))),
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
              ],
            ),
          ),
            if (isSelectMode)
              Padding(
              padding: const EdgeInsets.all(24),
              child: GestureDetector(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(
                        'Upload ${_selectedPhotos.length} photos',
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.save,
                      size: 24,
                      color: Colors.red,
                    )
                  ],
                ),
                onTap: () async {
                  if (_selectedPhotos.isEmpty) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text('Enable selection mode by tapping and holding a photo')));
                    return;
                  }

                  successFullUploadsCount = 0;
                  ScaffoldMessenger.of(context).showSnackBar(uploadingSnackBar());
                  await uploadPhotos();
                  ScaffoldMessenger.of(context).showSnackBar(successfulUploadSnackBar());
                },
              ),
            ),
          if (!isSelectMode)
            TextButton(
                onPressed: () async {
                  _selectedPhotos = widget._photos;
                  await uploadPhotos();
                },
                child: const Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Text('Upload all', style: TextStyle(fontSize: 18),),
                )
            )

        ]));
  }

  Future<void> uploadPhotos() async {
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
