import 'package:async_redux/async_redux.dart';
import 'package:ffw_photospaces/screens/login_screen.dart';

import '../../app_state.dart';

class ResetStateAction extends ReduxAction<AppState> {
  @override
  AppState reduce() {
    return AppState.initialState();
  }

}