import 'package:async_redux/async_redux.dart';
import 'package:dev_eza_api/main.dart';
import 'package:ffw_photospaces/redux/app_state.dart';
import 'package:ffw_photospaces/screens/camera_screen.dart';
import 'package:ffw_photospaces/screens/login_screen.dart';
import 'package:ffw_photospaces/screens/mock_home_screen.dart';
import 'package:ffw_photospaces/services/authentication_service.dart';
import 'package:ffw_photospaces/services/current_locales_service.dart';
import 'package:ffw_photospaces/services/session_service.dart';
import 'package:flutter/material.dart';
import "package:flutter/services.dart" as flutter_services;
import 'package:yaml/yaml.dart';

late CurrentLocalesService currentLocalesService;

void main() async {
  configureDependencies();
  WidgetsFlutterBinding.ensureInitialized();
  currentLocalesService = CurrentLocalesService(
      await flutter_services.rootBundle.loadString("locales/en.yaml").then((value) => loadYaml(value)));
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
  static const MaterialColor custom_red = MaterialColor(
      0xFFb71c1c,
      <int, Color> {
        50: Color(0xFFF6F5F5),
        100: Color(0xFFD3E0EA),
        200: Color(0xFFD3E0EA),
        300: Color(0xFFD3E0EA),
        400: Color(0xFF1687A7),
        500: Color(0xFF276678),
        600: Color(0xFFD3E0EA),
        700: Color(0xFF1687A7),
      }
  );

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
          theme: ThemeData(primarySwatch: custom_red, backgroundColor: custom_red, unselectedWidgetColor: Colors.blueAccent),
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
