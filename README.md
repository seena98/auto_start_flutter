# auto_start_flutter

A Flutter plugin to help manage background execution on **Android, iOS, macOS, Windows, and Linux**. It opens the OEM "Auto-Start" settings on Android, checks "Background App Refresh" on iOS, manages "Startup Apps / Login Items" on Windows and macOS, and can run Dart callbacks headlessly on boot, on a schedule, or on demand.

[![pub package](https://img.shields.io/pub/v/auto_start_flutter.svg)](https://pub.dev/packages/auto_start_flutter)

## Features

- **Auto-Start settings**: manufacturer-specific "Auto-Start" / "App Launch" pages on Android (Xiaomi, Redmi, Poco, Oppo, Realme, Vivo, Huawei, Honor, Samsung, ASUS, OnePlus, Nokia, LeTV, Meizu, HTC, Infinix and more), Background App Refresh on iOS, Startup Apps on Windows, Login Items on macOS.
- **Battery optimization**: check the exemption status and open the system settings (Android), power settings (Windows/macOS).
- **Exact alarms** (Android 12+): check and request the permission.
- **Boot callback**: run a headless Dart callback when the device starts.
- **Scheduled tasks**: run a headless callback at an exact time; cancel and list tasks; Android tasks survive reboots.
- **Headless execution**: run a callback immediately without a UI.
- **Foreground service** keep-alive (Android).
- **Status snapshot**: `AutoStart.getStatus()` collects everything above in one call.
- **No surprise permissions**: the plugin declares **no** Android permissions. You add only those for the features you use (see [Android Permissions](#android-permissions)).

## Getting Started

```yaml
dependencies:
  auto_start_flutter: ^1.6.0
```

```dart
import 'package:auto_start_flutter/auto_start_flutter.dart';
```

### Android build requirements
The plugin builds with Android Gradle Plugin 8.11.1, Kotlin 2.2.20 and JDK 17. Your app should use Gradle 8.14+ (matching Flutter's current minimums).

## The `AutoStart` API

All methods are static and **never throw**: unsupported platforms and native errors are reported through the return value.

Methods that open a settings page return a `SettingsResult`:

| Value | Meaning |
|---|---|
| `opened` | The page was opened. |
| `notAvailable` | This device has no such page (e.g. no OEM auto-start manager). Fall back to `AutoStart.openAppInfo()`. |
| `unsupported` | The feature doesn't exist on this platform. |
| `failed` | The platform reported an error. |

`AutoStart.scheduleTask` returns a `ScheduleResult`: `scheduled`, `exactAlarmDenied`, `invalidCallback`, `unsupported` or `failed`.

### Platform support

| Method | Android | iOS | Windows | macOS | Linux |
| --- | --- | --- | --- | --- | --- |
| `isAutoStartSettingsAvailable` | Manufacturer has an auto-start page | Background App Refresh available | `true` | `true` | `true` |
| `openAutoStartSettings` | Auto Start page | App Settings | Startup Apps | Login Items | No-op |
| `openAppInfo` | App Info | App Settings | Apps & Features | General Settings | No-op |
| `getManufacturer` | `Build.MANUFACTURER` | "Apple" | "Microsoft" | "Apple" | "Linux" |
| `isBatteryOptimizationDisabled` | Doze exemption status | `true` | `true` | `true` | `true` |
| `requestIgnoreBatteryOptimization` | Direct system dialog | App Settings | Power & Sleep | Energy Saver | No-op |
| `openBatteryOptimizationSettings` | Battery optimization list | App Settings | Power & Sleep | Energy Saver | No-op |
| `canScheduleExactAlarms` | `AlarmManager` check (Android 12+) | `true` | `true` | `true` | `true` |
| `openExactAlarmSettings` | "Alarms & reminders" (Android 12+) | not available | not available | not available | not available |
| `openCustomSetting` | Opens an activity | unsupported | unsupported | unsupported | unsupported |
| `registerBootCallback` | `BOOT_COMPLETED` + headless engine | unsupported | Startup registry | `SMAppService` | `~/.config/autostart/` |
| `startForegroundService` | Foreground service | `false` | `false` | `false` | `false` |
| `scheduleTask` / `cancelTask` / `getScheduledTaskIds` | `AlarmManager` (persisted across reboots) | Local notification | Task Scheduler | Local notification | `systemd` user timers |
| `executeInBackground` | Headless engine | Headless engine | Background isolate | Background isolate | Background isolate |
| `completeBackgroundTask` | Releases the engine | Releases the engine | No-op | No-op | No-op |

> **Note**: Standard Android APIs can't tell whether "Auto Start" is actually enabled. `isAutoStartSettingsAvailable` only reports that the device has such a page. Only iOS lets you verify the real background refresh status.

## Usage

### Auto-start settings
```dart
if (await AutoStart.isAutoStartSettingsAvailable()) {
  final result = await AutoStart.openAutoStartSettings();
  if (result == SettingsResult.notAvailable) {
    await AutoStart.openAppInfo(); // generic fallback
  }
}
```

### Other helpers
```dart
String? manufacturer = await AutoStart.getManufacturer(); // "Xiaomi", "Apple", ...

// Android only: open a specific hidden settings activity you know about.
await AutoStart.openCustomSetting(
  packageName: 'com.android.settings',
  activityName: r'com.android.settings.Settings$PowerUsageSummaryActivity',
);
```

### One-call status
```dart
final status = await AutoStart.getStatus();
// status.manufacturer, status.isAutoStartAvailable,
// status.isBatteryOptimizationDisabled, status.canScheduleExactAlarms
```

### Boot callback
Runs a headless Dart callback (Android) or launches the app (desktop) when the device starts.

```dart
// Must be a top-level or static function.
@pragma('vm:entry-point')
Future<void> myBootCallback() async {
  WidgetsFlutterBinding.ensureInitialized();
  // ... do work ...
  await AutoStart.completeBackgroundTask(); // release the headless engine
}

await AutoStart.registerBootCallback(myBootCallback);
```
Android needs the `RECEIVE_BOOT_COMPLETED` permission ([see below](#android-permissions)).

### Scheduled tasks
```dart
final result = await AutoStart.scheduleTask(
  DateTime.now().add(const Duration(minutes: 5)),
  myScheduledTaskCallback,
  taskId: 'my_task_1', // optional; scheduling the same id again replaces the task
);

switch (result) {
  case ScheduleResult.scheduled:
    break;
  case ScheduleResult.exactAlarmDenied:
    await AutoStart.openExactAlarmSettings(); // Android 12+
  default:
    // invalidCallback / unsupported / failed
}

await AutoStart.cancelTask('my_task_1');
final pending = await AutoStart.getScheduledTaskIds();
```

- **Android**: uses `AlarmManager` and runs the callback headlessly even in Doze. Tasks are persisted and re-registered after a reboot; tasks that came due while the device was off run on boot.
- **iOS & macOS**: Apple doesn't allow generic headless wakes at exact times, so a local notification is scheduled (the user is asked for notification permission on first use). When the user taps it, the app opens and `getLaunchArguments()` contains `scheduledTaskId` and `callbackHandle`.
- **Windows**: Windows Task Scheduler. **Linux**: `systemd` user timers.

```dart
// On startup, check whether a scheduled task launched the app.
final args = await AutoStart.getLaunchArguments(); // iOS, macOS, Windows
if (args['scheduledTaskId'] == 'my_task_1') { ... }
```

**Exact alarms (Android 12+)**
```dart
if (!await AutoStart.canScheduleExactAlarms()) {
  await AutoStart.openExactAlarmSettings(); // "Alarms & reminders" page
}
```

### Headless execution
Runs a callback immediately, without a UI.

```dart
@pragma('vm:entry-point')
Future<void> myHeadlessTask() async {
  WidgetsFlutterBinding.ensureInitialized();
  // ... do work ...
  await AutoStart.completeBackgroundTask();
}

await AutoStart.executeInBackground(myHeadlessTask);
```

- **Android / iOS**: a dedicated headless `FlutterEngine`. Call `AutoStart.completeBackgroundTask()` at the end of the callback to destroy it immediately; otherwise Android destroys it after 5 minutes.
- **Desktop**: a background Dart isolate. Plugins that support background isolates work; there is no UI.

### Foreground service (Android)
Keeps the app alive with a persistent notification.
```dart
await AutoStart.startForegroundService(
  title: 'Syncing data',
  content: 'Do not close the app.',
);
await AutoStart.stopForegroundService();
```

### Battery optimization
Android's Doze and App Standby restrict background work; Windows/macOS power settings can too.

```dart
final exempt = await AutoStart.isBatteryOptimizationDisabled() ?? false;

if (!exempt) {
  // Recommended and Google Play safe: opens the system battery optimization list.
  await AutoStart.openBatteryOptimizationSettings();
}
```

Direct dialog (`ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS`):
> [!WARNING]
> Google Play strictly limits which apps may request the direct exemption dialog. Only use `requestIgnoreBatteryOptimization()` if your app qualifies; otherwise use `openBatteryOptimizationSettings()`.
```dart
await AutoStart.requestIgnoreBatteryOptimization();
```

## Android Permissions

The plugin declares **no permissions**, so you only ship what you use. Add the ones for the features you enable to `android/app/src/main/AndroidManifest.xml`. Features whose permission is missing fail gracefully (a `false` / error result); they never crash the app.

| Feature | Permission(s) | Required? |
|---|---|---|
| `registerBootCallback`, reboot-persistent `scheduleTask` | `RECEIVE_BOOT_COMPLETED` | Yes |
| `startForegroundService` | `FOREGROUND_SERVICE`; on Android 14+ also `FOREGROUND_SERVICE_SPECIAL_USE`; on Android 13+ `POST_NOTIFICATIONS` to show the notification | Yes |
| `scheduleTask` | `SCHEDULE_EXACT_ALARM`, or `USE_EXACT_ALARM` (Android 13+, only for alarm/calendar apps per Google Play policy) | Yes |
| `requestIgnoreBatteryOptimization` | `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` | Yes |
| Headless callbacks (boot, scheduled, `executeInBackground`) | `WAKE_LOCK` | Optional: without it the callback still runs, but the device may go back to sleep before it finishes |
| `openBatteryOptimizationSettings`, `openAutoStartSettings`, `openAppInfo` | none | - |

```xml
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_SPECIAL_USE" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
<uses-permission android:name="android.permission.USE_EXACT_ALARM" />
<uses-permission android:name="android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
```

## Migrating from the top-level functions (1.6.0)

The original top-level functions still work but are `@Deprecated`. They keep their signatures and `bool` results and delegate to `AutoStart`.

| Deprecated | Replacement |
|---|---|
| `isAutoStartAvailable` | `AutoStart.isAutoStartSettingsAvailable()` |
| `getAutoStartPermission()` | `AutoStart.openAutoStartSettings()` → `SettingsResult` |
| `openAppInfo()` | `AutoStart.openAppInfo()` |
| `getDeviceManufacturer()` | `AutoStart.getManufacturer()` |
| `openCustomSetting(...)` | `AutoStart.openCustomSetting(...)` → `SettingsResult` |
| `isBatteryOptimizationDisabled` | `AutoStart.isBatteryOptimizationDisabled()` |
| `disableBatteryOptimization()` | `AutoStart.requestIgnoreBatteryOptimization()` |
| `openBatteryOptimizationSettings()` | `AutoStart.openBatteryOptimizationSettings()` |
| `canScheduleExactAlarms()`, `openExactAlarmSettings()`, `registerBootCallback`, `startForegroundService`, `stopForegroundService`, `executeInBackground`, `getLaunchArguments` | same names on `AutoStart` |
| `scheduleTask(...)` → `bool` | `AutoStart.scheduleTask(...)` → `ScheduleResult` |

New in 1.6.0 (only on `AutoStart`): `cancelTask`, `getScheduledTaskIds`, `completeBackgroundTask`, `getStatus`.

## Testing

All calls go through `AutoStartFlutterPlatform`. In tests, extend it and assign `AutoStartFlutterPlatform.instance` to fake the plugin.

## Contributing
If you find any issues or would like to add support for more devices, please file an issue or pull request on GitHub.
