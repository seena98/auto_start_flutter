import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'auto_start_flutter_platform_interface.dart';

/// An implementation of [AutoStartFlutterPlatform] that uses method channels.
class MethodChannelAutoStartFlutter extends AutoStartFlutterPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel =
      const MethodChannel('com.techflow.co/auto_start_flutter');

  @override
  Future<String?> getPlatformVersion() =>
      methodChannel.invokeMethod<String>('getPlatformVersion');

  @override
  Future<bool?> isAutoStartAvailable() =>
      methodChannel.invokeMethod<bool>('isAutoStartPermission');

  @override
  Future<bool?> openAutoStartSettings() =>
      methodChannel.invokeMethod<bool>('permit-auto-start');

  @override
  Future<void> openAppInfo() => methodChannel.invokeMethod<void>('openAppInfo');

  @override
  Future<String?> getDeviceManufacturer() =>
      methodChannel.invokeMethod<String>('getDeviceManufacturer');

  @override
  Future<bool?> openCustomSetting(String packageName, String activityName) =>
      methodChannel.invokeMethod<bool>('openCustomSetting', {
        'packageName': packageName,
        'activityName': activityName,
      });

  @override
  Future<bool?> isBatteryOptimizationDisabled() =>
      methodChannel.invokeMethod<bool>('isBatteryOptimizationDisabled');

  @override
  Future<void> disableBatteryOptimization() =>
      methodChannel.invokeMethod<void>('disableBatteryOptimization');

  @override
  Future<bool?> openBatteryOptimizationSettings() =>
      methodChannel.invokeMethod<bool>('openBatteryOptimizationSettings');

  @override
  Future<bool?> canScheduleExactAlarms() =>
      methodChannel.invokeMethod<bool>('canScheduleExactAlarms');

  @override
  Future<bool?> openExactAlarmSettings() =>
      methodChannel.invokeMethod<bool>('openExactAlarmSettings');

  @override
  Future<bool?> registerBootCallback(int callbackHandle) =>
      methodChannel.invokeMethod<bool>(
          'registerBootCallback', {'callbackHandle': callbackHandle});

  @override
  Future<bool?> startForegroundService(String title, String content) =>
      methodChannel.invokeMethod<bool>(
          'startForegroundService', {'title': title, 'content': content});

  @override
  Future<bool?> stopForegroundService() =>
      methodChannel.invokeMethod<bool>('stopForegroundService');

  @override
  Future<bool?> scheduleTask(
          int timestampMillis, int callbackHandle, String taskId) =>
      methodChannel.invokeMethod<bool>('scheduleTask', {
        'timestamp': timestampMillis,
        'callbackHandle': callbackHandle,
        'taskId': taskId,
      });

  @override
  Future<bool?> cancelTask(String taskId) =>
      methodChannel.invokeMethod<bool>('cancelTask', {'taskId': taskId});

  @override
  Future<List<String>?> getScheduledTaskIds() async {
    final List<dynamic>? ids =
        await methodChannel.invokeMethod<List<dynamic>>('getScheduledTaskIds');
    return ids?.cast<String>();
  }

  @override
  Future<Map<dynamic, dynamic>?> getLaunchArguments() =>
      methodChannel.invokeMethod<Map<dynamic, dynamic>>('getLaunchArguments');

  @override
  Future<bool?> executeInBackground(int callbackHandle) =>
      methodChannel.invokeMethod<bool>(
          'executeInBackground', {'callbackHandle': callbackHandle});

  @override
  Future<void> completeBackgroundTask() =>
      methodChannel.invokeMethod<void>('completeBackgroundTask');
}
