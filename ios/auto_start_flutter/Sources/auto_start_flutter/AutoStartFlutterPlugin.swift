import Flutter
import UIKit

public class AutoStartFlutterPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "com.techflow.co/auto_start_flutter", binaryMessenger: registrar.messenger())
    let instance = AutoStartFlutterPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "isAutoStartPermission":
        // Check Background App Refresh status
        let status = UIApplication.shared.backgroundRefreshStatus
        if status == .available {
            result(true)
        } else {
            result(false)
        }
    case "permit-auto-start", "openAppInfo", "disableBatteryOptimization":
        // For iOS, these all map to opening the app's settings page
        if let url = URL(string: UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: { success in
                    result(success)
                })
            } else {
                result(false)
            }
        } else {
            result(false)
        }
    case "getDeviceManufacturer":
        result("Apple")
    case "isBatteryOptimizationDisabled":
         // iOS doesn't have battery optimization in the same way.
         // We can assume if background refresh is available, we are "good".
         // Or just return true as we can't programmatically check "Low Power Mode" easily without strict API usage?
         // Actually, `ProcessInfo.processInfo.isLowPowerModeEnabled` exists.
         // But the user asked for simple mapping. Let's return true for now to indicate "no restriction" or just return the BG refresh status?
         // The prompt said: "isBatteryOptimizationDisabled: Return true (Not applicable on iOS, treat as 'optimized' or 'good')".
         result(true)
    case "openCustomSetting":
        // Not supported on iOS
        result(FlutterMethodNotImplemented)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
