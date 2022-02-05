import 'dart:async';
import 'dart:io';

import 'package:async_redux/async_redux.dart';
import 'package:dev_eza_api/base_http_service.dart';
import 'package:dev_eza_api/main.dart';
import 'package:ffw_photospaces/error_snackbars.dart';
import 'package:ffw_photospaces/exceptions/logic_exception.dart';
import 'package:ffw_photospaces/redux/app_state.dart';
import 'package:ffw_photospaces/screens/camera_screen.dart';
import 'package:ffw_photospaces/screens/login_screen.dart';
import 'package:ffw_photospaces/screens/mock_home_screen.dart';
import 'package:ffw_photospaces/services/authentication_service.dart';
import 'package:ffw_photospaces/services/session_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

GlobalKey<NavigatorState> _navKey = GlobalKey<NavigatorState>();

void main() async {
  runZonedGuarded(() async {
    configureDependencies();
    WidgetsFlutterBinding.ensureInitialized();

    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      if(kReleaseMode) {
        exit(1);
      }
    };

    runApp(const MainActivity());
  }, (error, stack) {
    print(stack.toString());
    if (error.runtimeType == DevEzaException) {
      var e = (error as DevEzaException);
      ScaffoldMessenger.of(_navKey.currentContext!).clearSnackBars();
      ScaffoldMessenger.of(_navKey.currentContext!)
          .showSnackBar(apiExceptionSnackBar(e));
    } else if(error.runtimeType == LogicException) {
      ScaffoldMessenger.of(_navKey.currentContext!).clearSnackBars();
      ScaffoldMessenger.of(_navKey.currentContext!).showSnackBar(exceptionSnackBar((error as LogicException).message));
    } else {
      ScaffoldMessenger.of(_navKey.currentContext!).clearSnackBars();
      ScaffoldMessenger.of(_navKey.currentContext!).showSnackBar(exceptionSnackBar(error.toString()));
    }
  });
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
  static const MaterialColor custom_red = MaterialColor(0xFFb71c1c, <int, Color>{
    50: Color(0xFFF6F5F5),
    100: Color(0xFFD3E0EA),
    200: Color(0xFFD3E0EA),
    300: Color(0xFFD3E0EA),
    400: Color(0xFF1687A7),
    500: Color(0xFF276678),
    600: Color(0xFFD3E0EA),
    700: Color(0xFF1687A7),
  });

  @override
  void initState() {
    super.initState();
    tryLoginByCookie = SessionService().create().then((value) async => await AuthenticationService().loginByCookie());
  }

  @override
  Widget build(BuildContext context) {
    return StoreProvider<AppState>(
        store: store,
        child: MaterialApp(
          navigatorKey: _navKey,
          theme: ThemeData(
              primarySwatch: custom_red, backgroundColor: custom_red, unselectedWidgetColor: Colors.blueAccent),
          routes: {
            '/': (_) => tryCookieLoginAndBuildInitialRoute(),
            '/mockHomeScreen': (_) => const MockHomeScreen(),
            '/cameraPreviewScreen': (_) => const CameraScreenConnector(),
          },
        ));
  }

  FutureBuilder<dynamic> tryCookieLoginAndBuildInitialRoute() {
    return FutureBuilder(
        future: tryLoginByCookie,
        builder: (ctx, result) {
          return !result.hasData
              ? const Scaffold(body: Center(child: CircularProgressIndicator()))
              : result.data != true
                  ? const LoginScreen()
                  : const MockHomeScreen();
        });
  }
}
