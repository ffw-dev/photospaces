import 'package:ffw_photospaces/screens/camera_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MockHomeScreen extends StatelessWidget {
  const MockHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        child: Center(
            child: IconButton(
          onPressed: () async {
            Navigator.push(context, MaterialPageRoute(builder: (_) => CameraScreen()));
          },
          icon: Icon(Icons.camera, color: Colors.red,),
        )),
      ),
    );
  }
}
