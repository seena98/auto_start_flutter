package co.techFlow.auto_start_flutter

import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.provider.Settings
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import android.util.Log
import io.flutter.plugin.common.MethodChannel.Result


class AutoStartFlutterPlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "com.techflow.co/auto_start_flutter")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "permit-auto-start" -> {
                val success = openAutoStartSettings()
                result.success(success)
            }
            "registerBootCallback" -> {
                val callbackHandle = call.argument<Long>("callbackHandle")
                if (callbackHandle != null) {
                    val prefs = context.getSharedPreferences(BootReceiver.SHARED_PREFS_KEY, Context.MODE_PRIVATE)
                    prefs.edit().putLong(BootReceiver.CACHED_CALLBACK_KEY, callbackHandle).apply()
                    result.success(true)
                } else {
                    result.error("INVALID_ARGUMENT", "callbackHandle must not be null", null)
                }
            }
            "isAutoStartPermission" -> {
                 val intents = AutoStartIntents.getIntents(context)
                 var found = false
                 for (intent in intents) {
                     try {
                         intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                         val list = context.packageManager.queryIntentActivities(
                             intent, PackageManager.MATCH_DEFAULT_ONLY
                         )
                         if (list.size > 0) {
                             found = true
                             break
                         }
                     } catch (e: Exception) {
                         // Ignore and try next intent
                     }
                 }
                 result.success(found)
             }
            "isBatteryOptimizationDisabled" -> {
                val packageName = context.packageName
                val pm = context.getSystemService(Context.POWER_SERVICE) as PowerManager
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    result.success(pm.isIgnoringBatteryOptimizations(packageName))
                } else {
                    result.success(true)
                }
            }
            "disableBatteryOptimization" -> {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS)
                    intent.data = Uri.parse("package:" + context.packageName)
                    intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                    context.startActivity(intent)
                }
                result.success(null)
            }
            "startForegroundService" -> {
                try {
                    val title = call.argument<String>("title")
                    val content = call.argument<String>("content")
                    val serviceIntent = Intent(context, KeepAliveService::class.java).apply {
                        putExtra("title", title)
                        putExtra("content", content)
                    }
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        context.startForegroundService(serviceIntent)
                    } else {
                        context.startService(serviceIntent)
                    }
                    result.success(true)
                } catch (e: Exception) {
                    result.error("FOREGROUND_SERVICE_ERROR", e.message, null)
                }
            }
            "stopForegroundService" -> {
                try {
                    val serviceIntent = Intent(context, KeepAliveService::class.java)
                    context.stopService(serviceIntent)
                    result.success(true)
                } catch (e: Exception) {
                    result.error("FOREGROUND_SERVICE_ERROR", e.message, null)
                }
            }
            "openAppInfo" -> {
                try {
                    val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS)
                    intent.data = Uri.fromParts("package", context.packageName, null)
                    intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                    context.startActivity(intent)
                    result.success(true)
                } catch (e: Exception) {
                    result.success(false)
                }
            }
            "getDeviceManufacturer" -> {
                result.success(Build.MANUFACTURER)
            }
            "openCustomSetting" -> {
                val packageName = call.argument<String>("packageName")
                val activityName = call.argument<String>("activityName")
                if (packageName != null && activityName != null) {
                    try {
                        val intent = Intent()
                        intent.component = android.content.ComponentName(packageName, activityName)
                        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                        context.startActivity(intent)
                        result.success(true)
                    } catch (e: Exception) {
                        result.success(false)
                    }
                } else {
                    result.error("INVALID_ARGUMENT", "Package name and activity name must not be null", null)
                }
            }
            "scheduleTask" -> {
                val timestamp = call.argument<Long>("timestamp")
                val callbackHandle = call.argument<Long>("callbackHandle")
                val taskId = call.argument<String>("taskId")
                
                if (timestamp != null && callbackHandle != null && taskId != null) {
                    val success = scheduleAndroidAlarm(timestamp, callbackHandle, taskId)
                    result.success(success)
                } else {
                    result.error("INVALID_ARGUMENT", "timestamp, callbackHandle, and taskId must not be null", null)
                }
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    private fun scheduleAndroidAlarm(timestamp: Long, callbackHandle: Long, taskId: String): Boolean {
        return try {
            val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as android.app.AlarmManager
            val intent = Intent(context, ScheduledTaskReceiver::class.java).apply {
                putExtra(ScheduledTaskReceiver.EXTRA_CALLBACK_HANDLE, callbackHandle)
                putExtra(ScheduledTaskReceiver.EXTRA_TASK_ID, taskId)
            }
            
            val pendingIntent = android.app.PendingIntent.getBroadcast(
                context,
                taskId.hashCode(),
                intent,
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    android.app.PendingIntent.FLAG_UPDATE_CURRENT or android.app.PendingIntent.FLAG_IMMUTABLE
                } else {
                    android.app.PendingIntent.FLAG_UPDATE_CURRENT
                }
            )
            
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                alarmManager.setExactAndAllowWhileIdle(android.app.AlarmManager.RTC_WAKEUP, timestamp, pendingIntent)
            } else {
                alarmManager.setExact(android.app.AlarmManager.RTC_WAKEUP, timestamp, pendingIntent)
            }
            true
        } catch (e: Exception) {
            Log.e("AutoStartPlugin", "Failed to schedule alarm: ${e.message}")
            false
        }
    }

    private fun openAutoStartSettings(): Boolean {
        val intents = AutoStartIntents.getIntents(context)
        for (intent in intents) {
            try {
                intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                val list = context.packageManager.queryIntentActivities(intent, PackageManager.MATCH_DEFAULT_ONLY)
                if (list.size > 0) {
                    context.startActivity(intent)
                    return true
                }
            } catch (e: Exception) {
                // Ignore and try next intent
            }
        }
        return false
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}
