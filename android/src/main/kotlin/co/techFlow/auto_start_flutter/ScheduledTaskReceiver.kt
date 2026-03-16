package co.techFlow.auto_start_flutter

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import android.os.Handler
import android.os.Looper

class ScheduledTaskReceiver : BroadcastReceiver() {
    companion object {
        const val TAG = "AutoStartTaskReceiver"
        const val EXTRA_CALLBACK_HANDLE = "callback_handle"
        const val EXTRA_TASK_ID = "task_id"
    }

    override fun onReceive(context: Context, intent: Intent) {
        val callbackHandle = intent.getLongExtra(EXTRA_CALLBACK_HANDLE, -1L)
        val taskId = intent.getStringExtra(EXTRA_TASK_ID)
        
        Log.d(TAG, "Scheduled task fired! TaskId: $taskId")
        
        if (callbackHandle != -1L) {
            Handler(Looper.getMainLooper()).post {
                HeadlessEngineHelper.startHeadlessCallback(context, callbackHandle)
            }
        } else {
            Log.e(TAG, "No callback handle provided for scheduled task.")
        }
    }
}
