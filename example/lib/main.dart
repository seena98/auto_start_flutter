import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:auto_start_flutter/auto_start_flutter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _batteryOptimizationStatus = "Unknown";

  @override
  void initState() {
    super.initState();
    initAutoStart();
  }

  //initializing the autoStart with the first build.
  Future<void> initAutoStart() async {
    try {
      //check auto-start availability.
      var isAvailable = (await isAutoStartAvailable) ?? false;
      print("Auto start available: $isAvailable");
      //if available then navigate to auto-start setting page.
      if (isAvailable) await getAutoStartPermission();
    } on PlatformException catch (e) {
      print(e);
    }
    if (!mounted) return;
  }

  Future<void> _checkBatteryOptimization() async {
    bool? isDisabled = await isBatteryOptimizationDisabled;
    setState(() {
      _batteryOptimizationStatus =
          isDisabled == true ? "Disabled (Good)" : "Enabled (Bad)";
    });
  }

  Future<void> _disableBatteryOptimization() async {
    await disableBatteryOptimization();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Auto Start Flutter Example'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Auto Start initialize..."),
              SizedBox(height: 20),
              Text("Battery Optimization: $_batteryOptimizationStatus"),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _checkBatteryOptimization,
                child: Text("Check Battery Optimization"),
              ),
              ElevatedButton(
                onPressed: _disableBatteryOptimization,
                child: Text("Disable Battery Optimization"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
