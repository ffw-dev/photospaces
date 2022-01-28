import 'package:async_redux/async_redux.dart';
import 'package:ffw_photospaces/data_transfer_objects/selectable_photo_wrapper.dart';

import '../../app_state.dart';

class RemovePhotoAction extends ReduxAction<AppState> {
  final SelectablePhotoWrapper _photoWrapper;

  RemovePhotoAction(this._photoWrapper);

  @override
  AppState reduce() {
    state.photosState.photos.remove(_photoWrapper);

    return store.state.copy(loginState: state.loginState, photosState: state.photosState);
  }
}
