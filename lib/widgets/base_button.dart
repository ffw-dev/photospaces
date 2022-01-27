import 'package:flutter/material.dart';

class BaseButton extends StatelessWidget {
  final String? text;
  final Text? textWidget;
  final VoidCallback _callback;
  final Color? textColour;
  final double? fontSize;
  final double? padding;

  const BaseButton(this.text, this.textWidget, this._callback, {this.textColour, this.fontSize, this.padding, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
      return TextButton(
          onPressed: _callback,
          child: Padding(
            padding: EdgeInsets.all(padding ?? 12),
            child: textWidget ?? Text(
              text!,
              style: TextStyle(fontSize: fontSize ?? 16, color: textColour ?? Theme.of(context).unselectedWidgetColor),
            ),
          ));
    }
}
