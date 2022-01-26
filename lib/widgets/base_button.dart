import 'package:flutter/material.dart';

class BaseButton extends StatelessWidget {
  final String? text;
  final Text? textWidget;
  final VoidCallback _callback;
  final Color? textColour;

  const BaseButton(this.text, this.textWidget, this._callback, {this.textColour, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
      return TextButton(
          onPressed: _callback,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: textWidget ?? Text(
              text!,
              style: TextStyle(fontSize: 16, color: textColour ?? Theme.of(context).unselectedWidgetColor),
            ),
          ));
    }
}
