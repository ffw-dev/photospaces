import 'package:async_redux/async_redux.dart';
import 'package:ffw_photospaces/components/photos_preview/grid_photo.dart';
import 'package:ffw_photospaces/components/photos_preview/preview_app_bar.dart';
import 'package:ffw_photospaces/data_transfer_objects/selectable_photo_wrapper.dart';
import 'package:ffw_photospaces/main.dart';
import 'package:ffw_photospaces/redux/actions/photos_actions/add_description_photo.dart';
import 'package:ffw_photospaces/redux/app_state.dart';
import 'package:ffw_photospaces/services/current_locales_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PhotosPreviewScreenConnector extends StatelessWidget {
  const PhotosPreviewScreenConnector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => StoreConnector<AppState, PhotosPreviewScreenViewModel>(
        vm: () => PhotosPreviewScreenFactory(),
        builder: (BuildContext context, PhotosPreviewScreenViewModel vm) {
          return PhotosPreviewScreen(vm.onAddDescription);
        },
      );
}

class PhotosPreviewScreenFactory extends VmFactory<AppState, PhotosPreviewScreenConnector> {
  @override
  Vm? fromStore() => PhotosPreviewScreenViewModel(
      store.state.photosState.photos, (String s) => store.dispatch(AddDescriptionAction(s)));
}

class PhotosPreviewScreenViewModel extends Vm {
  final List<SelectablePhotoWrapper> photos;
  final Function onAddDescription;

  PhotosPreviewScreenViewModel(this.photos, this.onAddDescription);
}

class PhotosPreviewScreen extends StatefulWidget {
  final Function onAddDescription;

  const PhotosPreviewScreen(this.onAddDescription, {Key? key}) : super(key: key);

  @override
  State<PhotosPreviewScreen> createState() => _PhotosPreviewScreenState();
}

class _PhotosPreviewScreenState extends State<PhotosPreviewScreen> {
  bool isSelectMode = true;
  final TextEditingController _textEditingController = TextEditingController();

  String get textControllerText => _textEditingController.text;

  @override
  void initState() {
    _textEditingController.addListener(() {
      widget.onAddDescription(_textEditingController.text);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: PreviewAppBarConnector(toggleSelectionMode, textControllerText),
      body: Column(children: [
        Expanded(child: PhotosGridViewConnector(isSelectMode: isSelectMode)),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Expanded(child: buildTextInput())],
          ),
        )
      ]));

  Widget buildTextInput() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24),
        child: TextField(
          decoration: InputDecoration(
            suffixIcon: const Icon(Icons.edit),
            hintText: CurrentLocalesService.screenPhotosPreview.textInputHint,
            isDense: true,
          ),
          controller: _textEditingController,
          textAlign: TextAlign.left,
          maxLength: 60,
          maxLengthEnforcement: MaxLengthEnforcement.none,
        ),
      );

  void toggleSelectionMode() => setState(() => isSelectMode = !isSelectMode);

  void startSelectionModeAndAddPhotoToSelectedPhotos(SelectablePhotoWrapper photoDTO) =>
      setState(() => isSelectMode = true);
}
