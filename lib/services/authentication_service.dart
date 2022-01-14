import 'package:dev_eza_api/endpoints/authentication_endpoints.dart';
import 'package:dev_eza_api/main.dart';
import 'package:dio/dio.dart';
import 'package:ffw_photospaces/main.dart';
import 'package:ffw_photospaces/redux/actions/authentication_actions.dart';
import 'package:ffw_photospaces/redux/state_parts/login_state.dart';
import 'package:ffw_photospaces/services/secure_cookie_service.dart';

import 'device_storage_service.dart';

class AuthenticationService {
  final AuthenticationEndpoints _authenticationEndpoints = DevEzaApi.authenticationEndpoints;
  final SecureCookieService _secureCookieService = SecureCookieService();

  Future<bool> login(String email, String password) async {
    var response = await _authenticationEndpoints.emailPasswordPost(email, password);
    var success = response.error.fullName == null ? true : false;

    if(success) {
      await _secureCookieService.create().then((value) => replaceCookie(value));
      store.dispatch(SetAuthenticatedStateAction(AuthenticatedState.authenticated));
    }

    return success;
  }

  Future<bool> loginByCookie() {
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

  void replaceCookie(SecureCookie cookieFromLoginResponse) {
    DeviceStorageService.save(SecureCookieService.key, cookieFromLoginResponse);
  }
}
