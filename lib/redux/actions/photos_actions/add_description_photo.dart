
import 'package:async_redux/async_redux.dart';

import '../../app_state.dart';

class AddDescriptionAction extends ReduxAction<AppState> {
  final String description;

  AddDescriptionAction(this.description);

  @override
  AppState reduce() {
    state.photosState.description = description;

    return store.state.copy(loginState: state.loginState, photosState: state.photosState);
  }
}