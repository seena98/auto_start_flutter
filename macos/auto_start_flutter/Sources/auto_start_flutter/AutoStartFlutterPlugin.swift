import Cocoa
import FlutterMacOS
import ServiceManagement

public class AutoStartFlutterPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "com.techflow.co/auto_start_flutter", binaryMessenger: registrar.messenger)
    let instance = AutoStartFlutterPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "permit-auto-start":
        // Open Login Items Settings
        // macOS 13+ (Ventura) and later
        if let url = URL(string: "x-apple.systempreferences:com.apple.LoginItems-Settings.extension") {
            NSWorkspace.shared.open(url)
        }
        result(true)
    case "isAutoStartPermission":
        result(true)
    case "getDeviceManufacturer":
        result("Apple")
    case "isBatteryOptimizationDisabled":
        result(true)
    case "disableBatteryOptimization":
        // Open Energy Saver / Battery settings
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.energy") {
            NSWorkspace.shared.open(url)
        }
         result(true)
    case "openAppInfo":
        // Open General Settings
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.general") {
             NSWorkspace.shared.open(url)
        }
        result(true)
    case "registerBootCallback":
        if #available(macOS 13.0, *) {
            do {
                try SMAppService.mainApp.register()
                result(true)
            } catch {
                print("Failed to register SMAppService: \(error)")
                result(false)
            }
        } else {
            // SMLoginItemSetEnabled requires a bundled helper app.
            // For macOS < 13.0, we just return false indicating failure/unsupported.
            result(false)
        }
    case "startForegroundService", "stopForegroundService":
        result(false)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
