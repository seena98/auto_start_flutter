import 'dart:async';

import 'package:flutter/services.dart';

///initial AutoStart Class
const MethodChannel _channel =
    const MethodChannel('com.techflow.co/auto_start_flutter');

/// It checks if the phone has auto-start function.
Future<bool?> get isAutoStartAvailable async {
  ///check availability
  //auto start availability
  final bool? isAutoStartAvailable =
      await _channel.invokeMethod('isAutoStartPermission');
  return isAutoStartAvailable;
}

///It navigates to settings => auto-start option where users can manually enable auto-start.
///Returns [true] if the settings page was opened, [false] otherwise.
Future<bool> getAutoStartPermission() async {
  try {
    final bool? success = await _channel.invokeMethod("permit-auto-start");
    return success ?? false;
  } catch (e) {
    print(e);
    return false;
  }
}

/// Open the App Info page in system settings.
/// This is useful as a fallback if specific auto-start settings cannot be opened.
Future<void> openAppInfo() async {
  try {
    await _channel.invokeMethod("openAppInfo");
  } catch (e) {
    print(e);
  }
}

/// Get the device manufacturer name.
Future<String?> getDeviceManufacturer() async {
  try {
    return await _channel.invokeMethod("getDeviceManufacturer");
  } catch (e) {
    print(e);
    return null;
  }
}

/// Check if battery optimization is disabled
Future<bool?> get isBatteryOptimizationDisabled async {
  final bool? isBatteryOptimizationDisabled =
      await _channel.invokeMethod('isBatteryOptimizationDisabled');
  return isBatteryOptimizationDisabled;
}

/// Open battery optimization settings
Future<void> disableBatteryOptimization() async {
  try {
    await _channel.invokeMethod("disableBatteryOptimization");
  } catch (e) {
    print(e);
  }
}
