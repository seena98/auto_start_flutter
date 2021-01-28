import 'dart:async';

import 'package:flutter/services.dart';

class AutoStartFlutter {
  static const MethodChannel _channel =
      const MethodChannel('com.techflow.co/auto_start_flutter');

  static Future<bool> get isAutoStartAvailable async {
    final bool isAutoStartAvailable =
        await _channel.invokeMethod('isAutoStartPermission');
    return isAutoStartAvailable;
  }

  static Future<void> getAutoStartPermission() async {
    try {
      await _channel.invokeMethod("permit-auto-start");
    } on PlatformException catch (e) {
      print(e);
    }
  }
}
