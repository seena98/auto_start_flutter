import 'src/auto_start.dart';

export 'auto_start_flutter_method_channel.dart';
export 'auto_start_flutter_platform_interface.dart';
export 'src/auto_start.dart';

// The functions below are the original top-level API. They keep working and
// delegate to [AutoStart], but are deprecated in favour of it.

/// It checks if the phone has auto-start function.
@Deprecated('Use AutoStart.isAutoStartSettingsAvailable()')
Future<bool?> get isAutoStartAvailable =>
    AutoStart.isAutoStartSettingsAvailable();

/// Opens the auto-start settings. Returns `true` if the page was opened.
@Deprecated('Use AutoStart.openAutoStartSettings()')
Future<bool> getAutoStartPermission() async =>
    await AutoStart.openAutoStartSettings() == SettingsResult.opened;

/// Opens the App Info page in system settings.
@Deprecated('Use AutoStart.openAppInfo()')
Future<void> openAppInfo() => AutoStart.openAppInfo();

/// Gets the device manufacturer name.
@Deprecated('Use AutoStart.getManufacturer()')
Future<String?> getDeviceManufacturer() => AutoStart.getManufacturer();

/// Opens a custom setting by package name and activity name.
@Deprecated('Use AutoStart.openCustomSetting()')
Future<bool> openCustomSetting({
  required String packageName,
  required String activityName,
}) async =>
    await AutoStart.openCustomSetting(
        packageName: packageName, activityName: activityName) ==
    SettingsResult.opened;

/// Checks if battery optimization is disabled; `null` if unknown.
@Deprecated('Use AutoStart.isBatteryOptimizationDisabled()')
Future<bool?> get isBatteryOptimizationDisabled =>
    AutoStart.isBatteryOptimizationDisabled();

/// Prompts the user to exempt the app from battery optimization.
@Deprecated('Use AutoStart.requestIgnoreBatteryOptimization()')
Future<void> disableBatteryOptimization() =>
    AutoStart.requestIgnoreBatteryOptimization();

/// Opens the system battery optimization settings page.
@Deprecated('Use AutoStart.openBatteryOptimizationSettings()')
Future<bool> openBatteryOptimizationSettings() async =>
    await AutoStart.openBatteryOptimizationSettings() == SettingsResult.opened;

/// Whether exact alarms can be scheduled (Android 12+).
@Deprecated('Use AutoStart.canScheduleExactAlarms()')
Future<bool> canScheduleExactAlarms() => AutoStart.canScheduleExactAlarms();

/// Opens the exact alarm settings page (Android 12+).
@Deprecated('Use AutoStart.openExactAlarmSettings()')
Future<bool> openExactAlarmSettings() async =>
    await AutoStart.openExactAlarmSettings() == SettingsResult.opened;

/// Registers a callback to run headlessly on boot (Android).
@Deprecated('Use AutoStart.registerBootCallback()')
Future<bool> registerBootCallback(Function callback) =>
    AutoStart.registerBootCallback(callback as BackgroundCallback);

/// Starts the keep-alive foreground service (Android).
@Deprecated('Use AutoStart.startForegroundService()')
Future<bool> startForegroundService(
        {String title = "Running in background",
        String content = "Keep-alive service is active."}) =>
    AutoStart.startForegroundService(title: title, content: content);

/// Stops the keep-alive foreground service (Android).
@Deprecated('Use AutoStart.stopForegroundService()')
Future<bool> stopForegroundService() => AutoStart.stopForegroundService();

/// Schedules a task to run headlessly at [at].
@Deprecated('Use AutoStart.scheduleTask(), which reports why scheduling failed')
Future<bool> scheduleTask(DateTime at, Function callback,
        {String? taskId}) async =>
    await AutoStart.scheduleTask(at, callback as BackgroundCallback,
        taskId: taskId) ==
    ScheduleResult.scheduled;

/// Returns the arguments the app was launched with.
@Deprecated('Use AutoStart.getLaunchArguments()')
Future<Map<String, dynamic>> getLaunchArguments() =>
    AutoStart.getLaunchArguments();

/// Executes [callback] immediately in a headless background engine.
@Deprecated('Use AutoStart.executeInBackground()')
Future<bool> executeInBackground(Function callback) =>
    AutoStart.executeInBackground(callback as BackgroundCallback);
