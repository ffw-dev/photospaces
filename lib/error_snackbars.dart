import 'package:dev_eza_api/base_http_service.dart';
import 'package:flutter/material.dart';

SnackBar apiExceptionSnackBar(DevEzaException e) => SnackBar(content: ConstrainedBox(
  constraints: const BoxConstraints(
      maxHeight: 100
  ),
  child: Column(
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text('Error name: ' + (e.errorResponsePart.fullName ?? 'Unknown name')),
          Text('Code: ' + (e.errorResponsePart.code == null ? 'no code' : e.errorResponsePart.code.toString())),
        ],
      ),
      Align(alignment: Alignment.bottomCenter, child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Text(e.errorResponsePart.message ?? 'Unknown error', style: const TextStyle(color: Colors.red),),
      ),)
    ],),
));

SnackBar exceptionSnackBar(dynamic e) => SnackBar(content: ConstrainedBox(
  constraints: const BoxConstraints(
      maxHeight: 100
  ),
  child: Center(child: Text(e),)
));