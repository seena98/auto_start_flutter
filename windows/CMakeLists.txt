cmake_minimum_required(VERSION 3.15)

project(auto_start_flutter LANGUAGES CXX)

set(PLUGIN_NAME "auto_start_flutter_plugin")

add_library(${PLUGIN_NAME} SHARED
  "auto_start_flutter_plugin.cpp"
)

apply_standard_settings(${PLUGIN_NAME})

set_target_properties(${PLUGIN_NAME} PROPERTIES
  CXX_VISIBILITY_PRESET hidden
  VISIBILITY_INLINES_HIDDEN 1
)

target_compile_definitions(${PLUGIN_NAME} PRIVATE FLUTTER_PLUGIN_IMPL)

target_include_directories(${PLUGIN_NAME} PUBLIC
  "${CMAKE_CURRENT_SOURCE_DIR}/include"
)

target_link_libraries(${PLUGIN_NAME} PRIVATE flutter flutter_wrapper_plugin)

# List of absolute paths to libraries that should be bundled with the plugin
set(auto_start_flutter_bundled_libraries
  ""
  PARENT_SCOPE
)
