# auto_start_flutter

A flutter plugin for enabling auto-start for background services in 
 samsung, honor, huawei, xiaomi, oppo, asus etc. phones.
The plugin redirects the user to auto-start permission screen to allow auto-start and fix
background problems in some phones.
## Getting Started

Import the package.

import 'package:auto_start_flutter/auto_start_flutter.dart';


Use the extension methods

to get the permission

getAutoStartPermission();

to check if auto-start is available in your phone.

isAutoStartAvailable

