package co.techFlow.auto_start_flutter

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

class ScheduledTaskReceiver : BroadcastReceiver() {
    companion object {
        const val TAG = "AutoStartTaskReceiver"
        const val EXTRA_CALLBACK_HANDLE = "callback_handle"
        const val EXTRA_TASK_ID = "task_id"
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
        val callbackHandle = intent.getLongExtra(EXTRA_CALLBACK_HANDLE, -1L)
        val taskId = intent.getStringExtra(EXTRA_TASK_ID)

        Log.d(TAG, "Scheduled task fired! TaskId: $taskId")
        if (taskId != null) TaskScheduler.remove(context, taskId)

        if (callbackHandle != -1L) {
            // onReceive already runs on the main thread, which the Flutter engine requires.
            HeadlessEngineHelper.startHeadlessCallback(context, callbackHandle)
        } else {
            Log.e(TAG, "No callback handle provided for scheduled task.")
        }
    }
}
