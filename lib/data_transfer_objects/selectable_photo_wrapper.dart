import 'package:camera/camera.dart';
import 'package:ffw_photospaces/data_transfer_objects/file_data_transfer_object.dart';

class SelectablePhotoWrapper {
  FileDataTransferObject<XFile> photo;
  bool isSelected = true;

  SelectablePhotoWrapper(this.photo);
}