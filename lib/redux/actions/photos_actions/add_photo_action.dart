
import 'package:async_redux/async_redux.dart';
import 'package:camera/camera.dart';
import 'package:ffw_photospaces/data_transfer_objects/file_data_transfer_object.dart';
import 'package:ffw_photospaces/data_transfer_objects/selectable_photo_wrapper.dart';

import '../../app_state.dart';

class AddPhotoAction extends ReduxAction<AppState> {
  final XFile _photoWrapper;

  AddPhotoAction(this._photoWrapper);

  @override
  AppState reduce() {
    state.photosState.photos.add(SelectablePhotoWrapper(FileDataTransferObject(_photoWrapper)));

    return store.state.copy(loginState: state.loginState, photosState: state.photosState);
  }
}