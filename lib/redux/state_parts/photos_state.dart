import 'package:ffw_photospaces/data_transfer_objects/selectable_photo_wrapper.dart';

class PhotosState {
  List<SelectablePhotoWrapper> photos = [];
  String description = '';

  PhotosState._();

  static PhotosState initialState() => PhotosState._();
}