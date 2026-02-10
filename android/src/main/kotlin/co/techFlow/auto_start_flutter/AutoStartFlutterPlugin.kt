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
            "isAutoStartPermission" -> {
                // We return true if the manufacturer is one we have intents for.
                // It's a best-guess "is this feature relevant?" check.
                val manufacturer = Build.MANUFACTURER.lowercase()
                val knownManufacturers = listOf("xiaomi", "redmi", "poco", "oppo", "vivo", "huawei", "honor", "samsung", "oneplus", "nokia", "asus", "letv", "meizu", "htc", "realme", "infinix", "tecno", "itel", "lenovo", "zte", "nubia")
                result.success(knownManufacturers.contains(manufacturer))
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
                    val intent = Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS)
                    intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                    context.startActivity(intent)
                }
                result.success(null)
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
            else -> {
                result.notImplemented()
            }
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
