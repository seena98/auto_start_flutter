#include "auto_start_flutter_plugin.h"

// #include <windows.h> // Already included by
// flutter/plugin_registrar_windows.h indirectly, but good to be explicit for
// ShellExecute if needed
#include <shellapi.h>

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <memory>
#include <sstream>

namespace auto_start_flutter {

// static
void AutoStartFlutterPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows *registrar) {
  auto channel =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          registrar->messenger(), "auto_start_flutter",
          &flutter::StandardMethodCodec::GetInstance());

  auto plugin = std::make_unique<AutoStartFlutterPlugin>();

  channel->SetMethodCallHandler(
      [plugin_pointer = plugin.get()](const auto &call, auto result) {
        plugin_pointer->HandleMethodCall(call, std::move(result));
      });

  registrar->AddPlugin(std::move(plugin));
}

AutoStartFlutterPlugin::AutoStartFlutterPlugin() {}

AutoStartFlutterPlugin::~AutoStartFlutterPlugin() {}

void AutoStartFlutterPlugin::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  if (method_call.method_name().compare("getAutoStartPermission") == 0) {
    // Open Windows Startup Settings
    // URI scheme: ms-settings:startupapps
    ShellExecute(0, 0, L"ms-settings:startupapps", 0, 0, SW_SHOW);
    result->Success();
  } else if (method_call.method_name().compare("isAutoStartAvailable") == 0) {
    // Windows generally supports managing startup apps via settings
    result->Success(flutter::EncodableValue(true));
  } else if (method_call.method_name().compare("getDeviceManufacturer") == 0) {
    result->Success(flutter::EncodableValue("Microsoft"));
  } else if (method_call.method_name().compare(
                 "isBatteryOptimizationDisabled") == 0) {
    // Not strictly applicable to Windows in the same way as Android Doze,
    // but returning true (optimization disabled/ignored) is a safe default for
    // compatibility.
    result->Success(flutter::EncodableValue(true));
  } else if (method_call.method_name().compare("disableBatteryOptimization") ==
             0) {
    // Create a dummy result for compatibility
    ShellExecute(0, 0, L"ms-settings:powersleep", 0, 0, SW_SHOW);
    result->Success();
  } else if (method_call.method_name().compare("openAppInfo") == 0) {
    ShellExecute(0, 0, L"ms-settings:appsfeatures-app", 0, 0, SW_SHOW);
    result->Success();
  } else {
    result->NotImplemented();
  }
}

} // namespace auto_start_flutter

void AutoStartFlutterPluginRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  auto_start_flutter::AutoStartFlutterPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
