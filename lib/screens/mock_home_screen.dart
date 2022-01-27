import 'package:dev_eza_api/main.dart';
import 'package:ffw_photospaces/screens/camera_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MockHomeScreen extends StatefulWidget {
  const MockHomeScreen({Key? key}) : super(key: key);

  @override
  State<MockHomeScreen> createState() => _MockHomeScreenState();
}

class _MockHomeScreenState extends State<MockHomeScreen> {
  int ICONSIZE = 62;
  Color colors = Colors.red;

  int widths = 10;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Theme.of(context).primaryColor, elevation: 0,),
      body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () async => Navigator.push(context, MaterialPageRoute(builder: (_) => const CameraScreen())),
                iconSize: 62,
                icon: Icon(
                  Icons.add_a_photo,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
      ),
    );
  }
}
