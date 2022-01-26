import 'package:flutter/material.dart';

class BaseOutlinedButton extends StatefulWidget {
  final String? text;
  final Text? textWidget;
  final VoidCallback _callback;
  final Color? textColour;
  final bool ignoreClick;
  final bool initialSelected;

  const BaseOutlinedButton(this.text, this.textWidget, this._callback, {this.textColour, this.ignoreClick = false, this.initialSelected = false, Key? key}) : super(key: key);

  @override
  State<BaseOutlinedButton> createState() => _BaseOutlinedButtonState();
}

class _BaseOutlinedButtonState extends State<BaseOutlinedButton> {
  late bool isSelected = true;

  @override
  void initState() {
    setState(() {
      if(widget.ignoreClick) {
        isSelected = widget.ignoreClick;
      } else {
        isSelected = widget.initialSelected;
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 17),
      padding: const EdgeInsets.all(2),
      child: ElevatedButton(
        style: OutlinedButton.styleFrom(
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(29))),
          elevation: isSelected ? 4 : 0,
          backgroundColor: isSelected ? Theme.of(context).primaryColor.withBlue(50).withGreen(50) : null,
          side: BorderSide(width: isSelected ? 1 : 0, color: widget.textColour ?? Theme.of(context).primaryColor),
        ),
          onPressed: () {
            widget._callback();

            if(widget.ignoreClick != null || widget.ignoreClick == true) {
              setState(() => isSelected = !isSelected);
            }
          },
          child: widget.textWidget ?? Text(
            widget.text!,
            style: TextStyle(fontSize: 14, color: widget.textColour ?? Colors.white),
          )),
    );
  }
}
