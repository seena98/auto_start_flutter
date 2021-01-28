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
  @override
  void initState() {
    super.initState();
    initAutoStart();
  }

  Future<void> initAutoStart() async {
    try {
      var test = await AutoStartFlutter.isAutoStartAvailable;
      print(test);
      if (test) await AutoStartFlutter.getAutoStartPermission();
    } on PlatformException catch (e) {
      print(e);
    }
    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Auto Start Flutter Example'),
        ),
        body: Center(
          child: Text("Auto Start initialize..."),
        ),
      ),
    );
  }
}
