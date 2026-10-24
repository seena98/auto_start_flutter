## 1.6.0
* **New API**: `AutoStart` class with consistent names and richer results. Methods that open settings return `SettingsResult` (`opened`, `notAvailable`, `unsupported`, `failed`) and `AutoStart.scheduleTask` returns `ScheduleResult` (`scheduled`, `exactAlarmDenied`, `invalidCallback`, `unsupported`, `failed`). Nothing throws.
* **Deprecated (still working)**: every original top-level function (`getAutoStartPermission`, `isAutoStartAvailable`, `scheduleTask`, ...) is now `@Deprecated` and delegates to `AutoStart`, with the same signatures and `bool` results, so existing code keeps compiling. See the README migration table.
* **Feature**: `AutoStart.cancelTask(taskId)` and `AutoStart.getScheduledTaskIds()` on Android, iOS, macOS, Linux and Windows (`getScheduledTaskIds` enumerates Task Scheduler entries).
* **Feature (Android)**: Scheduled tasks are persisted and restored after reboot; tasks that came due while the device was off run on boot.
* **Feature**: `AutoStart.completeBackgroundTask()` releases a headless engine when the callback finishes.
* **Feature**: `AutoStart.getStatus()` returns a `BackgroundStatus` snapshot (manufacturer, auto-start, battery optimization, exact alarms).
* **Fix**: All calls go through `AutoStartFlutterPlatform` (previously a dead template layer on a different channel name), so the plugin can be faked in tests.
* **Fix**: Consistent error handling. Unsupported platforms no longer throw; `canScheduleExactAlarms` fails closed on real errors.
* **Fix (Android)**: Headless Flutter engines are destroyed (on `completeBackgroundTask()` or after 5 minutes) instead of leaking, and `goAsync()` plus an optional wake lock (only used if your app declares `WAKE_LOCK`; the plugin declares no permissions) keep the process alive while the Dart callback runs from the boot/alarm receivers.
* **Fix (Android)**: Exact alarm denial on Android 12+ is reported as `EXACT_ALARM_DENIED`; task ids no longer collide; `disableBatteryOptimization` no longer crashes when no activity can handle the intent.
* **Fix (Linux)**: Scheduled timers are now enabled via `systemctl --user` and use UTC consistently.
* **Fix (desktop)**: `executeInBackground` spawns the isolate through a top-level entry point and initialises the background binary messenger, so plugins that support background isolates now work inside the callback.
* **Fix (iOS)**: Headless engines started by `executeInBackground` now have this plugin attached, so `completeBackgroundTask()` releases them.
* **Tooling**: Raised SDK constraints to Dart 3.6 / Flutter 3.10, enabled `strict-casts`, `strict-raw-types` and `public_member_api_docs`, expanded tests, and moved the example to the new API.
* **Note**: the Android, iOS and macOS builds were verified; the Windows and Linux native additions could not be compiled in the development environment, so please verify them on those platforms.

## 1.5.0
* **Feature (Exact Alarms - Android 12+)**: Added `canScheduleExactAlarms()` and `openExactAlarmSettings()` APIs to check and navigate to system "Alarms & reminders" settings for exact background alarms.
* **Feature (Google Play Policy Compliant Battery Settings)**: Added `openBatteryOptimizationSettings()` navigating to the standard system battery optimization screen (`ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS`), providing a 100% Google Play policy-safe alternative to direct dialog prompts.
* **Android**: Bumped Android Gradle Plugin to 8.11.1 and Kotlin Gradle plugin to 2.2.20 (Flutter's current minimums); the plugin applies `kotlin-android` and uses `jvmToolchain(17)`.
* **Android**: Example app now uses Gradle 8.14 and sets `android.newDsl=false` to stay compatible with AGP 9 DSL changes.
* **Android**: Removed obsolete `jcenter()` repository from Gradle configuration.
* **Android**: Removed deprecated `package` attribute from `AndroidManifest.xml`.
* **Android**: Added ColorOS / Oppo auto-start manager intents for Realme devices.
* **Android**: Implemented missing `getPlatformVersion` handler and verified Android unit tests.
* **Cross-Platform**: Gracefully supported `openBatteryOptimizationSettings` across iOS, macOS, Windows, and Linux.
* **Core**: Added `!kIsWeb` safeguards to prevent `UnsupportedError` when running in web-enabled Flutter projects.
* **Example App**: Updated with interactive status checks and UI buttons for exact alarm management and policy-safe battery optimization settings.
* **CI**: Build example APK with `--android-skip-build-dependency-validation` so builds pass on modern Flutter toolchains.
* **Tests**: Added unit tests covering `canScheduleExactAlarms`, `openExactAlarmSettings`, and `openBatteryOptimizationSettings`.

## 1.4.0
* **Major Feature (Phase 3)**: Added `executeInBackground` API for immediate, headless execution of Dart callbacks without attaching a UI.
    * **Android**: Leverages a dedicated headless `FlutterEngine` to run background tasks efficiently without disruption.
    * **iOS**: Leverages a secondary natively-isolated `FlutterEngine` via `FlutterCallbackCache` to run tasks headlessly.
    * **macOS/Windows/Linux**: Implemented highly efficient background execution using Dart's native `Isolate.spawn` API natively.
* **Refactor**: Replaced desktop background process cloning with native Dart isolates to improve RAM efficiency, reduce duplicate application instances in desktop environments, and fix compiler warnings on macOS edge cases.
* **Documentation Update**: Outlined `executeInBackground` behavior and required permission contexts for Phase 3 background tasks.

## 1.3.0
* **Feature (Phase 2 - Apple)**: Added `scheduleTask` implementation for iOS and macOS natively using `UNUserNotificationCenter` for precise local notifications.
* **Feature (Phase 2 - Apple)**: Implemented `getLaunchArguments` for iOS and macOS to capture notification payloads when the app receives a scheduled task trigger.
* **Improvement**: Updated Example App with a native interactive time picker to properly demonstrate exact scheduling across supported platforms.

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





