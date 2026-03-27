## 1.2.0
* **Improvement (Android)**: Refined `isAutoStartPermission` logic to query actual intent resolution via Package Manager, ensuring more accurate availability reporting.
* **Fix (Windows)**: Resolved linker errors (`LNK2001`) and narrowing conversion warnings (`C4244`).
* **Fix (Linux)**: Resolved undeclared identifier in the plugin implementation.
* **Fix (Android)**: Resolved missing `Log` import.

## 1.1.0
* **Feature (Phase 2)**: Added `scheduleTask` API to schedule top-level Dart callbacks at specific times.
    * **Android**: Integrated with `AlarmManager` for exact alarms even in Doze mode.
    * **Windows**: Integrated with **Windows Task Scheduler** via COM API.
    * **Linux**: Integrated with **Systemd Timers** natively.
* **Feature**: Added `getLaunchArguments` to detect if the app was woke up by a task or boot.
* **Breaking Change (Opt-in Permissions)**: Removed all default permissions from the library manifest. Developers must now manually add permissions (e.g., `RECEIVE_BOOT_COMPLETED`, `SCHEDULE_EXACT_ALARM`) to their own `AndroidManifest.xml`.
* **Improvement**: Enhanced headless engine initialization for more reliable background triggers.

## 1.0.0
* **Major Release: The "Background Super-Plugin" Update!**
* **Feature (Phase 1)**: Added `registerBootCallback` API for Android, Windows, macOS, and Linux to run headless Dart code or launch your app when the device boots up.
    * **Android**: Uses `BOOT_COMPLETED` intent and spawns a secure background Flutter Engine.
    * **Windows**: Modifies Startup Registry.
    * **macOS**: Uses `SMAppService` to register Login Items natively.
    * **Linux**: Generates standardized Autostart `.desktop` files.
* **Feature**: Added `startForegroundService` and `stopForegroundService` APIs for Android to stick a persistent keep-alive notification in the status bar.
* **Feature**: Upgraded Android `disableBatteryOptimization` to use the `ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` direct system dialog prompt instead of jumping into settings.
* Example app updated with UI buttons to cleanly test all Phase 1 capabilities natively.

## 0.7.0
* Implemented native C++ unit tests for Windows and Linux to enhance stability.
* Updated CI/CD workflow to verify builds and test binaries on Linux runners.
* Added Swift Package Manager (SPM) support for macOS to resolve pub.dev analyzer warnings.

## 0.6.0
* Major release including Windows and macOS support.
* Comprehensive documentation updates.
* Cross-platform CI/CD.

## 0.5.2
* Comprehensively updated README for Windows support.

## 0.5.1
* Updated platform support table in README.

## 0.5.0
* **Feature**: Added Windows support.
* **Feature**: Added GitHub Actions for cross-platform CI/CD.
* Restructured iOS plugin for improved Swift Package Manager support.
* Updated README to clarify platform limitations regarding checking "enabled" status.

## 0.4.3
* Fixed Swift Package Manager (SPM) support configuration.

## 0.4.2
* Added Swift Package Manager (SPM) support for iOS.

## 0.4.1
* Updated README to accurately reflect iOS support.

## 0.4.0
* **iOS Support**: Added support for iOS.
    * `isAutoStartAvailable`: Checks `UIBackgroundRefreshStatus`.
    * `getAutoStartPermission`: Opens App Settings.
    * `getDeviceManufacturer`: Returns "Apple".
* Updated documentation to reflect cross-platform behavior.

## 0.3.0
* Added `openCustomSetting` API to open specific settings by package and activity name.
* Added support for Lenovo and ZTE/Nubia devices.

## 0.2.1
* Added specific intents for Honor devices (`com.hihonor.systemmanager`).

## 0.2.0
* **Breaking Change**: Migrated Android plugin to Kotlin. Ensure your project supports Kotlin.
* `getAutoStartPermission` now returns `Future<bool>` indicating if the settings page was successfully opened.
* Added `openAppInfo` method as a fallback to open system App Info settings.
* Added `getDeviceManufacturer` method to identify the device manufacturer.
* Added support for Transsion devices (Tecno, Infinix, Itel).
* Added support for newer OnePlus devices (ColorOS based).
* Added support for Meizu and Letv.
* Improved intent handling robustness.

## 0.1.7-nullsafety

* Added support for Infinix and OnePlus Ace Devices.

## 0.1.6-nullsafety

* Added Battery Optimization support and refined auto start process for some phones.


## 0.1.5-nullsafety

* Fixed android run issues

## 0.1.4-nullsafety

* Fixed android run issues

## 0.1.3-nullsafety

* Added support for huawei, honor, poco, xiaomi, redmi, letv phones

## 0.1.2-nullsafety

* Fixed android runtime problem

## 0.1.1-nullsafety

* Fixed IOS runtime problem

## 0.1.0-nullsafety

* added support for null safety

## 0.0.8-nullsafety

* added support for null safety

## 0.0.7-nullsafety.0

* added support for null safety

## 0.0.6

* added support for RealMe Phones.

## 0.0.5

* fixed plugin calling problems and deleted static values.

## 0.0.4

* fixed homepage link and documentation.

## 0.0.3

* fixed homepage link.

## 0.0.2

* fixed documentation problems.

## 0.0.1

* It's the initial release.





