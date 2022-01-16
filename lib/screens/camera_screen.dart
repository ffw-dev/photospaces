import 'dart:io';

import 'package:camera/camera.dart';
import 'package:ffw_photospaces/screens/photo_preview_screen.dart';
import 'package:ffw_photospaces/screens/photos_preview_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  bool isCamerasReady = false;
  bool isPhotoTaken = false;
  bool isFinishedTakingPictures = false;

  late final CameraController _cameraController;
  List<XFile> currentPhotos = [];

  @override
  void initState() {
    availableCameras().then((value) {
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
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _cameraController;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      isCamerasReady = false;
      _cameraController.initialize().then((value) => isCamerasReady = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(), body: !isCamerasReady ? buildLoadingText() : buildCameraPreview(context));
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
        buildCameraView(context),
        Expanded(
          child: buildCameraControlRow(context),
        )
      ],
    );
  }

  Container buildCameraControlRow(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Colors.red),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        textBaseline: TextBaseline.alphabetic,
        children: [buildTakePictureButton(context), if (currentPhotos.isNotEmpty) buildLastPhotoIndicator(context)],
      ),
    );
  }

  GestureDetector buildLastPhotoIndicator(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PhotosPreviewScreen(currentPhotos))),
      child: SizedBox(
          width: 60,
          height: 60,
          child: FittedBox(
              alignment: Alignment.center, fit: BoxFit.fill, child: Image.file(File(currentPhotos.last.path)))),
    );
  }

  GestureDetector buildCameraView(BuildContext context) {
    return GestureDetector(
      onVerticalDragDown: (_) => Navigator.pop(context),
      child: InteractiveViewer(
        onInteractionEnd: zoomHandler,
        child: ConstrainedBox(
          constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7, minWidth: MediaQuery.of(context).size.width),
          child: AspectRatio(
              aspectRatio: 1 / _cameraController.value.aspectRatio, child: CameraPreview(_cameraController)),
        ),
      ),
    );
  }

  void zoomHandler(details) async => await _cameraController.getMaxZoomLevel() <= details.scale
          ? null
          : await _cameraController.setZoomLevel(details.scale
              .clamp(await _cameraController.getMinZoomLevel(), await _cameraController.getMaxZoomLevel()));

  IconButton buildFinishedTakingPhotosIcon(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.add_task, size: 46, color: Colors.white),
      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PhotosPreviewScreen(currentPhotos))),
    );
  }

  IconButton buildTakePictureButton(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.camera, size: 46, color: Colors.white),
      onPressed: () {
        _cameraController.takePicture().then((value) {
          setState(() {
            currentPhotos.add(value);
            Navigator.push(context, MaterialPageRoute(builder: (_) => PhotoPreviewScreen(value)));
          });
        });
      },
    );
  }
}
