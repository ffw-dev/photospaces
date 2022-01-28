import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EmptyDescriptionSnackBar extends SnackBar {
  const EmptyDescriptionSnackBar.create(BuildContext context)
      : super(
          content: const SnackBar(
              content: Padding(
            padding: EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                'It is better to add a description to an asset.',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
          )),
        );

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
