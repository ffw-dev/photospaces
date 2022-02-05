import 'package:async_redux/async_redux.dart';
import 'package:ffw_photospaces/data_transfer_objects/selectable_photo_wrapper.dart';
import 'package:ffw_photospaces/exceptions/logic_exception.dart';
import 'package:ffw_photospaces/extensions/future_extension.dart';
import 'package:ffw_photospaces/mixins/ez_asset_mixin.dart';
import 'package:ffw_photospaces/mixins/snackbars_mixin.dart';
import 'package:ffw_photospaces/redux/actions/photos_actions/replace_photos_action.dart';
import 'package:ffw_photospaces/redux/app_state.dart';
import 'package:ffw_photospaces/screens/login_screen.dart';
import 'package:ffw_photospaces/services/authentication_service.dart';
import 'package:ffw_photospaces/services/current_locales_service.dart';
import 'package:ffw_photospaces/services/image_compression_service.dart';
import 'package:ffw_photospaces/widgets/base_outlined_button.dart';
import 'package:flutter/material.dart';

import '../../main.dart';

class PreviewAppBarConnector extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback callBack;
  final String assetDescription;

  const PreviewAppBarConnector(this.callBack, this.assetDescription, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => StoreConnector<AppState, PreviewAppBarViewModel>(
        vm: () => PreviewAppBarFactory(callBack, assetDescription),
        builder: (BuildContext context, PreviewAppBarViewModel vm) {
          return PreviewAppBar(
            photos: vm.photos,
            assetDescription: vm.description,
            callBack: callBack,
            onRemoveAll: vm.onRemoveAll,
          );
        },
      );

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class PreviewAppBarViewModel extends Vm {
  final List<SelectablePhotoWrapper> photos;
  final String description;
  final VoidCallback callBack;
  final VoidCallback onRemoveAll;

  PreviewAppBarViewModel(this.photos, this.description, this.callBack, this.onRemoveAll)
      : super(equals: [description, ...photos]);
}

class PreviewAppBarFactory extends VmFactory<AppState, PreviewAppBarConnector> {
  VoidCallback callBack;
  final String assetDescription;

  PreviewAppBarFactory(this.callBack, this.assetDescription);

  @override
  Vm? fromStore() => PreviewAppBarViewModel(store.state.photosState.photos, store.state.photosState.description,
      callBack, () => store.dispatch(ReplacePhotosAction([])));
}

class PreviewAppBar extends StatelessWidget with SnackBarsMixin, EzAssetMixin implements PreferredSizeWidget {
  final List<SelectablePhotoWrapper> photos;
  final String assetDescription;
  final VoidCallback callBack;
  final VoidCallback onRemoveAll;

  const PreviewAppBar(
      {Key? key,
      required this.photos,
      required this.assetDescription,
      required this.callBack,
      required this.onRemoveAll})
      : super(key: key);

  bool get isSelectionEmpty => photos.where((element) => element.isSelected).isEmpty;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) => AppBar(
        actions: [
          IconButton(onPressed: () => popAllAndNavigateToMockScreen(context), icon: const Icon(Icons.cancel)),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.07,
          ),
          BaseOutlinedButton(
            CurrentLocalesService.screenPhotosPreview.componentPreviewAppBar.textSelect,
            null,
            callBack,
            initialSelected: true,
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.07,
          ),
          IconButton(
              onPressed: () async => handleUploadAndShowSnackBars(context), icon: const Icon(Icons.check_circle)),
          IconButton(
            icon: const Icon(
              Icons.logout,
              color: Colors.white,
              size: 24,
            ),
            onPressed: () async {
              if(!isSelectionEmpty) {
                throw LogicException('App still contains unused photos');
              }
              await AuthenticationService().logout();
              popAllAndNavigateToLoginScreen(context);
            },
          )
        ],
      );

  void popAllAndNavigateToMockScreen(BuildContext context) {
    onRemoveAll();
    Navigator.pushNamedAndRemoveUntil(context, '/mockHomeScreen', (route) => false);
  }

  void popAllAndNavigateToLoginScreen(BuildContext context) {
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false);
  }

  Future<void> handleUploadAndShowSnackBars(BuildContext context) async {
    if (isSelectionEmpty) {
      throw LogicException('Empty selection');
    }

    if (assetDescription.isEmpty) {
      throw LogicException('Add description');
    } else {
      showSnackBarPersistWithWidget(
          context,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(CurrentLocalesService.screenPhotosPreview.componentPreviewAppBar.textUploading),
              const CircularProgressIndicator()
            ],
          ));

      var compressedImages = await ImageCompressionService().compressImages(photos.map((e) => e.photo).toList());

      createAssetAndUploadPhotos(compressedImages, assetDescription).onSuccess((_) {
        ScaffoldMessenger.of(context).clearSnackBars();
        showSnackBarWithTextWithDuration(
            context, CurrentLocalesService.screenPhotosPreview.componentPreviewAppBar.textSuccessfulUpload,
            milliseconds: 2000);
        popAllAndNavigateToMockScreen(context);
      });
    }
  }
}
