import 'dart:io';

import 'package:camera/camera.dart';
import 'package:ffw_photospaces/screens/photo_preview_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CameraPreviewScreen extends StatefulWidget {
  const CameraPreviewScreen({Key? key}) : super(key: key);

  @override
  _CameraPreviewScreenState createState() => _CameraPreviewScreenState();
}

class _CameraPreviewScreenState extends State<CameraPreviewScreen> {
  bool isCamerasReady = false;
  bool isPhotoTaken = false;
  bool isFinishedTakingPictures = false;

  late final List<CameraDescription> _cameras;
  late final CameraController _cameraController;
  List<XFile> currentPhotos = [];

  @override
  void initState() {
    availableCameras().then((value) {
      _cameras = value;
      _cameraController = CameraController(value[0], ResolutionPreset.max);
      _cameraController.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {
          isCamerasReady = true;
        });
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: isFinishedTakingPictures
            ? buildPhotosPreview(context)
            : !isCamerasReady
                ? buildLoadingText()
                : buildCameraPreview(context));
  }

  Center buildLoadingText() {
    return const Center(
      child: Text('Loading camera...'),
    );
  }

  Column buildCameraPreview(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        ConstrainedBox(
          constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7, minWidth: MediaQuery.of(context).size.width),
          child: AspectRatio(
              aspectRatio: 1 / _cameraController.value.aspectRatio, child: CameraPreview(_cameraController)),
        ),
        Align(
          alignment: Alignment.center,
          child: IconButton(
            icon: const Icon(Icons.camera, size: 46, color: Colors.red),
            onPressed: () {
              _cameraController.takePicture().then((value) {
                setState(() {
                  currentPhotos.add(value);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => PhotoPreviewScreen(value)));
                });
              });
            },
          ),
        ),
        if (currentPhotos.isNotEmpty)
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: const Icon(Icons.add_task, size: 46, color: Colors.red),
              onPressed: () {
                setState(() {
                  isFinishedTakingPictures = true;
                });
              },
            ),
          ),
      ],
    );
  }

  GridView buildPhotosPreview(BuildContext context) {
    return GridView.count(
      primary: false,
      padding: const EdgeInsets.all(20),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      crossAxisCount: 2,
      children: <Widget>[
        ...currentPhotos
            .map(
              (e) => GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PhotoPreviewScreen(e))),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: Image.file(File(e.path)),
                  color: Colors.teal[600],
                ),
              ),
            )
            .toList()
      ],
    );
  }
}

/*
*         IconButton(
          icon: const Icon(Icons.add_task, size: 46, color: Colors.red),
          onPressed: () {
            _cameraController.takePicture().then((value) {
              setState(() {
                isPhotoTaken = false;
                currentPhotos = [];
              });
            });
          },
        ),*/
