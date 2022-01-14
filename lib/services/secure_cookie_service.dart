import 'package:dev_eza_api/endpoints/authentication_endpoints.dart';
import 'package:dev_eza_api/main.dart';
import 'package:dio/dio.dart';
import 'package:ffw_photospaces/services/device_storage_service.dart';

class SecureCookieService {
  final AuthenticationEndpoints _authenticationEndpoints = DevEzaApi.authenticationEndpoints;

  static String get key => 'secureCookie';

  Future<SecureCookie> create() async =>
      _authenticationEndpoints.secureCookieCreate().then((response) => response.body.results[0]);

  Future<SecureCookie?> login(String guid, String password) async {
    try {
      var response = await _authenticationEndpoints
          .secureCookieLogin(guid, password);

      if(response == null) {
        return null;
      }

      return response.body.results[0];
    } catch (_) {
      print(_);
      return null;
    }
  }
}
