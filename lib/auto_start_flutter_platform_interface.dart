import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'auto_start_flutter_method_channel.dart';

abstract class AutoStartFlutterPlatform extends PlatformInterface {
  /// Constructs a AutoStartFlutterPlatform.
  AutoStartFlutterPlatform() : super(token: _token);

  static final Object _token = Object();

  static AutoStartFlutterPlatform _instance = MethodChannelAutoStartFlutter();

  /// The default instance of [AutoStartFlutterPlatform] to use.
  ///
  /// Defaults to [MethodChannelAutoStartFlutter].
  static AutoStartFlutterPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [AutoStartFlutterPlatform] when
  /// they register themselves.
  static set instance(AutoStartFlutterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
