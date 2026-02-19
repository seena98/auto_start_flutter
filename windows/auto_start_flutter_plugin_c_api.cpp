#include "include/auto_start_flutter/auto_start_flutter_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "auto_start_flutter_plugin.h"

void AutoStartFlutterPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  auto_start_flutter::AutoStartFlutterPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
