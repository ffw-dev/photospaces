import 'package:camera/camera.dart';

class SelectablePhotoWrapper {
  late XFile photo;
  bool isSelected = true;

  SelectablePhotoWrapper(this.photo);
}