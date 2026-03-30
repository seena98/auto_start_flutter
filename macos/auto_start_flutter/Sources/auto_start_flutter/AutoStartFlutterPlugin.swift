import Cocoa
import FlutterMacOS
import ServiceManagement
import UserNotifications

public class AutoStartFlutterPlugin: NSObject, FlutterPlugin, UNUserNotificationCenterDelegate {
    
    var launchArgs: [String: Any]? = nil
    var backgroundEngines: [Int64: FlutterEngine] = [:]

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "com.techflow.co/auto_start_flutter", binaryMessenger: registrar.messenger)
        let instance = AutoStartFlutterPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        
        let center = UNUserNotificationCenter.current()
        if center.delegate == nil {
            center.delegate = instance
        }
    }

    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        if let taskId = userInfo["taskId"] as? String {
            var args: [String: Any] = ["scheduledTaskId": taskId]
            if let callbackHandle = userInfo["callbackHandle"] as? Int64 {
                args["callbackHandle"] = callbackHandle
            } else if let callbackHandleStr = userInfo["callbackHandle"] as? String, let handle = Int64(callbackHandleStr) {
                args["callbackHandle"] = handle
            } else if let callbackHandleInt = userInfo["callbackHandle"] as? Int {
                args["callbackHandle"] = Int64(callbackHandleInt)
            } else if let callbackHandleNS = userInfo["callbackHandle"] as? NSNumber {
                args["callbackHandle"] = callbackHandleNS.int64Value
            }
            self.launchArgs = args
        }
        completionHandler()
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "permit-auto-start":
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
            if let url = URL(string: "x-apple.systempreferences:com.apple.preference.energy") {
                NSWorkspace.shared.open(url)
            }
             result(true)
        case "openAppInfo":
            if let url = URL(string: "x-apple.systempreferences:com.apple.preference.general") {
                 NSWorkspace.shared.open(url)
            }
            result(true)
        case "executeInBackground":
            result(false) // Handled natively in Dart via Isolate.spawn for macOS
        case "scheduleTask":
            guard let args = call.arguments as? [String: Any],
                  let timestamp = args["timestamp"] as? Int64,
                  let taskId = args["taskId"] as? String else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing required arguments", details: nil))
                return
            }
            let callbackHandle = args["callbackHandle"] as? Int64 ?? 0
            
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                if granted {
                    let content = UNMutableNotificationContent()
                    content.title = "Scheduled Task"
                    content.body = "Tap to execute background task."
                    content.userInfo = [
                        "taskId": taskId,
                        "callbackHandle": callbackHandle
                    ]
                    
                    let date = Date(timeIntervalSince1970: TimeInterval(timestamp) / 1000.0)
                    let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
                    
                    let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
                    let request = UNNotificationRequest(identifier: "auto_start_flutter_\(taskId)", content: content, trigger: trigger)
                    
                    center.add(request) { error in
                        DispatchQueue.main.async {
                            if let error = error {
                                print("Error scheduling task: \(error)")
                                result(false)
                            } else {
                                result(true)
                            }
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        result(false)
                    }
                }
            }
        case "getLaunchArguments":
            result(launchArgs ?? [:])
            launchArgs = nil
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
                result(false)
            }
        case "startForegroundService", "stopForegroundService":
            result(false)
        default:
          result(FlutterMethodNotImplemented)
        }
    }
}
