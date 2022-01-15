
import 'package:ffw_photospaces/redux/state_parts/login_state.dart';
import 'package:flutter/cupertino.dart';

@immutable
class AppState {

  final LoginState loginState;

  const AppState({
    required this.loginState,
  });

  AppState copy({
    required LoginState loginState,
  }) {
    return AppState(
      loginState: loginState,
    );
  }

  static AppState initialState() =>
      AppState(
          loginState: LoginState.initialState());

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is AppState && runtimeType == other.runtimeType &&
          loginState == other.loginState;

  @override
  int get hashCode => loginState.hashCode;
}