import 'package:dev_eza_api/main.dart';
import 'package:ffw_photospaces/screens/camera_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MockHomeScreen extends StatelessWidget {
  const MockHomeScreen({Key? key}) : super(key: key);

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
              ),/*
              IconButton(
                onPressed: () async {
                  DevEzaApi.ezAssetEndpoints.getGet('81790b20-fbd6-4ff6-a856-4e182fac2a41').then((value) {
                    print(value.body.results[0].data![0].fields!['ReelPart_Description']);
                  });
                },
                iconSize: 62,
                icon: Icon(
                  Icons.add_a_photo,
                  color: Theme.of(context).primaryColor,
                ),
              ),*/
            ],
          ),
      ),
    );
  }
}
