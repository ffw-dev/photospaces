import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:dev_eza_api/main.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PhotoPreviewScreen extends StatelessWidget {
  XFile file;

  PhotoPreviewScreen(this.file, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Expanded(child: Center(child: Image.file(File(file.path)))),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: IconButton(
              icon: const Icon(Icons.check, size: 42, color: Colors.red),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}
