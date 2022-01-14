import 'package:dev_eza_api/main.dart';

class SessionService {
  Future<void> create() async {
    await DevEzaApi.sessionEndpoints.createSessionGet();
  }
}