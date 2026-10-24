package co.techFlow.auto_start_flutter

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

class BootReceiver : BroadcastReceiver() {
    companion object {
        const val TAG = "AutoStartBootReceiver"
        const val SHARED_PREFS_KEY = "co.techflow.auto_start_flutter.prefs"
        const val CACHED_CALLBACK_KEY = "boot_callback_handle"
    }

    override fun onReceive(context: Context, intent: Intent) {
        // Keep the receiver alive while we set up the engine; the wake lock covers the Dart run.
        val pendingResult = goAsync()
        try {
            handle(context, intent)
        } finally {
            pendingResult.finish()
        }
    }

    private fun handle(context: Context, intent: Intent) {
        val action = intent.action
        if (action == Intent.ACTION_BOOT_COMPLETED ||
            action == "android.intent.action.QUICKBOOT_POWERON" ||
            action == "com.htc.intent.action.QUICKBOOT_POWERON") {

            Log.d(TAG, "Device booted.")

            // Alarms are cleared on reboot: restore them and run any that came due meanwhile.
            for (task in TaskScheduler.restoreAfterBoot(context)) {
                HeadlessEngineHelper.startHeadlessCallback(context, task.callbackHandle)
            }

            val prefs = context.getSharedPreferences(SHARED_PREFS_KEY, Context.MODE_PRIVATE)
            val callbackHandle = prefs.getLong(CACHED_CALLBACK_KEY, -1L)

            if (callbackHandle != -1L) {
                HeadlessEngineHelper.startHeadlessCallback(context, callbackHandle)
            } else {
                Log.d(TAG, "No Dart callback registered for boot.")
            }
        }
    }
}
