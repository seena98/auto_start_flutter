import 'dart:async';
import 'package:flutter/services.dart';

///initial AutoStart Class
const MethodChannel _channel =
    const MethodChannel('com.techflow.co/auto_start_flutter');

/// It checks if the phone has auto-start function.
Future<bool> get isAutoStartAvailable async {
  ///check availability
  //auto start availability
  final bool isAutoStartAvailable =
      await _channel.invokeMethod('isAutoStartPermission');
  return isAutoStartAvailable;
}

///It navigates to settings => auto-start option where users can manually enable auto-start. It's not possible to check if user has turned on this option or not.
Future<void> getAutoStartPermission() async {
  try {
    await _channel.invokeMethod("permit-auto-start");
  } on PlatformException catch (e) {
    print(e);
  }
}
