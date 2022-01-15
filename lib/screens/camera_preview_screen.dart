import 'dart:io';

import 'package:camera/camera.dart';
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

  late final List<CameraDescription> _cameras;
  late final CameraController _cameraController;
  XFile? currentPhoto;

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
        body: isPhotoTaken
            ? Column(
                children: [
                  ConstrainedBox(
                      constraints: BoxConstraints(
                          minWidth: MediaQuery.of(context).size.width,
                          maxHeight: MediaQuery.of(context).size.height * 0.7),
                      child: Image.file(File(currentPhoto!.path))),
                  IconButton(
                    icon: const Icon(Icons.add_task, size: 46, color: Colors.red),
                    onPressed: () {
                      _cameraController.takePicture().then((value) {
                        setState(() {
                          isPhotoTaken = false;
                          currentPhoto = null;
                        });
                      });
                    },
                  ),
                ],
              )
            : !isCamerasReady
                ? const Center(
                    child: Text('Loading camera...'),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      ConstrainedBox(
                        constraints: BoxConstraints(
                            maxHeight: MediaQuery.of(context).size.height * 0.7,
                            minWidth: MediaQuery.of(context).size.width),
                        child: AspectRatio(
                            aspectRatio: 1 / _cameraController.value.aspectRatio,
                            child: CameraPreview(_cameraController)),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: IconButton(
                          icon: const Icon(Icons.camera, size: 46, color: Colors.red),
                          onPressed: () {
                            _cameraController.takePicture().then((value) {
                              setState(() {
                                isPhotoTaken = true;
                                currentPhoto = value;
                              });
                            });
                          },
                        ),
                      ),
                    ],
                  ));
  }
}
