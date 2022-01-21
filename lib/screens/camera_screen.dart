import 'dart:io';

import 'package:camera/camera.dart';
import 'package:ffw_photospaces/screens/photos_preview_screen.dart';
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
  CameraType currentCamera = CameraType.back;

  late CameraController? _cameraController = null;
  List<XFile> currentPhotos = [];

  @override
  void initState() {
    init(currentCamera);
    super.initState();
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
      init(currentCamera);
    }
  }

  void init(CameraType camera) async {
    if (_cameraController != null) {
      await _cameraController!.dispose();
    }

    setState(() {
      isCamerasReady = false;
      isFinishedTakingPictures = false;
      isPhotoTaken = false;
    });

    availableCameras().then((value) {
      currentCamera = camera;
      _cameraController = CameraController(camera == CameraType.front ? value[1] : value[0], ResolutionPreset.max);
      _cameraController!.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {
          isCamerasReady = true;
        });
      });
    });
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
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
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (currentPhotos.isNotEmpty) Align(alignment: Alignment.centerLeft, child: buildLastPhotoIndicator(context)),
          Align(alignment: Alignment.center, child: buildTakePictureButton(context)),
          Align(alignment: Alignment.centerRight, child: buildConfirmPhotosButton(context))
        ],
      ),
    );
  }

  GestureDetector buildLastPhotoIndicator(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PhotosPreviewScreen(currentPhotos))),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: SizedBox(
            width: 70,
            height: 70,
            child: FittedBox(
                alignment: Alignment.center, fit: BoxFit.fill, child: Image.file(File(currentPhotos.last.path)))),
      ),
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
              aspectRatio: 1 / _cameraController!.value.aspectRatio, child: CameraPreview(_cameraController!)),
        ),
      ),
    );
  }

  void zoomHandler(details) async => await _cameraController!.getMaxZoomLevel() <= details.scale
      ? null
      : await _cameraController!.setZoomLevel(
          details.scale.clamp(await _cameraController!.getMinZoomLevel(), await _cameraController!.getMaxZoomLevel()));

  IconButton buildFinishedTakingPhotosIcon(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.add_task, size: 64, color: Colors.white),
      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PhotosPreviewScreen(currentPhotos))),
    );
  }

  GestureDetector buildTakePictureButton(BuildContext context) {
    return GestureDetector(
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 70,
            height: 70,
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white
              ),
            ),
          ),
          SizedBox(
            width: 61,
            height: 61,
            child: Container(
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(
                  color: Colors.red,
                  width: 2.0,
                )
              ),
            ),
          )
        ],
      ),
      onTap: () => handleTakeAPicture(context),
    );

    //const Icon(Icons.camera, size: 46, color: Colors.white)
  }

  void handleTakeAPicture(BuildContext context) {
    _cameraController!.takePicture().then((value) {
      setState(() {
        currentPhotos.add(value);
      });
    });
  }

  IconButton buildSwitchCameraButton(BuildContext context) {
    return IconButton(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      icon: const Icon(Icons.cameraswitch, size: 32, color: Colors.white),
      onPressed: () {
        setState(() {
          isCamerasReady = false;
          currentCamera == CameraType.front ? init(CameraType.back) : init(CameraType.front);
        });
      },
    );
  }

  IconButton buildConfirmPhotosButton(BuildContext context) {
    return IconButton(
      padding: const EdgeInsets.symmetric(horizontal: 34.0),
      icon: const Icon(Icons.check_circle, size: 48, color: Colors.white),
      onPressed: () {
        setState(() {
          currentPhotos.isEmpty
              ? Navigator.of(context).pop()
              : Navigator.push(context, MaterialPageRoute(builder: (_) => PhotosPreviewScreen(currentPhotos)));
        });
      },
    );
  }
}

enum CameraType { front, back }
