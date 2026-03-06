import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

///initial AutoStart Class
const MethodChannel _channel =
    MethodChannel('com.techflow.co/auto_start_flutter');

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
    debugPrint(e.toString());
    return false;
  }
}

/// Open the App Info page in system settings.
/// This is useful as a fallback if specific auto-start settings cannot be opened.
Future<void> openAppInfo() async {
  try {
    await _channel.invokeMethod("openAppInfo");
  } catch (e) {
    debugPrint(e.toString());
  }
}

/// Get the device manufacturer name.
Future<String?> getDeviceManufacturer() async {
  try {
    return await _channel.invokeMethod("getDeviceManufacturer");
  } catch (e) {
    debugPrint(e.toString());
    return null;
  }
}

/// Open a custom setting by package name and activity name.
/// This allows trying specific intents that are not yet natively supported by the plugin.
Future<bool> openCustomSetting({
  required String packageName,
  required String activityName,
}) async {
  try {
    final bool? success = await _channel.invokeMethod('openCustomSetting', {
      'packageName': packageName,
      'activityName': activityName,
    });
    return success ?? false;
  } catch (e) {
    debugPrint(e.toString());
    return false;
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
    debugPrint(e.toString());
  }
}

/// Registers a callback to be executed headlessly when the device boots up.
/// Only supported on Android in Phase 1.
/// The [callback] must be a top-level or static function decorated with `@pragma('vm:entry-point')`.
Future<bool> registerBootCallback(Function callback) async {
  try {
    final CallbackHandle? handle = PluginUtilities.getCallbackHandle(callback);
    if (handle == null) {
      debugPrint("Failed to get callback handle. Ensure the function is static or top-level and uses @pragma('vm:entry-point').");
      return false;
    }
    final bool? success = await _channel.invokeMethod('registerBootCallback', {
      'callbackHandle': handle.toRawHandle(),
    });
    return success ?? false;
  } catch (e) {
    debugPrint(e.toString());
    return false;
  }
}

/// Starts a Foreground Service on Android.
/// This attaches a persistent notification to the status bar, preventing the OS from killing the app when it goes to the background.
/// [title] and [content] are used to populate the persistent notification.
/// Only supported on Android 8.0+.
Future<bool> startForegroundService({String title = "Running in background", String content = "Keep-alive service is active."}) async {
  try {
    final bool? success = await _channel.invokeMethod('startForegroundService', {
      'title': title,
      'content': content,
    });
    return success ?? false;
  } catch (e) {
    debugPrint(e.toString());
    return false;
  }
}

/// Stops the Foreground Service on Android, resolving the persistent notification.
Future<bool> stopForegroundService() async {
  try {
    final bool? success = await _channel.invokeMethod('stopForegroundService');
    return success ?? false;
  } catch (e) {
    debugPrint(e.toString());
    return false;
  }
}
