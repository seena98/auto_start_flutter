import 'dart:async';

import 'package:flutter/services.dart';

///initial AutoStart Class
class AutoStartFlutter {
  //method channel
  static const MethodChannel _channel =
      const MethodChannel('com.techflow.co/auto_start_flutter');

  /// it checks if the phone has auto-start function.
  static Future<bool> get isAutoStartAvailable async {
    //auto start availability
    final bool isAutoStartAvailable =
        await _channel.invokeMethod('isAutoStartPermission');
    return isAutoStartAvailable;
  }

  ///it navigates to setting auto-start option where users can manually enable auto-start. It's not possible to check if user has turned on this option or not.
  static Future<void> getAutoStartPermission() async {
    try {
      await _channel.invokeMethod("permit-auto-start");
    } on PlatformException catch (e) {
      print(e);
    }
  }
}
