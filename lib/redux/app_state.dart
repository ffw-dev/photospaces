
import 'package:ffw_photospaces/redux/state_parts/login_state.dart';
import 'package:ffw_photospaces/redux/state_parts/photos_state.dart';
import 'package:flutter/cupertino.dart';

@immutable
class AppState {

  final LoginState loginState;
  final PhotosState photosState;

  const AppState._({
    required this.loginState,
    required this.photosState
  });

  AppState copy({
    required LoginState loginState, photosState,
  }) {
    return AppState._(
      loginState: loginState,
      photosState: photosState
    );
  }

  static AppState initialState() =>
      AppState._(
          loginState: LoginState.initialState(),
          photosState: PhotosState.initialState()
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is AppState && runtimeType == other.runtimeType &&
          loginState == other.loginState && photosState == other.photosState;

  @override
  int get hashCode => loginState.hashCode + photosState.hashCode;
}