import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:auto_start_flutter/auto_start_flutter.dart';

@pragma('vm:entry-point')
void myBootCallback() {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint("Boot Callback execution triggered! The device just booted.");
}

@pragma('vm:entry-point')
void myScheduledTaskCallback() {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint("Scheduled Task execution triggered! Running headlessly.");
}

void main() {
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _batteryOptimizationStatus = "Unknown";
  String _manufacturer = "Unknown";
  String _launchArgs = "None";

  @override
  void initState() {
    super.initState();
    initAutoStart();
    _getManufacturer();
    _checkLaunchArgs();
  }

  Future<void> _checkLaunchArgs() async {
    final args = await getLaunchArguments();
    if (args.isNotEmpty) {
      setState(() {
        _launchArgs = args.toString();
      });
      debugPrint("App launched with arguments: $args");
    }
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
      debugPrint("Auto start available: $isAvailable");
      //if available then navigate to auto-start setting page.
      if (isAvailable) {
         bool success = await getAutoStartPermission();
         debugPrint("Auto start permission open success: $success");
      }
    } on PlatformException catch (e) {
      debugPrint(e.toString());
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
      if (!mounted) return;
      // Now this context is below MaterialApp, so ScaffoldMessenger works.
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Could not open Auto-Start settings directly.")));
    }
  }

  Future<void> _openAppInfo() async {
    await openAppInfo();
  }

  final TextEditingController _packageNameController = TextEditingController();
  final TextEditingController _activityNameController = TextEditingController();

  @override
  void dispose() {
    _packageNameController.dispose();
    _activityNameController.dispose();
    super.dispose();
  }

  Future<void> _openCustomSetting() async {
    if (_packageNameController.text.isEmpty || _activityNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please enter both package and activity names")));
      return;
    }
    bool success = await openCustomSetting(
      packageName: _packageNameController.text,
      activityName: _activityNameController.text,
    );
    if (!success) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to open custom setting")));
    }
  }

  Future<void> _testRegisterBootCallback() async {
    bool success = await registerBootCallback(myBootCallback);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Boot Callback Registered: $success")));
  }

  Future<void> _testStartForegroundService() async {
    bool success = await startForegroundService(
      title: "Example Foreground Service",
      content: "This prevents the app from being killed.",
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Started Foreground Service: $success")));
  }

  Future<void> _testStopForegroundService() async {
    bool success = await stopForegroundService();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Stopped Foreground Service: $success")));
  }

  Future<void> _testScheduleTask() async {
    // Schedule task for 1 minute from now
    final at = DateTime.now().add(Duration(minutes: 1));
    bool success = await scheduleTask(at, myScheduledTaskCallback, taskId: "test_task_1");
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Task Scheduled for 1 min from now: $success")));
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Auto Start Flutter Example'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Manufacturer: $_manufacturer"),
              SizedBox(height: 10),
              Text("Launch Args: $_launchArgs"),
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
              Divider(height: 40),
              Text("Test Custom Intent", style: TextStyle(fontWeight: FontWeight.bold)),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _packageNameController,
                  decoration: InputDecoration(labelText: "Package Name", border: OutlineInputBorder()),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _activityNameController,
                  decoration: InputDecoration(labelText: "Activity Name", border: OutlineInputBorder()),
                ),
              ),
              ElevatedButton(
                onPressed: _openCustomSetting,
                child: Text("Open Custom Setting"),
              ),
              Divider(height: 40),
              Text("Phase 1 Features", style: TextStyle(fontWeight: FontWeight.bold)),
              ElevatedButton(
                onPressed: _testRegisterBootCallback,
                child: Text("Register Boot Callback"),
              ),
              ElevatedButton(
                onPressed: _testStartForegroundService,
                child: Text("Start Foreground Service"),
              ),
              ElevatedButton(
                onPressed: _testStopForegroundService,
                child: Text("Stop Foreground Service"),
              ),
              Divider(height: 40),
              Text("Phase 2 Features", style: TextStyle(fontWeight: FontWeight.bold)),
              ElevatedButton(
                onPressed: _testScheduleTask,
                child: Text("Schedule Task (1 min)"),
              ),
              SizedBox(height: 40),
            ],

          ),
        ),
      ),
    );
  }
}
