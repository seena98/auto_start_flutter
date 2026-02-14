# auto_start_flutter

A Flutter plugin to help manage background execution permissions on Android and iOS devices. It supports requesting "Auto-Start" permissions on specific Android OEM devices and checking "Background App Refresh" status on iOS to ensure your app can run reliably in the background.

## Features

- **Auto-Start Permission**: Open the manufacturer-specific "Auto-Start" or "App Launch" settings.
- **Battery Optimization**: Check if the app is exempt from battery optimizations and open settings to request exemption.
- **Device Support**: targeted support for Xiaomi, Redmi, Poco, Oppo, Vivo, Huawei, Honor, Samsung, ASUS, OnePlus, Nokia, LeTV, Meizu, HTC, Infinix, and more.
- **Robustness**: The plugin attempts multiple known intents for each manufacturer to ensure the settings page opens correctly.

[![pub package](https://img.shields.io/pub/v/auto_start_flutter.svg)](https://pub.dev/packages/auto_start_flutter)

## Getting Started

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  auto_start_flutter: ^0.4.2
```

Import the package:
```dart
import 'package:auto_start_flutter/auto_start_flutter.dart';
```

## Platform Support

| Feature | Android | iOS |
| --- | --- | --- |
| `isAutoStartAvailable` | Checks manufacturer whitelist | Checks `UIBackgroundRefreshStatus` |
| `getAutoStartPermission` | Opens Auto Start / App Info | Opens App Settings |
| `openAppInfo` | Opens App Info | Opens App Settings |
| `getDeviceManufacturer` | Returns `Build.MANUFACTURER` | Returns "Apple" |
| `isBatteryOptimizationDisabled` | Checks doze mode status | Returns `true` (Always valid) |
| `disableBatteryOptimization` | Opens ignore battery optimization settings | Opens App Settings |
| `openCustomSetting` | Opens specific activity | **Not Supported** |

## Usage
### AutoStart Permission / Background Refresh
On **Android**, this checks if the device is from a manufacturer known to have aggressive auto-start restrictions and redirects the user to the appropriate settings page.
On **iOS**, this checks if **Background App Refresh** is enabled. If not, it redirects the user to the App Settings page where they can enable it.

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

### Battery Optimization (Android)
Android's Doze mode and App Standby can restrict background processing. On iOS, this API returns `true` for "disabled" (meaning good to go) and opens settings if requested, to maintain API compatibility.


1. **Check Status**: Check if your app is already ignoring battery optimizations.
    ```dart
    bool isExempt = await isBatteryOptimizationDisabled ?? false;
    print("Battery Optimization Disabled: $isExempt");
    ```

2. **Open Settings**: If not exempt, open the "Ignore Battery Optimization" settings to let the user allow your app.
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

## Contributing
If you find any issues or would like to add support for more devices, please file an issue or pull request on GitHub.
