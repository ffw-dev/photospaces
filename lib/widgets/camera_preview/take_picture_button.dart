import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TakePictureButton extends StatelessWidget {
  final VoidCallback callback;

  const TakePictureButton({Key? key, required this.callback}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 70,
            height: 70,
            child: Container(
              decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
            ),
          ),
          SizedBox(
            width: 61,
            height: 61,
            child: Container(
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(
                    color: Theme.of(context).primaryColor,
                    width: 2.0,
                  )),
            ),
          )
        ],
      ),
      onTap: callback,
    );
  }
}
