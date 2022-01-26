import 'dart:io';

import 'package:camera/camera.dart';
import 'package:ffw_photospaces/data_transfer_objects/file_data_transfer_object.dart';
import 'package:ffw_photospaces/main.dart';
import 'package:ffw_photospaces/screens/photos_preview_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with WidgetsBindingObserver {
  bool isCamerasReady = false;
  bool isPhotoTaken = false;
  bool isFinishedTakingPictures = false;
  CameraType currentCamera = CameraType.back;

  late CameraController? _cameraController = null;
  List<XFile> currentPhotos = [];

  @override
  void initState() {
    WidgetsBinding.instance!.addObserver(this);

    Future.delayed(
        const Duration(milliseconds: 300),
        () => init(CameraType
            .back)); //TODO: Temporary fix for a camera crashing the application after pushing this screen via calling Navigator.pushAndRemoveUntil

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();

    _cameraController?.dispose();
    WidgetsBinding.instance!.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _cameraController!.dispose();
    } else if (state == AppLifecycleState.resumed) {
      init(CameraType.back);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: [buildSwitchCameraButton(context)],
        ),
        body: !isCamerasReady ? buildLoadingText() : buildCameraPreview(context));
  }

  Future<void> init(CameraType camera) async {
    setState(() {
      isCamerasReady = false;
      isFinishedTakingPictures = false;
      isPhotoTaken = false;
    });

    await availableCameras().then((value) {
      currentCamera = CameraType.back;
      _cameraController = CameraController(value[0], ResolutionPreset.max);
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

  Center buildLoadingText() {
    return Center(
      child: Text(currentLocalesService.camera_screen['loading_camera']),
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
      decoration: BoxDecoration(color: Theme.of(context).primaryColor),
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
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PhotosPreviewScreen(currentPhotos.map((e) => FileDataTransferObject(e)).toList())))
          .then((value) => init(currentCamera)),
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
      child: InteractiveViewer(
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
      onPressed: () => Navigator.pushAndRemoveUntil(
          context, MaterialPageRoute(builder: (_) => PhotosPreviewScreen(currentPhotos.map((e) => FileDataTransferObject(e)).toList())), (_) => false),
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
              decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
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
                    color: Theme.of(context).primaryColor,
                    width: 2.0,
                  )),
            ),
          )
        ],
      ),
      onTap: () => handleTakeAPicture(context),
    );

    //const Icon(Icons.camera, size: 46, color: Colors.white)
  }

  void handleTakeAPicture(BuildContext context) {
    if (_cameraController == null) {
      return;
    }

    if (_cameraController!.value.isTakingPicture) {
      return;
    }

    try {
      _cameraController!.takePicture().then((value) {
        setState(() {
          currentPhotos.add(value);
        });
      });
    } catch (e) {
      print(e);
    }
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
              : Navigator.pushAndRemoveUntil(
                  context, MaterialPageRoute(builder: (_) => PhotosPreviewScreen(currentPhotos.map((e) => FileDataTransferObject(e)).toList())), (_) => false);
        });
      },
    );
  }
}

enum CameraType { front, back }
