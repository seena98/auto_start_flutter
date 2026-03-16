# auto_start_flutter

A Flutter plugin to help manage background execution permissions on **Android, iOS, macOS, Windows, and Linux** devices. It supports requesting "Auto-Start" permissions on specific Android OEM devices, checking "Background App Refresh" status on iOS, and managing "Startup Apps / Login Items" settings on Windows and macOS to ensure your app can run reliably in the background.

## Features

- **Auto-Start Permission**: 
  - **Android**: Open manufacturer-specific "Auto-Start" or "App Launch" settings.
  - **iOS**: Check Background App Refresh status.
  - **Windows/macOS**: Open the "Startup Apps" or "Login Items" system settings.
- **Battery Optimization**: Check if the app is exempt from battery optimizations and open settings to request exemption (Android) or power settings (Windows/macOS).
- **Device Support**: 
  - **Android**: Xiaomi, Redmi, Poco, Oppo, Vivo, Huawei, Honor, Samsung, ASUS, OnePlus, Nokia, LeTV, Meizu, HTC, Infinix, and more.
  - **iOS**: All devices.
  - **Windows**: Windows 10/11.
  - **macOS**: macOS 10.14+ (limitations apply).
  - **Linux**: Supported (stubbed methods due to varying Desktop Environments).
- **Robustness**: The plugin attempts multiple known intents for each manufacturer to ensure the settings page opens correctly.

