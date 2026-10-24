package co.techFlow.auto_start_flutter

import android.content.Context
import android.os.Handler
import android.os.Looper
import android.os.PowerManager
import android.util.Log
import io.flutter.FlutterInjector
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.view.FlutterCallbackInformation

object HeadlessEngineHelper {
    private const val TAG = "AutoStartHeadlessHelper"

    /** Engines are destroyed after this long even if Dart never calls completeBackgroundTask. */
    const val ENGINE_TIMEOUT_MS = 5 * 60 * 1000L

    private val mainHandler = Handler(Looper.getMainLooper())
    private val engines = mutableListOf<FlutterEngine>()
    private val wakeLocks = mutableMapOf<FlutterEngine, PowerManager.WakeLock>()

    fun startHeadlessCallback(context: Context, callbackHandle: Long) {
        val appContext = context.applicationContext
        FlutterInjector.instance().flutterLoader().startInitialization(appContext)
        FlutterInjector.instance().flutterLoader().ensureInitializationComplete(appContext, null)

        val callbackInfo = FlutterCallbackInformation.lookupCallbackInformation(callbackHandle)
        if (callbackInfo == null) {
            Log.e(TAG, "Fatal: failed to find callback for handle: $callbackHandle")
            return
        }

        Log.d(TAG, "Starting Flutter Engine in background to execute callback...")
        val engine = FlutterEngine(appContext)
        synchronized(engines) {
            engines.add(engine)
            acquireWakeLock(appContext)?.let { wakeLocks[engine] = it }
        }

        val args = DartExecutor.DartCallback(
            appContext.assets,
            FlutterInjector.instance().flutterLoader().findAppBundlePath(),
            callbackInfo
        )
        engine.dartExecutor.executeDartCallback(args)

        mainHandler.postDelayed({ destroy(engine) }, ENGINE_TIMEOUT_MS)
    }

    /** Destroys the engine that owns [messenger]. Called when Dart reports its task is done. */
    fun finish(messenger: BinaryMessenger): Boolean {
        val engine = synchronized(engines) {
            engines.firstOrNull { it.dartExecutor.binaryMessenger === messenger }
        } ?: return false
        // Post so the MethodChannel reply is delivered before the engine goes away.
        mainHandler.post { destroy(engine) }
        return true
    }

    private fun destroy(engine: FlutterEngine) {
        val removed = synchronized(engines) {
            wakeLocks.remove(engine)?.let { if (it.isHeld) it.release() }
            engines.remove(engine)
        }
        if (removed) {
            Log.d(TAG, "Destroying headless Flutter Engine.")
            engine.destroy()
        }
    }

    /**
     * Keeps the CPU awake while the Dart callback runs so the process isn't suspended right after
     * the receiver returns. Released with the engine, or by the timeout. Optional: the app must
     * declare android.permission.WAKE_LOCK; without it the callback still runs, just without the
     * wake lock.
     */
    private fun acquireWakeLock(context: Context): PowerManager.WakeLock? =
        try {
            val pm = context.getSystemService(Context.POWER_SERVICE) as PowerManager
            pm.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, "auto_start_flutter:headless").apply {
                acquire(ENGINE_TIMEOUT_MS)
            }
        } catch (e: Exception) {
            Log.w(TAG, "Could not acquire wake lock: ${e.message}")
            null
        }
}
