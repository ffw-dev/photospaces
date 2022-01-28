import 'package:ffw_photospaces/data_transfer_objects/selectable_photo_wrapper.dart';
import 'package:ffw_photospaces/screens/photos_preview_screen.dart';
import 'package:flutter/material.dart';

class FinishTakingPhotosButton extends StatelessWidget {
  final List<SelectablePhotoWrapper> photos;

  const FinishTakingPhotosButton(this.photos, {Key? key}) : super(key: key);

  bool get hasPhotos => photos.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      padding: const EdgeInsets.symmetric(horizontal: 34.0),
      icon: const Icon(Icons.check_circle, size: 48, color: Colors.white),
      onPressed: () {
        !hasPhotos
            ? Navigator.of(context).pop()
            : Navigator.pushAndRemoveUntil(
                context, MaterialPageRoute(builder: (_) => const PhotosPreviewScreenConnector()), (_) => false);
      },
    );
  }
}
