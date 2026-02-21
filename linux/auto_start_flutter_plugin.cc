#include "include/auto_start_flutter/auto_start_flutter_plugin.h"

#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>
#include <sys/utsname.h>

#include <cstring>

#include "auto_start_flutter_plugin_private.h"

#define AUTO_START_FLUTTER_PLUGIN(obj)                                         \
  (G_TYPE_CHECK_INSTANCE_CAST((obj), auto_start_flutter_plugin_get_type(),     \
                              AutoStartFlutterPlugin))

struct _AutoStartFlutterPlugin {
  GObject parent_instance;
};

G_DEFINE_TYPE(AutoStartFlutterPlugin, auto_start_flutter_plugin,
              g_object_get_type())

// Called when a method call is received from Flutter.
static void
auto_start_flutter_plugin_handle_method_call(AutoStartFlutterPlugin *self,
                                             FlMethodCall *method_call) {
  g_autoptr(FlMethodResponse) response = nullptr;

  const gchar *method = fl_method_call_get_name(method_call);

  if (strcmp(method, "permit-auto-start") == 0) {
    response = permit_auto_start();
  } else if (strcmp(method, "isAutoStartPermission") == 0) {
    response = is_auto_start_permission();
  } else if (strcmp(method, "getDeviceManufacturer") == 0) {
    response = get_device_manufacturer();
  } else if (strcmp(method, "disableBatteryOptimization") == 0) {
    response = disable_battery_optimization();
  } else if (strcmp(method, "isBatteryOptimizationDisabled") == 0) {
    response = is_battery_optimization_disabled();
  } else if (strcmp(method, "openAppInfo") == 0) {
    response = open_app_info();
  } else {
    response = FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());
  }

  fl_method_call_respond(method_call, response, nullptr);
}

FlMethodResponse *permit_auto_start() {
  g_autoptr(FlValue) result = fl_value_new_bool(TRUE);
  return FL_METHOD_RESPONSE(fl_method_success_response_new(result));
}

FlMethodResponse *is_auto_start_permission() {
  g_autoptr(FlValue) result = fl_value_new_bool(TRUE);
  return FL_METHOD_RESPONSE(fl_method_success_response_new(result));
}

FlMethodResponse *get_device_manufacturer() {
  g_autoptr(FlValue) result = fl_value_new_string("Linux");
  return FL_METHOD_RESPONSE(fl_method_success_response_new(result));
}

FlMethodResponse *disable_battery_optimization() {
  g_autoptr(FlValue) result = fl_value_new_bool(TRUE);
  return FL_METHOD_RESPONSE(fl_method_success_response_new(result));
}

FlMethodResponse *is_battery_optimization_disabled() {
  g_autoptr(FlValue) result = fl_value_new_bool(TRUE);
  return FL_METHOD_RESPONSE(fl_method_success_response_new(result));
}

FlMethodResponse *open_app_info() {
  g_autoptr(FlValue) result = fl_value_new_bool(TRUE);
  return FL_METHOD_RESPONSE(fl_method_success_response_new(result));
}

static void auto_start_flutter_plugin_dispose(GObject *object) {
  G_OBJECT_CLASS(auto_start_flutter_plugin_parent_class)->dispose(object);
}

static void
auto_start_flutter_plugin_class_init(AutoStartFlutterPluginClass *klass) {
  G_OBJECT_CLASS(klass)->dispose = auto_start_flutter_plugin_dispose;
}

static void auto_start_flutter_plugin_init(AutoStartFlutterPlugin *self) {}

static void method_call_cb(FlMethodChannel *channel, FlMethodCall *method_call,
                           gpointer user_data) {
  AutoStartFlutterPlugin *plugin = AUTO_START_FLUTTER_PLUGIN(user_data);
  auto_start_flutter_plugin_handle_method_call(plugin, method_call);
}

void auto_start_flutter_plugin_register_with_registrar(
    FlPluginRegistrar *registrar) {
  AutoStartFlutterPlugin *plugin = AUTO_START_FLUTTER_PLUGIN(
      g_object_new(auto_start_flutter_plugin_get_type(), nullptr));

  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  g_autoptr(FlMethodChannel) channel = fl_method_channel_new(
      fl_plugin_registrar_get_messenger(registrar),
      "com.techflow.co/auto_start_flutter", FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(
      channel, method_call_cb, g_object_ref(plugin), g_object_unref);

  g_object_unref(plugin);
}
