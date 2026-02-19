import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:auto_start_flutter/auto_start_flutter.dart';

void main() {
  const MethodChannel channel = MethodChannel('com.techflow.co/auto_start_flutter');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        switch (methodCall.method) {
          case 'isAutoStartPermission':
            return true;
          case 'permit-auto-start':
            return true;
          case 'getDeviceManufacturer':
            return 'TestManufacturer';
          case 'isBatteryOptimizationDisabled':
            return false;
          case 'disableBatteryOptimization':
            return null;
          case 'openAppInfo':
            return null;
          default:
            return null;
        }
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('isAutoStartAvailable', () async {
    expect(await isAutoStartAvailable, true);
  });

  test('getAutoStartPermission', () async {
    expect(await getAutoStartPermission(), true);
  });

  test('getDeviceManufacturer', () async {
    expect(await getDeviceManufacturer(), 'TestManufacturer');
  });

  test('isBatteryOptimizationDisabled', () async {
    expect(await isBatteryOptimizationDisabled, false);
  });
}
