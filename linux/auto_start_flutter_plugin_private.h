#include <flutter_linux/flutter_linux.h>

#include "include/auto_start_flutter/auto_start_flutter_plugin.h"

// This file exposes some plugin internals for unit testing. See
// https://github.com/flutter/flutter/issues/88724 for current limitations
// in the unit-testable API.

// Handles method calls
FlMethodResponse *permit_auto_start();
FlMethodResponse *is_auto_start_permission();
FlMethodResponse *get_device_manufacturer();
FlMethodResponse *disable_battery_optimization();
FlMethodResponse *is_battery_optimization_disabled();
FlMethodResponse *open_app_info();
FlMethodResponse *register_boot_callback();
FlMethodResponse *schedule_task(int64_t timestamp, const gchar *task_id,
                                int64_t callback_handle);

