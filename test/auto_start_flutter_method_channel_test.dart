import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:auto_start_flutter/auto_start_flutter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final platform = MethodChannelAutoStartFlutter();
  final calls = <MethodCall>[];

  setUp(() {
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(platform.methodChannel, (call) async {
      calls.add(call);
      if (call.method == 'getScheduledTaskIds') return <Object?>['a', 'b'];
      if (call.method == 'getPlatformVersion') return '42';
      return true;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(platform.methodChannel, null);
  });

  test('uses the channel name the native side registers', () {
    expect(platform.methodChannel.name, 'com.techflow.co/auto_start_flutter');
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });

  test('scheduleTask sends timestamp, handle and id', () async {
    await platform.scheduleTask(1000, 7, 'id');
    expect(calls.single.method, 'scheduleTask');
    expect(calls.single.arguments,
        {'timestamp': 1000, 'callbackHandle': 7, 'taskId': 'id'});
  });

  test('cancelTask sends the id', () async {
    await platform.cancelTask('id');
    expect(calls.single.arguments, {'taskId': 'id'});
  });

  test('getScheduledTaskIds casts to strings', () async {
    expect(await platform.getScheduledTaskIds(), ['a', 'b']);
  });
}
