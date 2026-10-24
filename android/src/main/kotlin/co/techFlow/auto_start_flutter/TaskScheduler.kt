package co.techFlow.auto_start_flutter

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.util.Log
import org.json.JSONObject

/**
 * Schedules exact alarms that fire [ScheduledTaskReceiver] and persists them so they can be
 * restored after a reboot.
 */
object TaskScheduler {
    private const val TAG = "AutoStartTaskScheduler"
    private const val TASKS_KEY = "scheduled_tasks"

    class ExactAlarmDeniedException : Exception("Exact alarm permission has not been granted.")

    data class Task(val taskId: String, val timestamp: Long, val callbackHandle: Long)

    private fun prefs(context: Context) =
        context.getSharedPreferences(BootReceiver.SHARED_PREFS_KEY, Context.MODE_PRIVATE)

    private fun readAll(context: Context): JSONObject =
        try {
            JSONObject(prefs(context).getString(TASKS_KEY, null) ?: "{}")
        } catch (e: Exception) {
            JSONObject()
        }

    private fun writeAll(context: Context, tasks: JSONObject) {
        prefs(context).edit().putString(TASKS_KEY, tasks.toString()).apply()
    }

    @Synchronized
    fun list(context: Context): List<Task> {
        val all = readAll(context)
        return all.keys().asSequence().mapNotNull { id ->
            val obj = all.optJSONObject(id) ?: return@mapNotNull null
            Task(id, obj.optLong("timestamp"), obj.optLong("callbackHandle"))
        }.toList()
    }

    @Synchronized
    fun remove(context: Context, taskId: String) {
        val all = readAll(context)
        if (all.has(taskId)) {
            all.remove(taskId)
            writeAll(context, all)
        }
    }

    /** @throws ExactAlarmDeniedException on Android 12+ when exact alarms are not allowed. */
    @Synchronized
    fun schedule(context: Context, task: Task) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S && !alarmManager.canScheduleExactAlarms()) {
            throw ExactAlarmDeniedException()
        }
        val pendingIntent = pendingIntent(context, task.taskId, task.callbackHandle)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, task.timestamp, pendingIntent)
        } else {
            alarmManager.setExact(AlarmManager.RTC_WAKEUP, task.timestamp, pendingIntent)
        }

        val all = readAll(context)
        all.put(
            task.taskId,
            JSONObject().put("timestamp", task.timestamp).put("callbackHandle", task.callbackHandle)
        )
        writeAll(context, all)
    }

    @Synchronized
    fun cancel(context: Context, taskId: String): Boolean {
        val all = readAll(context)
        val existed = all.has(taskId)
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val pending = pendingIntent(context, taskId, -1L)
        alarmManager.cancel(pending)
        pending.cancel()
        remove(context, taskId)
        return existed
    }

    /**
     * Re-registers alarms lost on reboot. Tasks that were due while the device was off are
     * returned so the caller can run them right away.
     */
    fun restoreAfterBoot(context: Context): List<Task> {
        val now = System.currentTimeMillis()
        val missed = mutableListOf<Task>()
        for (task in list(context)) {
            if (task.timestamp <= now) {
                remove(context, task.taskId)
                missed.add(task)
            } else {
                try {
                    schedule(context, task)
                } catch (e: Exception) {
                    Log.e(TAG, "Could not restore task ${task.taskId}: ${e.message}")
                }
            }
        }
        return missed
    }

    // The task id lives in the intent data, so two ids can never share a PendingIntent
    // (Intent.filterEquals compares data but not extras).
    private fun pendingIntent(context: Context, taskId: String, callbackHandle: Long): PendingIntent {
        val intent = Intent(context, ScheduledTaskReceiver::class.java).apply {
            data = Uri.parse("auto-start-task://task/" + Uri.encode(taskId))
            putExtra(ScheduledTaskReceiver.EXTRA_CALLBACK_HANDLE, callbackHandle)
            putExtra(ScheduledTaskReceiver.EXTRA_TASK_ID, taskId)
        }
        val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        } else {
            PendingIntent.FLAG_UPDATE_CURRENT
        }
        return PendingIntent.getBroadcast(context, 0, intent, flags)
    }
}
