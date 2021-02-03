# auto_start_flutter

A flutter plugin for enabling auto-start for background services in 
 samsung, honor, huawei, xiaomi, oppo, asus etc. phones.
The plugin redirects the user to auto-start permission screen to allow auto-start and fix
background problems in some phones.

[![pub package](https://img.shields.io/pub/v/http.svg)](https://pub.dev/packages/auto_start_flutter)

## Getting Started

Note: This Plugin is not implemented for IOS Devices.

** If there's any issue with the plugin make an issue on github.

Import the `auto_start_flutter` package.
```dart
import 'package:auto_start_flutter/auto_start_flutter.dart';
```


To Navigate to auto-start screen and get the permission put this in init-state of your first screen.
```dart
getAutoStartPermission();
```
To check if auto-start is available in your phone this function returns a bool.
```dart
isAutoStartAvailable
```
