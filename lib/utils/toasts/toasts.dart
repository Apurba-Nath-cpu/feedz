import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
enum ToastType {
  success,
  info,
  error,
}

Future<void> showToast(ToastType type, String message) async {
  switch (type) {
    case ToastType.success:
      Fluttertoast.showToast(
        msg: message,
        textColor: Colors.black,
        backgroundColor: Colors.green[200],
      );
      break;
    case ToastType.info:
      Fluttertoast.showToast(
        msg: message,
        textColor: Colors.black,
        backgroundColor: Colors.yellow[200],
      );
      break;
    case ToastType.error:
      Fluttertoast.showToast(
        msg: message,
        textColor: Colors.white,
        backgroundColor: Colors.red[200],
      );
      break;
  }
}

