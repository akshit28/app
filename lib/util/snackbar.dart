import 'package:flutter/material.dart';

class CustomSnackBar extends StatelessWidget {
  final String text;
  final int seconds;
  final String type;

  const CustomSnackBar({
    Key? key,
    required this.seconds,
    required this.text,
    required this.type,
  }) : super(key: key);

  IconData _getIcon() {
    switch (type) {
      case 'success':
        return Icons.done;
      case 'error':
        return Icons.error;
      case 'notification':
        return Icons.notifications;  
      default:
        return Icons.info;
    }
  }

  Color _getColor() {
    switch (type) {
      case 'success':
        return Colors.green;
      case 'error':
        return Colors.red;
      case 'notification':
        return Colors.blue.shade900;
      default:
        return Colors.blue;
    }
  }

  SnackBar snackBar() {
    return SnackBar(
      content: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
            child: Icon(
              _getIcon(),
              color: Colors.white,
            ),
          ),
          Expanded(
              child: Text(
            text,
            style: const TextStyle(fontSize: 17),
          )),
        ],
      ),
      showCloseIcon: type == 'notification' ?  true : false,
      closeIconColor: Colors.white,
      duration: Duration(seconds: seconds),
      backgroundColor: _getColor(),
      behavior: type == 'notification' ?  SnackBarBehavior.floating : SnackBarBehavior.fixed,
    );
  }

  void show(
    BuildContext context,
  ) {
    ScaffoldMessenger.of(context)
        .showSnackBar(snackBar())
        .closed
        .then((value) => ScaffoldMessenger.of(context).clearSnackBars());
  }

  @override
  Widget build(BuildContext context) {
    return snackBar();
  }
}
