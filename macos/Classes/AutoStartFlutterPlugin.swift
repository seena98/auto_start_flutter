import Cocoa
import FlutterMacOS

public class AutoStartFlutterPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "auto_start_flutter", binaryMessenger: registrar.messenger)
    let instance = AutoStartFlutterPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getAutoStartPermission":
        // Open Login Items Settings
        // macOS 13+ (Ventura) and later
        if let url = URL(string: "x-apple.systempreferences:com.apple.LoginItems-Settings.extension") {
            NSWorkspace.shared.open(url)
        }
        result(true)
    case "isAutoStartAvailable":
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
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
