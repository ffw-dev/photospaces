import 'package:async_redux/async_redux.dart';
import 'package:ffw_photospaces/data_transfer_objects/selectable_photo_wrapper.dart';

import '../../app_state.dart';

class ToggleSelectionAction extends ReduxAction<AppState> {
  final SelectablePhotoWrapper _photoWrapper;

  ToggleSelectionAction(this._photoWrapper);

  @override
  AppState reduce() {
    var photo = store.state.photosState.photos.firstWhere((element) => element == _photoWrapper);

    photo.isSelected = !photo.isSelected;

    return store.state.copy(loginState: state.loginState, photosState: state.photosState);
  }
}
