import 'dart:ui';
import 'package:flutter/material.dart';

class ConfirmBox extends StatefulWidget {
  String title;
  String content;
  VoidCallback continueCallBack;
  VoidCallback cancelCallBack;
  dynamic button1Text;
  dynamic button2Text;

  ConfirmBox(
      {super.key,
      required this.title,
      required this.content,
      required this.continueCallBack,
      required this.cancelCallBack,
      this.button1Text,
      this.button2Text
      });

  @override
  State<ConfirmBox> createState() => _ConfirmBoxState();
}

class _ConfirmBoxState extends State<ConfirmBox> {
  TextStyle titleStyle = const TextStyle(
      color: Colors.black,
      fontFamily: "Cairo",
      fontSize: 22,
      fontWeight: FontWeight.bold);
  TextStyle contentStyle =
      const TextStyle(color: Colors.black, fontFamily: "Cairo", fontSize: 20);

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
      child: AlertDialog(
        title:
            Text(widget.title, textAlign: TextAlign.center, style: titleStyle),
        content: Text(widget.content,
            textAlign: TextAlign.center, style: contentStyle),
        actions: [
          TextButton(
            onPressed: () => widget.continueCallBack(),
            child: Text(widget.button1Text ?? 'Yes',
                style: const TextStyle(
                    fontSize: 20,
                    fontFamily: "Cairo",
                    fontWeight: FontWeight.bold)),
          ),
          TextButton(
              onPressed: () => widget.cancelCallBack(),
              child: Text(widget.button2Text ?? 'No',
                  style: const TextStyle(
                      fontSize: 20,
                      fontFamily: "Cairo",
                      fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}
