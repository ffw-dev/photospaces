import 'package:async_redux/async_redux.dart';
import 'package:camera/camera.dart';
import 'package:ffw_photospaces/components/camera_preview/finish_taking_photos_button.dart';
import 'package:ffw_photospaces/components/camera_preview/last_photo_indicator.dart';
import 'package:ffw_photospaces/components/camera_preview/take_picture_button.dart';
import 'package:ffw_photospaces/data_transfer_objects/selectable_photo_wrapper.dart';
import 'package:ffw_photospaces/main.dart';
import 'package:ffw_photospaces/mixins/snackbars_mixin.dart';
import 'package:ffw_photospaces/redux/actions/photos_actions/add_photo_action.dart';
import 'package:ffw_photospaces/redux/actions/photos_actions/replace_photos_action.dart';
import 'package:ffw_photospaces/redux/app_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CameraScreenConnector extends StatelessWidget {
  const CameraScreenConnector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => StoreConnector<AppState, CameraScreenViewModel>(
        vm: () => CameraScreenFactory(),
        builder: (BuildContext context, CameraScreenViewModel vm) {
          return CameraScreen(
            photos: vm.photos,
            onAddPhoto: vm.onAddPhoto,
            onRemoveAll: vm.onRemoveAll,
          );
        },
      );
}

class CameraScreenViewModel extends Vm {
  final List<SelectablePhotoWrapper> photos;
  final Function onAddPhoto;
  final Function onRemoveAll;

  CameraScreenViewModel(this.photos, this.onRemoveAll, this.onAddPhoto) : super(equals: [...photos]);
}

class CameraScreenFactory extends VmFactory<AppState, CameraScreenConnector> {
  @override
  Vm? fromStore() => CameraScreenViewModel(store.state.photosState.photos,
      () => store.dispatch(ReplacePhotosAction([])), (XFile s) => store.dispatch(AddPhotoAction(s)));
}

class CameraScreen extends StatefulWidget {
  final List<SelectablePhotoWrapper> photos;
  final Function onAddPhoto;
  final Function onRemoveAll;

  const CameraScreen({Key? key, required this.photos, required this.onAddPhoto, required this.onRemoveAll})
      : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with WidgetsBindingObserver, SnackBarsMixin {
  bool _isCamerasReady = false;

  CameraController? _cameraController = null;

  @override
  void initState() {
    WidgetsBinding.instance!.addObserver(this);
    WidgetsFlutterBinding.ensureInitialized();

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
        .then((value) => initializeCamera(CameraType.back));

    super.initState();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    SystemChrome.setPreferredOrientations([...DeviceOrientation.values]);
    WidgetsBinding.instance!.removeObserver(this);

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _cameraController!.dispose();
    } else if (state == AppLifecycleState.resumed) {
      initializeCamera(CameraType.back);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(), body: !_isCamerasReady ? buildProgressIndicator() : buildCameraPreview(context));
  }

  Future<void> initializeCamera(CameraType camera) async {
    setState(() => _isCamerasReady = false);

    var cameras = await availableCameras().then((value) => value);

    _cameraController = CameraController(cameras[0], ResolutionPreset.max, imageFormatGroup: ImageFormatGroup.bgra8888);

    _cameraController!.initialize().then((_) async {
      if (!mounted) {
        return;
      }

      await _cameraController!.lockCaptureOrientation();

      setState(() => _isCamerasReady = true);
    });
  }

  Center buildProgressIndicator() {
    return const Center(
      child: CircularProgressIndicator(),
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

  Container buildCameraControlRow(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Theme.of(context).primaryColor),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (widget.photos.isNotEmpty)
            Align(
                alignment: Alignment.centerLeft,
                child: LastPhotoIndicator(
                  photos: widget.photos,
                )),
          Align(alignment: Alignment.center, child: TakePictureButton(callback: () => handleTakeAPicture(context))),
          Align(
              alignment: Alignment.centerRight,
              child: FinishTakingPhotosButton(widget.photos))
        ],
      ),
    );
  }

  void zoomHandler(details) async => await _cameraController!.getMaxZoomLevel() <= details.scale
      ? null
      : await _cameraController!.setZoomLevel(
          details.scale.clamp(await _cameraController!.getMinZoomLevel(), await _cameraController!.getMaxZoomLevel()));

  void handleTakeAPicture(BuildContext context) async {
    if (_cameraController == null || _cameraController!.value.isTakingPicture) {
      return;
    }

    try {
      var photo = await _cameraController!.takePicture().then((value) => value);
      setState(() => widget.onAddPhoto(photo));
    } catch (e) {
      showSnackBarWithText(e.toString());
    }
  }
}

enum CameraType { front, back }
