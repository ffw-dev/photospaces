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
          if (isSelectMode) buildCancelSelectionModeButton(),
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
                          _selectedPhotos = [];
                          if (_selectedPhotos.contains(photo)) {
                            return;
                          }
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
          if (isSelectMode && _selectedPhotos.isNotEmpty) buildUploadNumberOfPhotosButton(context),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!isSelectMode) buildUploadAllButton(context),
                if (_selectedPhotos.length != widget._photos.length && isSelectMode) buildSelectAllButton(),
                if (isSelectMode && _selectedPhotos.isNotEmpty) buildUnselectAllButton()
              ],
            ),
          )
        ]));
  }

  TextButton buildUnselectAllButton() {
    return TextButton(
        onPressed: () async {
          setState(() {
            _selectedPhotos = [];
          });
        },
        child: const Padding(
          padding: EdgeInsets.all(12.0),
          child: Text(
            'Unselect all',
            style: TextStyle(fontSize: 14),
          ),
        ));
  }

  TextButton buildSelectAllButton() {
    return TextButton(
        onPressed: () async {
          setState(() {
            _selectedPhotos = List.from(widget._photos);
            isSelectMode = true;
          });
        },
        child: const Padding(
          padding: EdgeInsets.all(12.0),
          child: Text(
            'Select all',
            style: TextStyle(fontSize: 14),
          ),
        ));
  }

  TextButton buildUploadAllButton(BuildContext context) {
    return TextButton(
        onPressed: () async {
          _selectedPhotos = widget._photos;
          await handleUploadAndShowSnackBars(context);
        },
        child: const Padding(
          padding: EdgeInsets.all(12.0),
          child: Text(
            'Upload all',
            style: TextStyle(fontSize: 16),
          ),
        ));
  }

  Padding buildUploadNumberOfPhotosButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: GestureDetector(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Upload ${_selectedPhotos.length} photos',
              style: const TextStyle(
                fontSize: 18,
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
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No photos selected')));
            return;
          }

          successFullUploadsCount = 0;
          await handleUploadAndShowSnackBars(context);
        },
      ),
    );
  }

  Future<void> handleUploadAndShowSnackBars(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(showSnackBarWithText('Uploading, please wait'));
    await uploadPhotos();
    ScaffoldMessenger.of(context).showSnackBar(showSnackBarWithText('Successfully uploaded $successFullUploadsCount of ${_selectedPhotos.length} pictures.'));
  }

  TextButton buildCancelSelectionModeButton() {
    return TextButton(
        onPressed: () async {
          setState(() {
            _selectedPhotos = [];
            _selectedPhotos = widget._photos;
            isSelectMode = false;
          });
        },
        child: const Padding(
          padding: EdgeInsets.all(12.0),
          child: Text(
            'cancel selection mode',
            style: TextStyle(fontSize: 14, color: Colors.red),
          ),
        ));
  }

  Future<void> uploadPhotos() async {
    successFullUploadsCount = 0;
    for (var file in _selectedPhotos) {
      await DevEzaApi.ezFileEndpoints
          .uploadPost(FormData.fromMap({
        "assetId": "c37744ff-938d-4614-a29e-a386d1db3d63",
        "Type": "3",
        "File": await MultipartFile.fromFile(file.path)
      }))
          .then((value) {
        setState(() {
          successFullUploadsCount++;
        });
      });
    }
  }

  void togglePhotoSelect(XFile photo) => isSelectMode
      ? setState(() {
          !_selectedPhotos.contains(photo) ? _selectedPhotos.add(photo) : _selectedPhotos.remove(photo);
        })
      : null;

  SnackBar showSnackBarWithText(String text) {
    return SnackBar(
      content: Text(text),
    );
  }

  SnackBar uploadingSnackBar() {
    return const SnackBar(
      content: Text('Uploading, please wait.'),
    );
  }
}
