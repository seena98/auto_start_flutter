import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../auto_start_flutter_platform_interface.dart';

/// A callback that can be run headlessly (boot, scheduled task or immediate
/// background execution).
///
/// It must be a top-level or static function annotated with
/// `@pragma('vm:entry-point')`.
typedef BackgroundCallback = FutureOr<void> Function();

/// The outcome of asking the OS to open a settings page.
enum SettingsResult {
  /// The settings page was opened.
  opened,

  /// This device has no matching settings page (for example an OEM without an
  /// auto-start manager). Consider falling back to [AutoStart.openAppInfo].
  notAvailable,

  /// The feature doesn't exist on this platform.
  unsupported,

  /// The platform reported an error while opening the page.
  failed,
}

/// The outcome of [AutoStart.scheduleTask].
enum ScheduleResult {
  /// The task was scheduled.
  scheduled,

  /// Android 12+ requires the exact alarm permission. Guide the user with
  /// [AutoStart.openExactAlarmSettings] and try again.
  exactAlarmDenied,

  /// The callback isn't a top-level or static function annotated with
  /// `@pragma('vm:entry-point')`.
  invalidCallback,

  /// Scheduling isn't supported on this platform.
  unsupported,

  /// The platform reported an error or declined to schedule.
  failed,
}

/// A snapshot of the settings that influence whether the app can run in the
/// background.
@immutable
class BackgroundStatus {
  /// Creates a [BackgroundStatus].
  const BackgroundStatus({
    required this.manufacturer,
    required this.isAutoStartAvailable,
    required this.isBatteryOptimizationDisabled,
    required this.canScheduleExactAlarms,
  });

  /// Device manufacturer, or `null` if unknown.
  final String? manufacturer;

  /// Whether the device has an OEM auto-start settings page.
  final bool isAutoStartAvailable;

  /// Whether the app is exempt from battery optimization; `null` if unknown.
  final bool? isBatteryOptimizationDisabled;

  /// Whether exact alarms can be scheduled.
  final bool canScheduleExactAlarms;

  @override
  bool operator ==(Object other) =>
      other is BackgroundStatus &&
      other.manufacturer == manufacturer &&
      other.isAutoStartAvailable == isAutoStartAvailable &&
      other.isBatteryOptimizationDisabled == isBatteryOptimizationDisabled &&
      other.canScheduleExactAlarms == canScheduleExactAlarms;

  @override
  int get hashCode => Object.hash(manufacturer, isAutoStartAvailable,
      isBatteryOptimizationDisabled, canScheduleExactAlarms);

  @override
  String toString() =>
      'BackgroundStatus(manufacturer: $manufacturer, autoStart: $isAutoStartAvailable, '
      'batteryOptimizationDisabled: $isBatteryOptimizationDisabled, '
      'exactAlarms: $canScheduleExactAlarms)';
}

/// Entry point of the plugin.
///
/// All methods are static and never throw: unsupported platforms and native
/// errors are reported through the return value.
abstract final class AutoStart {
  static AutoStartFlutterPlatform get _platform =>
      AutoStartFlutterPlatform.instance;

  static int _taskCounter = 0;

  /// Runs [action], logging and returning [fallback] if it fails.
  static Future<T> _guard<T>(Future<T> Function() action, T fallback) async {
    try {
      return await action();
    } on MissingPluginException {
      return fallback;
    } catch (e) {
      debugPrint('auto_start_flutter: $e');
      return fallback;
    }
  }

  static Future<SettingsResult> _open(Future<bool?> Function() action) async {
    try {
      return (await action()) == true
          ? SettingsResult.opened
          : SettingsResult.notAvailable;
    } on MissingPluginException {
      return SettingsResult.unsupported;
    } catch (e) {
      debugPrint('auto_start_flutter: $e');
      return SettingsResult.failed;
    }
  }

  // --- Settings pages ------------------------------------------------------

  /// Whether the device has an OEM auto-start settings page (or, on iOS,
  /// whether Background App Refresh is available).
  static Future<bool> isAutoStartSettingsAvailable() async =>
      await _guard<bool?>(() => _platform.isAutoStartAvailable(), false) ??
      false;

