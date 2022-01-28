import 'package:flutter/material.dart';

class SelectedIcon extends StatelessWidget {
  const SelectedIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Positioned(
      bottom: 6,
      right: 6,
      child: CircleAvatar(
        backgroundColor: Colors.white,
        radius: 10,
        child: Padding(
          padding: const EdgeInsets.all(0),
          child: Icon(
            Icons.check_circle,
            size: 20,
            color: Theme.of(context).unselectedWidgetColor,
          ),
        ),
      ));
}
