#ifndef FLUTTER_PLUGIN_AUTO_START_FLUTTER_PLUGIN_IMPL_H_
#define FLUTTER_PLUGIN_AUTO_START_FLUTTER_PLUGIN_IMPL_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <memory>

namespace auto_start_flutter {

class AutoStartFlutterPlugin : public flutter::Plugin {
public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  AutoStartFlutterPlugin();

  virtual ~AutoStartFlutterPlugin();

  // Disallow copy and assign.
  AutoStartFlutterPlugin(const AutoStartFlutterPlugin &) = delete;
  AutoStartFlutterPlugin &operator=(const AutoStartFlutterPlugin &) = delete;

private:
  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

} // namespace auto_start_flutter

#endif // FLUTTER_PLUGIN_AUTO_START_FLUTTER_PLUGIN_IMPL_H_