  /// Opens the auto-start settings page where users can enable auto-start.
  static Future<SettingsResult> openAutoStartSettings() =>
      _open(() => _platform.openAutoStartSettings());

  /// Opens the app info page in system settings. A good fallback when
  /// [openAutoStartSettings] returns [SettingsResult.notAvailable].
  static Future<SettingsResult> openAppInfo() => _open(() async {
        await _platform.openAppInfo();
        return true;
      });

  /// Returns the device manufacturer, or `null` if unknown.
  static Future<String?> getManufacturer() =>
      _guard<String?>(() => _platform.getDeviceManufacturer(), null);

  /// Opens an arbitrary activity by [packageName] and [activityName]. Useful
  /// for OEM pages the plugin doesn't know about yet.
  static Future<SettingsResult> openCustomSetting({
    required String packageName,
    required String activityName,
  }) =>
      _open(() => _platform.openCustomSetting(packageName, activityName));

  // --- Battery optimization -----------------------------------------------

  /// Whether the app is exempt from battery optimization; `null` if the state
  /// can't be determined.
  static Future<bool?> isBatteryOptimizationDisabled() =>
      _guard<bool?>(() => _platform.isBatteryOptimizationDisabled(), null);

  /// Shows the system dialog asking to exempt the app from battery
  /// optimization (`ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS`).
  ///
  /// Google Play restricts which apps may use this; prefer
  /// [openBatteryOptimizationSettings] unless your app qualifies.
  static Future<SettingsResult> requestIgnoreBatteryOptimization() =>
      _open(() async {
        await _platform.disableBatteryOptimization();
        return true;
      });

  /// Opens the system battery optimization list, where users can whitelist the
  /// app manually. Google Play policy-safe.
  static Future<SettingsResult> openBatteryOptimizationSettings() =>
      _open(() => _platform.openBatteryOptimizationSettings());

  // --- Exact alarms ---------------------------------------------------------

  /// Whether exact alarms may be scheduled (Android 12+). `true` where the
  /// concept doesn't exist; `false` if the permission is missing or the check
  /// failed.
  static Future<bool> canScheduleExactAlarms() async {
    try {
      return await _platform.canScheduleExactAlarms() ?? true;
    } on MissingPluginException {
      return true;
    } catch (e) {
      debugPrint('auto_start_flutter: $e');
      return false;
    }
  }

  /// Opens the "Alarms & reminders" settings page (Android 12+).
  static Future<SettingsResult> openExactAlarmSettings() =>
      _open(() => _platform.openExactAlarmSettings());

  // --- Headless execution ---------------------------------------------------

  /// Registers [callback] to run headlessly when the device boots (Android).
  ///
  /// Call [completeBackgroundTask] at the end of the callback to release the
  /// headless engine early.
  static Future<bool> registerBootCallback(BackgroundCallback callback) async {
    final int? handle = _handleFor(callback);
    if (handle == null) return false;
    return await _guard<bool?>(
            () => _platform.registerBootCallback(handle), false) ??
        false;
  }

  /// Starts a keep-alive foreground service with a persistent notification
  /// (Android 8.0+).
  static Future<bool> startForegroundService({
    String title = 'Running in background',
    String content = 'Keep-alive service is active.',
  }) async =>
      await _guard<bool?>(
          () => _platform.startForegroundService(title, content), false) ??
      false;

  /// Stops the keep-alive foreground service.
  static Future<bool> stopForegroundService() async =>
      await _guard<bool?>(() => _platform.stopForegroundService(), false) ??
      false;

