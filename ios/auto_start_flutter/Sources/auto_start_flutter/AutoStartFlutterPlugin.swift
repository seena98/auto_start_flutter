import Flutter
import UIKit
import UserNotifications

public class AutoStartFlutterPlugin: NSObject, FlutterPlugin, UNUserNotificationCenterDelegate {
    
    var launchArgs: [String: Any]? = nil
    var backgroundEngines: [Int64: FlutterEngine] = [:]

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "com.techflow.co/auto_start_flutter", binaryMessenger: registrar.messenger())
        let instance = AutoStartFlutterPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        registrar.addApplicationDelegate(instance)
        
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
        case "isAutoStartPermission":
            let status = UIApplication.shared.backgroundRefreshStatus
            if status == .available {
                result(true)
            } else {
                result(false)
            }
        case "permit-auto-start", "openAppInfo", "disableBatteryOptimization":
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
             result(true)
        case "executeInBackground":
            guard let args = call.arguments as? [String: Any] else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing required arguments", details: nil))
                return
            }
            let callbackHandle = args["callbackHandle"] as? Int64 ?? 0
            if callbackHandle != 0 {
                if let callbackInfo = FlutterCallbackCache.lookupCallbackInformation(callbackHandle) {
                    let engine = FlutterEngine(name: "auto_start_background_engine_\(callbackHandle)", project: nil, allowHeadlessExecution: true)
                    let isRunning = engine.run(withEntrypoint: callbackInfo.callbackName, libraryURI: callbackInfo.callbackLibraryPath)
                    
                    if isRunning {
                        self.backgroundEngines[callbackHandle] = engine
                        result(true)
                    } else {
                        result(FlutterError(code: "ENGINE_ERROR", message: "Failed to run background engine", details: nil))
                    }
                } else {
                    result(FlutterError(code: "INVALID_CALLBACK", message: "Could not find callback info", details: nil))
                }
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "callbackHandle must not be zero", details: nil))
            }
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
        case "openCustomSetting":
            result(FlutterMethodNotImplemented)
        case "startForegroundService", "stopForegroundService", "registerBootCallback":
            result(false)
        default:
          result(FlutterMethodNotImplemented)
        }
    }
}