[![pub package](https://img.shields.io/pub/v/auto_start_flutter.svg)](https://pub.dev/packages/auto_start_flutter)

## Getting Started

Add the package to your `pubspec.yaml`:

```yaml
  auto_start_flutter: ^1.1.0
```

Import the package:
```dart
import 'package:auto_start_flutter/auto_start_flutter.dart';
```

## Platform Support

| Feature | Android | iOS | Windows | macOS | Linux |
| --- | --- | --- | --- | --- | --- |
| `isAutoStartAvailable` | Checks manufacturer whitelist | Checks `UIBackgroundRefreshStatus` | Returns `true` | Returns `true` | Returns `true` |
| `getAutoStartPermission` | Opens Auto Start / App Info | Opens App Settings | Opens Startup Apps | Opens Login Items | Returns `true` (No-op) |
| `openAppInfo` | Opens App Info | Opens App Settings | Opens Apps & Features | Opens General Settings | Returns `true` (No-op) |
| `getDeviceManufacturer` | Returns `Build.MANUFACTURER` | Returns "Apple" | Returns "Microsoft" | Returns "Apple" | Returns "Linux" |
| `isBatteryOptimizationDisabled` | Checks doze mode status | Returns `true` (Always valid) | Returns `true` | Returns `true` | Returns `true` |
| `disableBatteryOptimization` | Opens ignore battery optimization settings | Opens App Settings | Opens Power & Sleep | Opens Energy Saver | Returns `true` (No-op) |
| `openCustomSetting` | Opens specific activity | **Not Supported** | **Not Supported** | **Not Supported** | **Not Supported** |
| `registerBootCallback` | Uses `BOOT_COMPLETED` trigger | **Not Supported** | Writes to Startup Registry | Registers via `SMAppService` | Writes `-autostart` to `~/.config/autostart/` |
| `startForegroundService` | Starts Foreground Service | **Not Supported** | Returns `false` (No-op) | Returns `false` (No-op) | Returns `false` (No-op) |

## Usage
### AutoStart Permission / Background Refresh
On **Android**, this checks if the device is from a manufacturer known to have aggressive auto-start restrictions and redirects the user to the appropriate settings page.
On **iOS**, this checks if **Background App Refresh** is enabled. If not, it redirects the user to the App Settings page where they can enable it.
On **Windows** and **macOS**, this opens the **Startup Apps** or **Login Items** system settings, where users can toggle your app's startup status.

```dart
import 'package:auto_start_flutter/auto_start_flutter.dart';
// ...

// 1. Check if auto-start permission is available / relevant
// Android: Returns true for Xiaomi, Oppo, Vivo, etc.
// iOS: Returns true if Background App Refresh is available (not restricted).
var isAvailable = await isAutoStartAvailable;

if (isAvailable == true) {
    // 2. Request permission / Open Settings
    // Android: Opens Auto Start settings or App Info.
    // iOS: Opens App Settings.
    // Windows/macOS: Opens Startup Apps / Login Items settings.
    await getAutoStartPermission();
}
```

### Other Features
2. **App Info**: Open the system settings page for the app.
    ```dart
    // Android: Opens App Info
    // iOS: Opens App Settings
    await openAppInfo();
    ```

3. **Device Manufacturer**: Get the device manufacturer.
    ```dart
    String? manufacturer = await getDeviceManufacturer(); 
    // e.g. "Xiaomi", "Apple", "Samsung"
    ```

4. **Custom Settings (Android Only)**: If you know the specific package and activity name for a setting page on a specific device, you can attempt to open it directly.
    ```dart
    // Example: Try opening a specific hidden setting
    await openCustomSetting(
      packageName: 'com.android.settings',
      activityName: 'com.android.settings.Settings\$PowerUsageSummaryActivity',
    );
    ```

### Background Execution & Boot
The plugin provides advanced lifecycle hooks to natively launch your app in the background across platforms.

1. **Boot Completed Trigger (`registerBootCallback`)**: Run a headless Dart callback or launch your app the moment the device turns on.
    * **Android**: Uses the `BOOT_COMPLETED` intent and spawns a secure background `FlutterEngine`.
    * **Windows**: Natively writes the executable path with an `--autostart` flag directly into the `HKCU\Software\Microsoft\Windows\CurrentVersion\Run` registry.
    * **macOS**: Uses the modern Apple `SMAppService.mainApp.register()` API to register the application into Login Items seamlessly (macOS 13+).
    * **Linux**: Generates a standardized X-GNOME `.desktop` file natively inside `~/.config/autostart/`.

    ```dart
    import 'dart:ui';
    import 'package:flutter/material.dart';

    // 1. Must be a top-level or static function
    @pragma('vm:entry-point')
    void myBootCallback() {
      WidgetsFlutterBinding.ensureInitialized();
      print("Device booted! Running in the background...");
    }

    // 2. Register it somewhere in your app (e.g. main.dart)
    await registerBootCallback(myBootCallback);
    ```
    *Note: On Android, you must manually add the `RECEIVE_BOOT_COMPLETED` permission to your `AndroidManifest.xml` (see Mandatory Setup below).*

2. **Foreground Service Keep-Alive (Android)**: Start a foreground service to prevent Android from killing your app when it goes to the background. This will pin a persistent notification to the user's status bar.
    ```dart
    // Start the service
    await startForegroundService(
      title: "Syncing Data",
      content: "Do not close the app.",
    );

    // Stop the service when done
    await stopForegroundService();
    ```
    *Note: On Android, you must manually add the `FOREGROUND_SERVICE` permission to your `AndroidManifest.xml` (see Mandatory Setup below).*

### Battery Optimization (Android & Windows)
Android's Doze mode and App Standby can restrict background processing. On Windows, power settings can similarly affect background performance. On iOS, this API returns `true` (disabled) to maintain API compatibility.


1. **Check Status**: Check if your app is already ignoring battery optimizations.
    ```dart
    bool isExempt = await isBatteryOptimizationDisabled ?? false;
    print("Battery Optimization Disabled: $isExempt");
    ```

2. **Request Exemption**: On Android 6.0+, this will trigger a direct system dialog asking the user to unrestrict your app's battery usage. On other platforms, it may open the system settings.
    ```dart
    if (!isExempt) {
      await disableBatteryOptimization();
    }
    ```

## Platform Support
| Platform | Supported | Notes |
|----------|-----------|-------|
| Android  | ✅         | Supports custom OEM intents and standard battery optimization settings. |
| iOS      | ✅         | Checks `UIBackgroundRefreshStatus` and opens App Settings. |
| Windows  | ✅         | Opens Startup Apps settings. |
| macOS    | ✅         | Opens Login Items settings. |
| Linux    | ✅         | Basic support. Most methods return logical defaults as DE APIs vary wildly. |

> **Note**: Standard Android APIs do not allow checking if "Auto Start" is actually enabled. `isAutoStartAvailable` only returns `true` if the device manufacturer is on the supported list (e.g. Xiaomi, Oppo). On Windows and macOS, `isAutoStartAvailable` returns `true` to indicate that the "Startup Apps" / "Login Items" setting is accessible. Only iOS allows verifying the actual background refresh status programmatically.

## Mandatory Setup (Android)
To keep the plugin lightweight and privacy-focused, permissions are no longer included by default. You must add the permissions required for the features you intend to use to your `android/app/src/main/AndroidManifest.xml`.

### 1. Boot Completed Trigger
Required for `registerBootCallback`.
```xml
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
```

### 2. Foreground Service
Required for `startForegroundService`.
```xml
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
<!-- For Android 14+ -->
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_SPECIAL_USE" />
```

### 3. Exact Scheduling & Alarms (Phase 2)
Required for `scheduleTask`.
```xml
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
<!-- For Android 13+ -->
<uses-permission android:name="android.permission.USE_EXACT_ALARM" />
```

### 4. Battery Optimization Exemption
Required for `disableBatteryOptimization`.
```xml
<uses-permission android:name="android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS" />
```

## Contributing
If you find any issues or would like to add support for more devices, please file an issue or pull request on GitHub.
