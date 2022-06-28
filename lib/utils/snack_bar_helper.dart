import 'package:flutter/material.dart';

class SnackBarHelper {
  bool _isShown = false;
  SnackBarData _lastSnackBar;

  SnackBarHelper();

  void show(
    BuildContext context,
    String message, [
    SnackBarType type,
    Map<String, dynamic> extraInfo,
  ]) {
    if (_isShown && _lastSnackBar?.message == message) return;

    _lastSnackBar = SnackBarData(message, type);
    _isShown = true;

    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(get(context, message, type, extraInfo))
          .closed
          .then((SnackBarClosedReason reason) {
        _isShown = false;
      });
  }

  void hide(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
    });
  }

  SnackBar get(
    BuildContext context,
    String message, [
    SnackBarType type,
    Map<String, dynamic> extraInfo,
  ]) {
    return SnackBar(
      backgroundColor: _getBackgroundColor(type),
      content: Text(message),
      duration: const Duration(seconds: 10),
    );
  }

  Color _getBackgroundColor(SnackBarType type) {
    switch (type) {
      case SnackBarType.neutral:
        return null;
      case SnackBarType.error:
        return Colors.red;
      case SnackBarType.success:
        return Colors.green[800];
      default:
        return null;
    }
  }
}

class SnackBarData {
  final String message;
  final SnackBarType snackBarType;

  SnackBarData(this.message, this.snackBarType);
}

enum SnackBarType {
  neutral,
  error,
  success,
}
