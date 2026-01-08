import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:auto_start_flutter/auto_start_flutter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _batteryOptimizationStatus = "Unknown";
  String _manufacturer = "Unknown";

  @override
  void initState() {
    super.initState();
    initAutoStart();
    _getManufacturer();
  }

  Future<void> _getManufacturer() async {
    String? manufacturer = await getDeviceManufacturer();
    if (manufacturer != null) {
      setState(() {
        _manufacturer = manufacturer;
      });
    }
  }

  //initializing the autoStart with the first build.
  Future<void> initAutoStart() async {
    try {
      //check auto-start availability.
      var isAvailable = (await isAutoStartAvailable) ?? false;
      print("Auto start available: $isAvailable");
      //if available then navigate to auto-start setting page.
      if (isAvailable) {
         bool success = await getAutoStartPermission();
         print("Auto start permission open success: $success");
      }
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
  
  Future<void> _openAutoStart() async {
    bool success = await getAutoStartPermission();
    if (!success) {
      // Now this context is below MaterialApp, so ScaffoldMessenger works.
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Could not open Auto-Start settings directly.")));
    }
  }

  Future<void> _openAppInfo() async {
    await openAppInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Auto Start Flutter Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Manufacturer: $_manufacturer"),
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
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _openAutoStart,
              child: Text("Open Auto Start Settings"),
            ),
            ElevatedButton(
              onPressed: _openAppInfo,
              child: Text("Open App Info"),
            ),
          ],
        ),
      ),
    );
  }
}
