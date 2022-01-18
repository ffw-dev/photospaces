import 'package:ffw_photospaces/screens/camera_screen.dart';
import 'package:flutter/material.dart';

class MockHomeScreen extends StatelessWidget {
  const MockHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
          child: IconButton(
            onPressed: () async => Navigator.push(context, MaterialPageRoute(builder: (_) => const CameraScreen())),
            iconSize: 62,
            icon: const Icon(
              Icons.add_a_photo,
              color: Colors.red,
            ),
          )),
    );
  }
}
