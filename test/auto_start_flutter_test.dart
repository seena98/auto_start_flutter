// ignore_for_file: deprecated_member_use_from_same_package

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:auto_start_flutter/auto_start_flutter.dart';

@pragma('vm:entry-point')
void topLevelCallback() {}

/// Fake platform used to verify the public API delegates through
/// [AutoStartFlutterPlatform] and handles failures.
class FakePlatform extends AutoStartFlutterPlatform {
  Object? error;
  bool openResult = true;
  final scheduled = <(int, int, String)>[];
  final cancelled = <String>[];
  bool completed = false;

  T _run<T>(T value) {
    if (error != null) throw error!;
    return value;
  }

  @override
  Future<bool?> isAutoStartAvailable() async => _run(true);
  @override
  Future<bool?> openAutoStartSettings() async => _run(openResult);
  @override
  Future<String?> getDeviceManufacturer() async => _run('TestManufacturer');
  @override
  Future<bool?> isBatteryOptimizationDisabled() async => _run(false);
  @override
  Future<bool?> openBatteryOptimizationSettings() async => _run(true);
  @override
  Future<bool?> canScheduleExactAlarms() async => _run(true);
  @override
  Future<bool?> openExactAlarmSettings() async => _run(true);
  @override
  Future<void> openAppInfo() async => _run(null);
  @override
  Future<void> disableBatteryOptimization() async => _run(null);
  @override
  Future<bool?> registerBootCallback(int callbackHandle) async => _run(true);
  @override
  Future<bool?> scheduleTask(int ts, int handle, String id) async {
    _run(null);
    scheduled.add((ts, handle, id));
    return true;
  }

  @override
  Future<bool?> cancelTask(String taskId) async {
    cancelled.add(taskId);
    return _run(true);
  }