  /// Schedules [callback] to run headlessly at [at].
  ///
  /// [taskId] identifies the task for [cancelTask]; scheduling again with the
  /// same id replaces the task. On Android, tasks survive reboots. Returns
  /// [ScheduleResult.exactAlarmDenied] on Android 12+ when the exact alarm
  /// permission is missing.
  static Future<ScheduleResult> scheduleTask(
    DateTime at,
    BackgroundCallback callback, {
    String? taskId,
  }) async {
    final int? handle = _handleFor(callback);
    if (handle == null) return ScheduleResult.invalidCallback;
    final String id =
        taskId ?? '${DateTime.now().microsecondsSinceEpoch}-${_taskCounter++}';
    try {
      final bool? ok =
          await _platform.scheduleTask(at.millisecondsSinceEpoch, handle, id);
      return ok == true ? ScheduleResult.scheduled : ScheduleResult.failed;
    } on MissingPluginException {
      return ScheduleResult.unsupported;
    } on PlatformException catch (e) {
      debugPrint('auto_start_flutter: ${e.code}: ${e.message}');
      return e.code == 'EXACT_ALARM_DENIED'
          ? ScheduleResult.exactAlarmDenied
          : ScheduleResult.failed;
    } catch (e) {
      debugPrint('auto_start_flutter: $e');
      return ScheduleResult.failed;
    }
  }

  /// Cancels a task created with [scheduleTask]. Returns `true` if it existed.
  static Future<bool> cancelTask(String taskId) async =>
      await _guard<bool?>(() => _platform.cancelTask(taskId), false) ?? false;

  /// Ids of tasks that are scheduled and haven't fired yet.
  static Future<List<String>> getScheduledTaskIds() async =>
      await _guard<List<String>?>(
          () => _platform.getScheduledTaskIds(), null) ??
      <String>[];

  /// Arguments the app was launched with (for example from a scheduled task
  /// notification). Supported on iOS, macOS and Windows; empty elsewhere.
  static Future<Map<String, dynamic>> getLaunchArguments() async {
    final Map<dynamic, dynamic>? args = await _guard<Map<dynamic, dynamic>?>(
        () => _platform.getLaunchArguments(), null);
    return args?.cast<String, dynamic>() ?? <String, dynamic>{};
  }

  /// Runs [callback] immediately in a headless Flutter engine.
  ///
  /// On Android the engine is released when the callback calls
  /// [completeBackgroundTask] (or after a 5 minute safety timeout). On desktop
  /// the callback runs in a background Dart isolate: plugins that support
  /// background isolates work, but there is no UI and no Flutter binding.
  static Future<bool> executeInBackground(BackgroundCallback callback) async {
    if (!kIsWeb &&
        (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      try {
        await Isolate.spawn(
            _runCallback, <Object?>[callback, RootIsolateToken.instance]);
        return true;
      } catch (e) {
        debugPrint('auto_start_flutter: isolate spawn error: $e');
        return false;
      }
    }
    final int? handle = _handleFor(callback);
    if (handle == null) return false;
    return await _guard<bool?>(
            () => _platform.executeInBackground(handle), false) ??
        false;
  }

  /// Signals that a headless callback (boot, scheduled or
  /// [executeInBackground]) has finished so its engine can be released.
  static Future<void> completeBackgroundTask() =>
      _guard<void>(() => _platform.completeBackgroundTask(), null);

  // --- Diagnostics ----------------------------------------------------------

  /// Collects the device's background-execution state in a single call.
  static Future<BackgroundStatus> getStatus() async {
    final results = await Future.wait<Object?>([
      getManufacturer(),
      isAutoStartSettingsAvailable(),
      isBatteryOptimizationDisabled(),
      canScheduleExactAlarms(),
    ]);
    return BackgroundStatus(
      manufacturer: results[0] as String?,
      isAutoStartAvailable: results[1]! as bool,
      isBatteryOptimizationDisabled: results[2] as bool?,
      canScheduleExactAlarms: results[3]! as bool,
    );
  }

  static int? _handleFor(Function callback) {
    final CallbackHandle? handle = PluginUtilities.getCallbackHandle(callback);
    if (handle == null) {
      debugPrint(
          "auto_start_flutter: failed to get callback handle. Ensure the function is static or top-level and annotated with @pragma('vm:entry-point').");
      return null;
    }
    return handle.toRawHandle();
  }
}

/// Entry point of the desktop background isolate. Initialising the background
/// binary messenger lets plugins that support background isolates work inside
/// the callback.
Future<void> _runCallback(List<Object?> message) async {
  final callback = message[0]! as BackgroundCallback;
  final token = message[1] as RootIsolateToken?;
  if (token != null) {
    BackgroundIsolateBinaryMessenger.ensureInitialized(token);
  }
  DartPluginRegistrant.ensureInitialized();
  await callback();
}
