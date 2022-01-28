import 'dart:io';

import 'package:async_redux/async_redux.dart';
import 'package:ffw_photospaces/data_transfer_objects/selectable_photo_wrapper.dart';
import 'package:ffw_photospaces/main.dart';
import 'package:ffw_photospaces/redux/actions/photos_actions/remove_photo_action.dart';
import 'package:ffw_photospaces/redux/actions/photos_actions/toggle_selection_action.dart';
import 'package:ffw_photospaces/redux/app_state.dart';
import 'package:ffw_photospaces/screens/photo_preview_screen.dart';
import 'package:ffw_photospaces/widgets/photos_preview/photo_animated_container.dart';
import 'package:ffw_photospaces/widgets/photos_preview/selected_icon.dart';
import 'package:ffw_photospaces/widgets/photos_preview/unselected_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';

import '../animated_photo_dialog_box.dart';

class PhotosGridViewConnector extends StatelessWidget {
  final bool isSelectMode;

  const PhotosGridViewConnector({Key? key, required this.isSelectMode}) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      StoreConnector<AppState, PhotosGridViewViewModel>(
        vm: () => PhotosGridViewFactory(isSelectMode),
        builder: (BuildContext context, PhotosGridViewViewModel vm) {
          return PhotosGridView(
              photosDTO: vm.photos,
              onToggleSelection: vm.onToggleSelection,
              onRemovePhoto: vm.onRemovePhoto,

              isSelectMode: isSelectMode,
          );
        },
      );
}

class PhotosGridViewViewModel extends Vm {
  final List<SelectablePhotoWrapper> photos;
  final Function onToggleSelection;
  final Function onRemovePhoto;
  final bool isSelectMode;

  PhotosGridViewViewModel(this.photos, this.onToggleSelection, this.onRemovePhoto, this.isSelectMode) : super(equals: [isSelectMode,...photos, ...photos.map((e) => e.isSelected)]);
}

class PhotosGridViewFactory extends VmFactory<AppState, PhotosGridViewConnector> {
  final bool isSelectMode;

  PhotosGridViewFactory(this.isSelectMode);

  @override
  Vm? fromStore() => PhotosGridViewViewModel(
          store.state.photosState.photos,
          (SelectablePhotoWrapper s) => store.dispatch(ToggleSelectionAction(s)),
          (SelectablePhotoWrapper s) => store.dispatch(RemovePhotoAction(s)),
          isSelectMode
  );
}


class PhotosGridView extends StatefulWidget {
  final List<SelectablePhotoWrapper> photosDTO;
  final Function onToggleSelection;
  final Function onRemovePhoto;

  final bool isSelectMode;

  const PhotosGridView({required this.photosDTO, Key? key, required this.onToggleSelection, required this.onRemovePhoto, required this.isSelectMode}) : super(key: key);

  @override
  State<PhotosGridView> createState() => _PhotosGridViewState();
}

class _PhotosGridViewState extends State<PhotosGridView> {

  bool isReady = false;

  double animatedContainerHeight = 129;
  double animatedContainerWidth = 129;

  @override
  void initState() {
    isReady = true;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return !isReady ? Container() : GridView.builder(
      itemCount: widget.photosDTO.length,
      scrollDirection: Axis.vertical,
      gridDelegate: customSliverDelegateSettings(context),
      itemBuilder: (BuildContext context, int index) {
        var photoWrapper = widget.photosDTO[index];

        return Padding(
          padding: const EdgeInsets.all(0.8),
          child: GridTile(
            child: GestureDetector(
              onTap: () => widget.onToggleSelection(photoWrapper),
              onLongPress: () async {
                await animateGridTileWidth();
                await Future.delayed(const Duration(milliseconds: 150), () {
                  showDialog(
                      context: context,
                      builder: (_) => AnimatedPhotoDialogBox(photoDTO: photoWrapper, callback: () => widget.onRemovePhoto(photoWrapper)));
                });
              },
              child: buildGridTilePhotoStack(photoWrapper),
            ),
          ),
        );
      },
    );
  }

  Stack buildGridTilePhotoStack(SelectablePhotoWrapper photoWrapper) {
    return Stack(children: [
              PhotoAnimatedContainer(photoWrapper: photoWrapper, gridTileHeight: animatedContainerHeight, gridTileWidth: animatedContainerWidth),
              if (widget.isSelectMode)
                photoWrapper.isSelected
                    ? const SelectedIcon()
                    : const UnselectedIcon()
            ]);
  }

  SliverGridDelegateWithFixedCrossAxisCount customSliverDelegateSettings(BuildContext context) {
    return SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: (MediaQuery
            .of(context)
            .size
            .width / animatedContainerWidth).round(),
        crossAxisSpacing: 0,
        mainAxisSpacing: 0);
  }

  Future<void> animateGridTileWidth() async {
    setState(() => animatedContainerWidth -= 10);
    Vibrate.feedback(FeedbackType.heavy);
    await Future.delayed(const Duration(milliseconds: 150), null);
    setState(() => animatedContainerWidth += 10);
  }
}