  @override
  Future<List<String>?> getScheduledTaskIds() async => _run(['x']);
  @override
  Future<Map<dynamic, dynamic>?> getLaunchArguments() async =>
      _run({'taskId': 't'});
  @override
  Future<bool?> executeInBackground(int callbackHandle) async => _run(true);
  @override
  Future<void> completeBackgroundTask() async {
    completed = true;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakePlatform fake;
  late AutoStartFlutterPlatform original;

  setUp(() {
    original = AutoStartFlutterPlatform.instance;
    fake = FakePlatform();
    AutoStartFlutterPlatform.instance = fake;
  });

  tearDown(() => AutoStartFlutterPlatform.instance = original);

  group('AutoStart', () {
    test('delegates to the platform', () async {
      expect(await AutoStart.isAutoStartSettingsAvailable(), true);
      expect(await AutoStart.openAutoStartSettings(), SettingsResult.opened);
      expect(await AutoStart.getManufacturer(), 'TestManufacturer');
      expect(await AutoStart.isBatteryOptimizationDisabled(), false);
      expect(await AutoStart.openBatteryOptimizationSettings(),
          SettingsResult.opened);
      expect(await AutoStart.requestIgnoreBatteryOptimization(),
          SettingsResult.opened);
      expect(await AutoStart.openAppInfo(), SettingsResult.opened);
      expect(await AutoStart.canScheduleExactAlarms(), true);
      expect(await AutoStart.openExactAlarmSettings(), SettingsResult.opened);
      expect(await AutoStart.getLaunchArguments(), {'taskId': 't'});
      expect(await AutoStart.getScheduledTaskIds(), ['x']);
    });

    test('settings that cannot be opened report notAvailable', () async {
      fake.openResult = false;
      expect(
          await AutoStart.openAutoStartSettings(), SettingsResult.notAvailable);
    });

    group('unsupported platform (MissingPluginException)', () {
      setUp(() => fake.error = MissingPluginException());

      test('every call returns a safe value instead of throwing', () async {
        expect(await AutoStart.isAutoStartSettingsAvailable(), false);
        expect(await AutoStart.isBatteryOptimizationDisabled(), isNull);
        expect(await AutoStart.getManufacturer(), isNull);
        expect(await AutoStart.openAutoStartSettings(),
            SettingsResult.unsupported);
        expect(await AutoStart.openAppInfo(), SettingsResult.unsupported);
        expect(await AutoStart.getLaunchArguments(), isEmpty);
        expect(await AutoStart.getScheduledTaskIds(), isEmpty);
        expect(await AutoStart.scheduleTask(DateTime.now(), topLevelCallback),
            ScheduleResult.unsupported);
      });

      test('exact alarms are considered available', () async {
        expect(await AutoStart.canScheduleExactAlarms(), true);
      });
    });

    test('PlatformException maps to failed / exactAlarmDenied', () async {
      fake.error = PlatformException(code: 'OTHER');
      expect(await AutoStart.canScheduleExactAlarms(), false);
      expect(await AutoStart.openAutoStartSettings(), SettingsResult.failed);
      expect(await AutoStart.scheduleTask(DateTime.now(), topLevelCallback),
          ScheduleResult.failed);

      fake.error = PlatformException(code: 'EXACT_ALARM_DENIED');
      expect(await AutoStart.scheduleTask(DateTime.now(), topLevelCallback),
          ScheduleResult.exactAlarmDenied);
    });

    group('callbacks', () {
      test('non top-level callbacks are rejected', () async {
        expect(await AutoStart.registerBootCallback(() {}), false);
        expect(await AutoStart.scheduleTask(DateTime.now(), () {}),
            ScheduleResult.invalidCallback);
        expect(fake.scheduled, isEmpty);
      });

      test('top-level callbacks are registered', () async {
        expect(await AutoStart.registerBootCallback(topLevelCallback), true);
      });
    });

    group('scheduleTask / cancelTask', () {
      test('passes timestamp and explicit task id', () async {
        final at = DateTime.fromMillisecondsSinceEpoch(123456);
        expect(
            await AutoStart.scheduleTask(at, topLevelCallback, taskId: 'mine'),
            ScheduleResult.scheduled);
        expect(fake.scheduled.single.$1, 123456);
        expect(fake.scheduled.single.$3, 'mine');
      });

      test('generated ids are unique', () async {
        final at = DateTime.now();
        await AutoStart.scheduleTask(at, topLevelCallback);
        await AutoStart.scheduleTask(at, topLevelCallback);
        expect(fake.scheduled[0].$3, isNot(fake.scheduled[1].$3));
      });

      test('cancelTask forwards the id', () async {
        expect(await AutoStart.cancelTask('mine'), true);
        expect(fake.cancelled, ['mine']);
      });
    });

    test('completeBackgroundTask reaches the platform', () async {
      await AutoStart.completeBackgroundTask();
      expect(fake.completed, true);
    });

    test('getStatus aggregates the individual checks', () async {
      expect(
          await AutoStart.getStatus(),
          const BackgroundStatus(
            manufacturer: 'TestManufacturer',
            isAutoStartAvailable: true,
            isBatteryOptimizationDisabled: false,
            canScheduleExactAlarms: true,
          ));
    });
  });

  group('deprecated top-level API keeps working', () {
    test('delegates to the platform', () async {
      expect(await isAutoStartAvailable, true);
      expect(await getAutoStartPermission(), true);
      expect(await getDeviceManufacturer(), 'TestManufacturer');
      expect(await isBatteryOptimizationDisabled, false);
      expect(await openBatteryOptimizationSettings(), true);
      expect(await canScheduleExactAlarms(), true);
      expect(await openExactAlarmSettings(), true);
      expect(await getLaunchArguments(), {'taskId': 't'});
      await openAppInfo();
      await disableBatteryOptimization();
    });

    test('keeps the bool-based contract', () async {
      expect(await registerBootCallback(topLevelCallback), true);
      expect(await scheduleTask(DateTime.now(), topLevelCallback), true);
      expect(await scheduleTask(DateTime.now(), () {}), false);

      fake.error = MissingPluginException();
      expect(await getAutoStartPermission(), false);
      expect(await isAutoStartAvailable, false);
      expect(await scheduleTask(DateTime.now(), topLevelCallback), false);
    });
  });
}
