# auto_start_flutter

A Flutter plugin to help manage background execution permissions on Android devices. It supports requesting "Auto-Start" permissions on specific OEM devices (Xiaomi, Oppo, Vivo, etc.) and managing battery optimization settings to ensure your app can run reliably in the background.

## Features

- **Auto-Start Permission**: Open the manufacturer-specific "Auto-Start" or "App Launch" settings.
- **Battery Optimization**: Check if the app is exempt from battery optimizations and open settings to request exemption.
- **Device Support**: targeted support for Xiaomi, Redmi, Poco, Oppo, Vivo, Huawei, Honor, Samsung, ASUS, OnePlus, Nokia, LeTV, Meizu, HTC, Infinix, and more.
- **Robustness**: The plugin attempts multiple known intents for each manufacturer to ensure the settings page opens correctly.

[![pub package](https://img.shields.io/pub/v/http.svg)](https://pub.dev/packages/auto_start_flutter)

## Getting Started

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  auto_start_flutter: ^0.1.7
```

Import the package:
```dart
import 'package:auto_start_flutter/auto_start_flutter.dart';
```

## Usage

### Auto-Start Permission
Many Android manufacturers (Xiaomi, Oppo, Vivo, etc.) have a custom "Auto-Start" permission that prevents apps from starting in the background by default.

1. **Check Availability**: Check if the current device requires this permission.
    ```dart
    bool isAvailable = await isAutoStartAvailable ?? false;
    ```
2. **Request Permission**: If available, navigate the user to the settings page.
    ```dart
    if (isAvailable) {
      await getAutoStartPermission();
    }
    ```

### Battery Optimization
Android's Doze mode and App Standby can restrict background processing. Disabling battery optimizations for your app can help ensure background services (like Alarms or WorkManager) run on time.

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
| iOS      | ❌         | Not applicable. |

## contributing
If you find any issues or would like to add support for more devices, please file an issue or pull request on GitHub.
