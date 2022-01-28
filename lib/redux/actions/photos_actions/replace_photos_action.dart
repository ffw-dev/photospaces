import 'package:async_redux/async_redux.dart';
import 'package:ffw_photospaces/data_transfer_objects/selectable_photo_wrapper.dart';

import '../../app_state.dart';

class ReplacePhotosAction extends ReduxAction<AppState> {
  final List<SelectablePhotoWrapper> _photoWrappersList;

  ReplacePhotosAction(this._photoWrappersList);

  @override
  AppState reduce() {
    state.photosState.photos = _photoWrappersList;

    return store.state.copy(loginState: state.loginState, photosState: state.photosState);
  }
}