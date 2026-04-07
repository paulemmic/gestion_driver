import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

enum MessageType { info, success, warning, error }

class Utils {
  static DateFormat dateFull = DateFormat('dd/MM/yyyy HH:mm:ss');
  static DateFormat dateShort = DateFormat('dd/MM/yyyy');
  static DateFormat timeFull = DateFormat('HH:mm:ss');
  static DateFormat timeShort = DateFormat('HH:mm');

  static String formatCFA(double amount) {
    // Create a NumberFormat instance for currency formatting
    NumberFormat currencyFormat = NumberFormat.currency(
      locale: 'fr_FR', // Change the locale as needed
      symbol:
          'FCFA', // The currency symbol, empty string if you want only the code
      decimalDigits: 0, // The number of decimal digits to display
    );

    // Format the amount as currency
    return currencyFormat.format(amount);
  }

  static String capitalize(String name) {
    if (name.isNotEmpty && name.length > 1) {
      return '${name[0].toUpperCase()}${name.substring(1).toLowerCase()}';
    } else {
      return '';
    }
  }

  static void showToast({required String message, required Color color}) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      backgroundColor: color,
      textColor: Colors.white,
      gravity: ToastGravity.BOTTOM,
      fontSize: 16,
      timeInSecForIosWeb: 5,
    );
  }

  static void showMessage({required String message, MessageType? messageType}) {
    final Color color;
    switch (messageType) {
      case MessageType.error:
        color = Colors.red.shade300;
        break;
      case MessageType.success:
        color = Colors.green.shade300;
        break;
      case MessageType.warning:
        color = Colors.orange.shade300;
        break;
      default:
        color = Colors.blue.shade300;
        break;
    }
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      backgroundColor: color,
      textColor: color,
      gravity: ToastGravity.BOTTOM,
      fontSize: 16,
      timeInSecForIosWeb: 1,
    );
  }

  static void showErrorMessage({required String message}) {
    showToast(message: message, color: Colors.red);
  }

  static void showWarningMessage({required String message}) {
    showToast(message: message, color: Colors.orange.shade800);
  }

  static void showInfoMessage({required String message}) {
    showToast(message: message, color: Colors.blue);
  }

  static void showSuccessMessage({required String message}) {
    showToast(message: message, color: Colors.green.shade800);
  }
}
