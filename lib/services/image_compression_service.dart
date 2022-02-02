import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class ImageCompressionService {
  final int QUALITY = 30;

  Future<XFile> compressImage(XFile image) async {
    File? result;
    File imgFile = File(image.path);

    final lastIndex = imgFile.absolute.path.lastIndexOf(RegExp(r'.jp'));
    final splitted = imgFile.absolute.path.substring(0, (lastIndex));
    final outPath = "${splitted}_compressed${imgFile.absolute.path.substring(lastIndex)}";

    try {
      result = await FlutterImageCompress.compressAndGetFile(
          imgFile.absolute.path,
          outPath,
          quality: QUALITY
      );
    } on UnsupportedError catch(_) {
      result = await FlutterImageCompress.compressAndGetFile(
          imgFile.absolute.path,
          outPath,
          quality: QUALITY
      );
    } on MissingPluginException catch(_) {
      rethrow;
    }

    if(result == null) {
      throw FileCompressionFailedException('File ${image.name} compression failed.');
    }

    return XFile(result.path);
  }


}

class FileCompressionFailedException implements Exception {
  final String message;

  FileCompressionFailedException(this.message): super();
}