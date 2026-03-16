package co.techFlow.auto_start_flutter

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import io.flutter.FlutterInjector
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.view.FlutterCallbackInformation
import android.os.Handler
import android.os.Looper

class BootReceiver : BroadcastReceiver() {
    companion object {
        const val TAG = "AutoStartBootReceiver"
        const val SHARED_PREFS_KEY = "co.techflow.auto_start_flutter.prefs"
        const val CACHED_CALLBACK_KEY = "boot_callback_handle"
    }

    override fun onReceive(context: Context, intent: Intent) {
        val action = intent.action
        if (action == Intent.ACTION_BOOT_COMPLETED ||
            action == "android.intent.action.QUICKBOOT_POWERON" ||
            action == "com.htc.intent.action.QUICKBOOT_POWERON") {
            
            Log.d(TAG, "Device booted. Attempting to run headless Dart callback...")
            
            val prefs = context.getSharedPreferences(SHARED_PREFS_KEY, Context.MODE_PRIVATE)
            val callbackHandle = prefs.getLong(CACHED_CALLBACK_KEY, -1L)
            
            if (callbackHandle != -1L) {
                // We shouldn't block the receiver thread too long, so we post to main thread
                Handler(Looper.getMainLooper()).post {
                    HeadlessEngineHelper.startHeadlessCallback(context, callbackHandle)
                }
            } else {
                Log.d(TAG, "No Dart callback registered for boot.")
            }
        }
    }
}
