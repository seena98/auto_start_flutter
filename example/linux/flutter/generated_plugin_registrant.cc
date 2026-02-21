//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <auto_start_flutter/auto_start_flutter_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) auto_start_flutter_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "AutoStartFlutterPlugin");
  auto_start_flutter_plugin_register_with_registrar(auto_start_flutter_registrar);
}
