import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'auto_start_flutter_method_channel.dart';

/// The interface that platform implementations of `auto_start_flutter` must
/// extend.
///
/// The top-level functions exported by `package:auto_start_flutter` delegate to
/// [AutoStartFlutterPlatform.instance], so the whole plugin can be replaced
/// with a fake in tests or by a federated implementation.
///
/// Methods here are raw: they may throw `PlatformException` or
/// `MissingPluginException`. The public top-level functions translate those
/// into safe return values.
abstract class AutoStartFlutterPlatform extends PlatformInterface {
  /// Constructs a AutoStartFlutterPlatform.
  AutoStartFlutterPlatform() : super(token: _token);

  static final Object _token = Object();

  static AutoStartFlutterPlatform _instance = MethodChannelAutoStartFlutter();

  /// The default instance of [AutoStartFlutterPlatform] to use.
  ///
  /// Defaults to [MethodChannelAutoStartFlutter].
  static AutoStartFlutterPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [AutoStartFlutterPlatform] when
  /// they register themselves.
  static set instance(AutoStartFlutterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Returns a human readable platform version string.
  Future<String?> getPlatformVersion() {
    throw UnimplementedError('getPlatformVersion() has not been implemented.');
  }

  /// Whether an auto-start settings page exists on this device.
  Future<bool?> isAutoStartAvailable() {
    throw UnimplementedError(
        'isAutoStartAvailable() has not been implemented.');
  }

  /// Opens the auto-start settings page.
  Future<bool?> openAutoStartSettings() {
    throw UnimplementedError(
        'openAutoStartSettings() has not been implemented.');
  }

  /// Opens the app info page.
  Future<void> openAppInfo() {
    throw UnimplementedError('openAppInfo() has not been implemented.');
  }

  /// Returns the device manufacturer.
  Future<String?> getDeviceManufacturer() {
    throw UnimplementedError(
        'getDeviceManufacturer() has not been implemented.');
  }

  /// Opens an arbitrary activity.
  Future<bool?> openCustomSetting(String packageName, String activityName) {
    throw UnimplementedError('openCustomSetting() has not been implemented.');
  }

  /// Whether the app is exempt from battery optimization.
  Future<bool?> isBatteryOptimizationDisabled() {
    throw UnimplementedError(
        'isBatteryOptimizationDisabled() has not been implemented.');
  }

  /// Prompts to exempt the app from battery optimization.
  Future<void> disableBatteryOptimization() {
    throw UnimplementedError(
        'disableBatteryOptimization() has not been implemented.');
  }

  /// Opens the system battery optimization list.
  Future<bool?> openBatteryOptimizationSettings() {
    throw UnimplementedError(
        'openBatteryOptimizationSettings() has not been implemented.');
  }

  /// Whether the app may schedule exact alarms.
  Future<bool?> canScheduleExactAlarms() {
    throw UnimplementedError(
        'canScheduleExactAlarms() has not been implemented.');
  }

  /// Opens the exact alarm settings page.
  Future<bool?> openExactAlarmSettings() {
    throw UnimplementedError(
        'openExactAlarmSettings() has not been implemented.');
  }

  /// Registers a callback handle to run on boot.
  Future<bool?> registerBootCallback(int callbackHandle) {
    throw UnimplementedError(
        'registerBootCallback() has not been implemented.');
  }

  /// Starts the keep-alive foreground service.
  Future<bool?> startForegroundService(String title, String content) {
    throw UnimplementedError(
        'startForegroundService() has not been implemented.');
  }

  /// Stops the keep-alive foreground service.
  Future<bool?> stopForegroundService() {
    throw UnimplementedError(
        'stopForegroundService() has not been implemented.');
  }

  /// Schedules a task at [timestampMillis] (ms since epoch).
  Future<bool?> scheduleTask(
      int timestampMillis, int callbackHandle, String taskId) {
    throw UnimplementedError('scheduleTask() has not been implemented.');
  }

  /// Cancels a previously scheduled task.
  Future<bool?> cancelTask(String taskId) {
    throw UnimplementedError('cancelTask() has not been implemented.');
  }

  /// Returns ids of tasks that are scheduled and have not fired yet.
  Future<List<String>?> getScheduledTaskIds() {
    throw UnimplementedError('getScheduledTaskIds() has not been implemented.');
  }

  /// Returns the arguments the app was launched with.
  Future<Map<dynamic, dynamic>?> getLaunchArguments() {
    throw UnimplementedError('getLaunchArguments() has not been implemented.');
  }

  /// Runs [callbackHandle] in a headless engine.
  Future<bool?> executeInBackground(int callbackHandle) {
    throw UnimplementedError('executeInBackground() has not been implemented.');
  }

  /// Tells the platform that a headless callback has finished so its engine
  /// can be released.
  Future<void> completeBackgroundTask() {
    throw UnimplementedError(
        'completeBackgroundTask() has not been implemented.');
  }
}
