#include <flutter/method_call.h>
#include <flutter/method_result_functions.h>
#include <flutter/standard_method_codec.h>
#include <gtest/gtest.h>
#include <windows.h>

#include <memory>
#include <string>
#include <variant>

#include "auto_start_flutter_plugin.h"

namespace auto_start_flutter {
namespace test {

namespace {

using flutter::EncodableMap;
using flutter::EncodableValue;
using flutter::MethodCall;
using flutter::MethodResultFunctions;

}  // namespace

TEST(AutoStartFlutterPlugin, IsAutoStartAvailable) {
  AutoStartFlutterPlugin plugin;
  std::unique_ptr<MethodResultFunctions<>> result =
      std::make_unique<MethodResultFunctions<>>(
          [](const EncodableValue* result) {
            EXPECT_TRUE(std::get<bool>(*result));
          },
          nullptr, nullptr);

  plugin.HandleMethodCall(
      MethodCall("isAutoStartAvailable", std::make_unique<EncodableValue>()),
      std::move(result));
}

TEST(AutoStartFlutterPlugin, GetDeviceManufacturer) {
  AutoStartFlutterPlugin plugin;
  std::unique_ptr<MethodResultFunctions<>> result =
      std::make_unique<MethodResultFunctions<>>(
          [](const EncodableValue* result) {
            EXPECT_EQ(std::get<std::string>(*result), "Microsoft");
          },
          nullptr, nullptr);

  plugin.HandleMethodCall(
      MethodCall("getDeviceManufacturer", std::make_unique<EncodableValue>()),
      std::move(result));
}

}  // namespace test
}  // namespace auto_start_flutter
