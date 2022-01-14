class LoginState {
  var authenticated = AuthenticatedState.checking;
  get isAuthenticated => authenticated;

  static LoginState initialState() {
    var initialState = LoginState();
    initialState.authenticated = AuthenticatedState.unauthenticated;

    return initialState;
  }
}

enum AuthenticatedState {
  authenticated,
  unauthenticated,
  checking,
}