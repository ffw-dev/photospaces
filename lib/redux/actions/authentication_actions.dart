
import 'package:async_redux/async_redux.dart';
import 'package:ffw_photospaces/redux/app_state.dart';
import 'package:ffw_photospaces/redux/state_parts/login_state.dart';

class SetAuthenticatedStateAction extends ReduxAction<AppState> {
  AuthenticatedState authenticatedState;

  SetAuthenticatedStateAction(this.authenticatedState);

  @override
  AppState reduce() {
    store.state.loginState.authenticated = authenticatedState;

    return state.copy(loginState: state.loginState);
  }

}