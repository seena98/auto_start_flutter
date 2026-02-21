#include <flutter_linux/flutter_linux.h>
#include <gmock/gmock.h>
#include <gtest/gtest.h>

#include "auto_start_flutter_plugin_private.h"
#include "include/auto_start_flutter/auto_start_flutter_plugin.h"

namespace auto_start_flutter {
namespace test {

TEST(AutoStartFlutterPlugin, PermitAutoStart) {
  g_autoptr(FlMethodResponse) response = permit_auto_start();
  ASSERT_NE(response, nullptr);
  ASSERT_TRUE(FL_IS_METHOD_SUCCESS_RESPONSE(response));
  FlValue *result = fl_method_success_response_get_result(
      FL_METHOD_SUCCESS_RESPONSE(response));
  ASSERT_EQ(fl_value_get_type(result), FL_VALUE_TYPE_BOOL);
  EXPECT_TRUE(fl_value_get_bool(result));
}

TEST(AutoStartFlutterPlugin, IsAutoStartPermission) {
  g_autoptr(FlMethodResponse) response = is_auto_start_permission();
  ASSERT_NE(response, nullptr);
  ASSERT_TRUE(FL_IS_METHOD_SUCCESS_RESPONSE(response));
  FlValue *result = fl_method_success_response_get_result(
      FL_METHOD_SUCCESS_RESPONSE(response));
  ASSERT_EQ(fl_value_get_type(result), FL_VALUE_TYPE_BOOL);
  EXPECT_TRUE(fl_value_get_bool(result));
}

TEST(AutoStartFlutterPlugin, GetDeviceManufacturer) {
  g_autoptr(FlMethodResponse) response = get_device_manufacturer();
  ASSERT_NE(response, nullptr);
  ASSERT_TRUE(FL_IS_METHOD_SUCCESS_RESPONSE(response));
  FlValue *result = fl_method_success_response_get_result(
      FL_METHOD_SUCCESS_RESPONSE(response));
  ASSERT_EQ(fl_value_get_type(result), FL_VALUE_TYPE_STRING);
  EXPECT_STREQ(fl_value_get_string(result), "Linux");
}

TEST(AutoStartFlutterPlugin, DisableBatteryOptimization) {
  g_autoptr(FlMethodResponse) response = disable_battery_optimization();
  ASSERT_NE(response, nullptr);
  ASSERT_TRUE(FL_IS_METHOD_SUCCESS_RESPONSE(response));
  FlValue *result = fl_method_success_response_get_result(
      FL_METHOD_SUCCESS_RESPONSE(response));
  ASSERT_EQ(fl_value_get_type(result), FL_VALUE_TYPE_BOOL);
  EXPECT_TRUE(fl_value_get_bool(result));
}

TEST(AutoStartFlutterPlugin, IsBatteryOptimizationDisabled) {
  g_autoptr(FlMethodResponse) response = is_battery_optimization_disabled();
  ASSERT_NE(response, nullptr);
  ASSERT_TRUE(FL_IS_METHOD_SUCCESS_RESPONSE(response));
  FlValue *result = fl_method_success_response_get_result(
      FL_METHOD_SUCCESS_RESPONSE(response));
  ASSERT_EQ(fl_value_get_type(result), FL_VALUE_TYPE_BOOL);
  EXPECT_TRUE(fl_value_get_bool(result));
}

TEST(AutoStartFlutterPlugin, OpenAppInfo) {
  g_autoptr(FlMethodResponse) response = open_app_info();
  ASSERT_NE(response, nullptr);
  ASSERT_TRUE(FL_IS_METHOD_SUCCESS_RESPONSE(response));
  FlValue *result = fl_method_success_response_get_result(
      FL_METHOD_SUCCESS_RESPONSE(response));
  ASSERT_EQ(fl_value_get_type(result), FL_VALUE_TYPE_BOOL);
  EXPECT_TRUE(fl_value_get_bool(result));
}

} // namespace test
} // namespace auto_start_flutter
