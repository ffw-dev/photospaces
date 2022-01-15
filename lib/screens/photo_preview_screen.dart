import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PhotoPreviewScreen extends StatelessWidget {
  XFile file;

  PhotoPreviewScreen(this.file, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ConstrainedBox(
              constraints: BoxConstraints(
                  minWidth: MediaQuery
                      .of(context)
                      .size
                      .width, maxHeight: MediaQuery
                  .of(context)
                  .size
                  .height * 0.7),
              child: Image.file(File(file.path))),
          IconButton(
            icon: const Icon(Icons.arrow_left_sharp, size: 46, color: Colors.red),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
