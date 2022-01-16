import 'package:async_redux/async_redux.dart';
import 'package:dev_eza_api/main.dart';
import 'package:ffw_photospaces/redux/app_state.dart';
import 'package:ffw_photospaces/screens/camera_screen.dart';
import 'package:ffw_photospaces/screens/login_screen.dart';
import 'package:ffw_photospaces/screens/mock_home_screen.dart';
import 'package:ffw_photospaces/services/authentication_service.dart';
import 'package:ffw_photospaces/services/session_service.dart';
import 'package:flutter/material.dart';

void main() async {
  configureDependencies();
  runApp(const MainActivity());
}

var state = AppState;

var store = Store<AppState>(
  initialState: AppState.initialState(),
);

class MainActivity extends StatefulWidget {
  const MainActivity({Key? key}) : super(key: key);

  @override
  State<MainActivity> createState() => _MainActivityState();
}

class _MainActivityState extends State<MainActivity> {
  late Future tryLoginByCookie;

  @override
  void initState() {
    super.initState();

    tryLoginByCookie =
        SessionService().create().then(
              (value) async => await AuthenticationService().loginByCookie()
        );
  }

  @override
  Widget build(BuildContext context) {
    return StoreProvider<AppState>(
        store: store,
        child: MaterialApp(
          theme: ThemeData(primarySwatch: Colors.red, backgroundColor: Colors.red),
          routes: {
            '/': (_) => tryCookieLoginAndBuildInitialRoute(),
            '/mockHomeScreen': (_) => const MockHomeScreen(),
            '/cameraPreviewScreen': (_) => const CameraScreen(),
          },
        ));
  }

  FutureBuilder<dynamic> tryCookieLoginAndBuildInitialRoute() {
    return FutureBuilder(
        future: tryLoginByCookie,
        builder: (ctx, result) {
          return !result.hasData
              ? const CircularProgressIndicator()
              : result.data != true
                  ? const LoginScreen()
                  : const MockHomeScreen();
        });
  }
}
