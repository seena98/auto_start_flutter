package co.techFlow.auto_start_flutter

import android.content.Context
import android.util.Log
import io.flutter.FlutterInjector
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.view.FlutterCallbackInformation

object HeadlessEngineHelper {
    private const val TAG = "AutoStartHeadlessHelper"

    fun startHeadlessCallback(context: Context, callbackHandle: Long) {
        FlutterInjector.instance().flutterLoader().startInitialization(context)
        FlutterInjector.instance().flutterLoader().ensureInitializationComplete(context, null)
        
        val callbackInfo = FlutterCallbackInformation.lookupCallbackInformation(callbackHandle)
        if (callbackInfo == null) {
            Log.e(TAG, "Fatal: failed to find callback for handle: $callbackHandle")
            return
        }
        
        Log.d(TAG, "Starting Flutter Engine in background to execute callback...")
        val engine = FlutterEngine(context)
        
        val args = DartExecutor.DartCallback(
            context.assets,
            FlutterInjector.instance().flutterLoader().findAppBundlePath(),
            callbackInfo
        )
        
        engine.dartExecutor.executeDartCallback(args)
    }
}
