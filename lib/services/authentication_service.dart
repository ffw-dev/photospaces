import 'package:dev_eza_api/base_http_service.dart';
import 'package:dev_eza_api/endpoints/authentication_endpoints.dart';
import 'package:dev_eza_api/main.dart';
import 'package:ffw_photospaces/exceptions/logic_exception.dart';
import 'package:ffw_photospaces/main.dart';
import 'package:ffw_photospaces/redux/actions/authentication_actions/reset_state_action.dart';
import 'package:ffw_photospaces/redux/actions/authentication_actions/set_authenticated_state_action.dart';
import 'package:ffw_photospaces/redux/state_parts/login_state.dart';
import 'package:ffw_photospaces/services/secure_cookie_service.dart';

import 'device_storage_service.dart';

class AuthenticationService {
  final AuthenticationEndpoints _authenticationEndpoints = DevEzaApi.authenticationEndpoints;
  final SecureCookieService _secureCookieService = SecureCookieService();

  Future<bool> login(String email, String password) async {
    store.dispatch(SetAuthenticatedStateAction(AuthenticatedState.checking));

    var response = await _authenticationEndpoints.emailPasswordPost(email, password);
    var success = response.error.fullName == null ? true : false;

    if(success) {
      await _secureCookieService.create().then((value) => replaceCookie(value));
      store.dispatch(SetAuthenticatedStateAction(AuthenticatedState.authenticated));
    }

    return success;
  }

  Future<bool> loginByCookie() {
    store.dispatch(SetAuthenticatedStateAction(AuthenticatedState.checking));

    return DeviceStorageService.read<SecureCookie>(SecureCookieService.key, SecureCookie.fromJson).then((cookieFromDevice) {
      if (cookieFromDevice == null) {
        return false;
      }

      return _secureCookieService
          .login(cookieFromDevice.guid, cookieFromDevice.passwordGuid)
          .then((cookieFromLoginResponse) async {
        if (cookieFromLoginResponse == null) {
          await DeviceStorageService.delete(SecureCookieService.key);
          return false;
        }

        replaceCookie(cookieFromLoginResponse);

        store.dispatch(SetAuthenticatedStateAction(AuthenticatedState.authenticated));

        return true;
      });
    });
  }

  Future<bool> logout() async {
    store.dispatch(SetAuthenticatedStateAction(AuthenticatedState.checking));

    await DeviceStorageService.delete(SecureCookieService.key);
    store.dispatch(SetAuthenticatedStateAction(AuthenticatedState.unauthenticated));
    DevEzaApi.removeSession();
    await store.dispatch(ResetStateAction());
    await DevEzaApi.sessionEndpoints.createSessionGet();

    return true;
  }

  void replaceCookie(SecureCookie cookieFromLoginResponse) {
    DeviceStorageService.save(SecureCookieService.key, cookieFromLoginResponse);
  }
}
