class LoginState {
  var authenticated = AuthenticatedState.checking;
  get isAuthenticated => authenticated;

  LoginState._();

  static LoginState initialState() {
    var initialState = LoginState._();
    initialState.authenticated = AuthenticatedState.unauthenticated;

    return initialState;
  }
}

enum AuthenticatedState {
  authenticated,
  unauthenticated,
  checking,
}