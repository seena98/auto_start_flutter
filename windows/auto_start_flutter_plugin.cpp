#include <initguid.h>
#include "auto_start_flutter_plugin.h"

#include <auto_start_flutter/auto_start_flutter_plugin.h>

#include <shellapi.h>
#include <windows.h>

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <memory>
#include <string>
#include <sstream>


namespace auto_start_flutter {
 
 std::string Utf16ToUtf8(const std::wstring& utf16) {
   if (utf16.empty())
     return "";
   int size_needed = WideCharToMultiByte(CP_UTF8, 0, &utf16[0], (int)utf16.size(),
                                         NULL, 0, NULL, NULL);
   std::string utf8(size_needed, 0);
   WideCharToMultiByte(CP_UTF8, 0, &utf16[0], (int)utf16.size(), &utf8[0],
                       size_needed, NULL, NULL);
   return utf8;
 }
 
 std::wstring Utf8ToUtf16(const std::string& utf8) {
   if (utf8.empty())
     return L"";
   int size_needed = MultiByteToWideChar(CP_UTF8, 0, &utf8[0], (int)utf8.size(),
                                         NULL, 0);
   std::wstring utf16(size_needed, 0);
   MultiByteToWideChar(CP_UTF8, 0, &utf8[0], (int)utf8.size(), &utf16[0],
                       size_needed);
   return utf16;
 }
 
// static
void AutoStartFlutterPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows *registrar) {
  auto channel =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          registrar->messenger(), "auto_start_flutter",
          &flutter::StandardMethodCodec::GetInstance());

  auto plugin = std::make_unique<AutoStartFlutterPlugin>();

  channel->SetMethodCallHandler(
      [plugin_pointer = plugin.get()](const auto &call, auto result) {
        plugin_pointer->HandleMethodCall(call, std::move(result));
      });

  registrar->AddPlugin(std::move(plugin));
}

AutoStartFlutterPlugin::AutoStartFlutterPlugin() {}

AutoStartFlutterPlugin::~AutoStartFlutterPlugin() {}

void AutoStartFlutterPlugin::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  if (method_call.method_name().compare("getAutoStartPermission") == 0) {
    // Open Windows Startup Settings
    // URI scheme: ms-settings:startupapps
    ShellExecute(0, 0, L"ms-settings:startupapps", 0, 0, SW_SHOW);
    result->Success();
  } else if (method_call.method_name().compare("isAutoStartAvailable") == 0) {
    // Windows generally supports managing startup apps via settings
    result->Success(flutter::EncodableValue(true));
  } else if (method_call.method_name().compare("getDeviceManufacturer") == 0) {
    result->Success(flutter::EncodableValue("Microsoft"));
  } else if (method_call.method_name().compare(
                 "isBatteryOptimizationDisabled") == 0) {
    // Not strictly applicable to Windows in the same way as Android Doze,
    // but returning true (optimization disabled/ignored) is a safe default for
    // compatibility.
    result->Success(flutter::EncodableValue(true));
  } else if (method_call.method_name().compare("disableBatteryOptimization") ==
             0) {
    // Create a dummy result for compatibility
    ShellExecute(0, 0, L"ms-settings:powersleep", 0, 0, SW_SHOW);
    result->Success();
  } else if (method_call.method_name().compare("openAppInfo") == 0) {
    ShellExecute(0, 0, L"ms-settings:appsfeatures-app", 0, 0, SW_SHOW);
    result->Success();
  } else if (method_call.method_name().compare("registerBootCallback") == 0) {
    // On Windows, the closest equivalent to a persistent background boot
    // trigger is adding the app to the startup registry. This launches the
    // whole app on login.
    wchar_t exePath[MAX_PATH];
    if (GetModuleFileNameW(NULL, exePath, MAX_PATH)) {
      HKEY hKey;
      LONG lRes =
          RegOpenKeyExW(HKEY_CURRENT_USER,
                        L"Software\\Microsoft\\Windows\\CurrentVersion\\Run", 0,
                        KEY_WRITE, &hKey);
      if (lRes == ERROR_SUCCESS) {
        // Use the executable name as the registry value name
        wchar_t *exeName = wcsrchr(exePath, L'\\');
        if (exeName) {
          exeName++; // Skip the backslash
        } else {
          exeName = L"AutoStartFlutterApp";
        }

        // Wrap path in quotes
        std::wstring valueData =
            std::wstring(L"\"") + exePath + std::wstring(L"\" --autostart");

        lRes = RegSetValueExW(
            hKey, exeName, 0, REG_SZ, (const BYTE *)valueData.c_str(),
            static_cast<DWORD>((valueData.length() + 1) * sizeof(wchar_t)));
        RegCloseKey(hKey);

        if (lRes == ERROR_SUCCESS) {
          result->Success(flutter::EncodableValue(true));
          return;
        }
      }
    }
    result->Success(flutter::EncodableValue(false));
  } else if (method_call.method_name().compare("getLaunchArguments") == 0) {
    LPWSTR *szArglist;
    int nArgs;
    szArglist = CommandLineToArgvW(GetCommandLineW(), &nArgs);
    flutter::EncodableMap args_map;
    if (szArglist) {
      for (int i = 0; i < nArgs; i++) {
        std::wstring arg = szArglist[i];
        if (arg.find(L"--scheduled-task-id=") == 0) {
           args_map[flutter::EncodableValue("scheduledTaskId")] =
               flutter::EncodableValue(Utf16ToUtf8(arg.substr(20)));
         } else if (arg.find(L"--callback-handle=") == 0) {
          args_map[flutter::EncodableValue("callbackHandle")] =
               flutter::EncodableValue(std::stoll(arg.substr(18)));
        } else if (arg == L"--autostart") {
          args_map[flutter::EncodableValue("autostart")] =
              flutter::EncodableValue(true);
        }
      }
      LocalFree(szArglist);
    }
    result->Success(flutter::EncodableValue(args_map));
  } else if (method_call.method_name().compare("executeInBackground") == 0) {
    result->Success(flutter::EncodableValue(false));
  } else if (method_call.method_name().compare("scheduleTask") == 0) {
    const auto *arguments =
        std::get_if<flutter::EncodableMap>(method_call.arguments());
    if (arguments) {
      auto timestamp_it = arguments->find(flutter::EncodableValue("timestamp"));
      auto callback_it =
          arguments->find(flutter::EncodableValue("callbackHandle"));
      auto id_it = arguments->find(flutter::EncodableValue("taskId"));

      if (timestamp_it != arguments->end() && callback_it != arguments->end() &&
          id_it != arguments->end()) {
        int64_t timestamp = std::get<int64_t>(timestamp_it->second);
        int64_t callback = std::get<int64_t>(callback_it->second);
        std::string taskId = std::get<std::string>(id_it->second);

        bool success = RegisterScheduledTaskWindows(timestamp, taskId, callback);
        result->Success(flutter::EncodableValue(success));
        return;
      }
    }
    result->Error("INVALID_ARGUMENTS",
                  "Missing timestamp, taskId or callbackHandle");
  } else if (method_call.method_name().compare("startForegroundService") == 0 ||
             method_call.method_name().compare("stopForegroundService") == 0) {
    // Foreground services are an Android-specific concept.
    // Return false instead of NotImplemented to avoid muddying Dart console
    // logs.
    result->Success(flutter::EncodableValue(false));
  } else {
    result->NotImplemented();
  }
}

bool AutoStartFlutterPlugin::RegisterScheduledTaskWindows(
    int64_t timestamp, const std::string &taskId, int64_t callbackHandle) {
  HRESULT hr = CoInitializeEx(NULL, COINIT_MULTITHREADED);
  // It's okay if COM is already initialized
  bool comInitialized = SUCCEEDED(hr);

  ITaskService *pService = NULL;
  hr = CoCreateInstance(CLSID_TaskScheduler, NULL, CLSCTX_INPROC_SERVER,
                        IID_ITaskService, (void **)&pService);
  if (FAILED(hr)) {
    if (comInitialized)
      CoUninitialize();
    return false;
  }

  hr = pService->Connect(_variant_t(), _variant_t(), _variant_t(), _variant_t());
  if (FAILED(hr)) {
    pService->Release();
    if (comInitialized)
      CoUninitialize();
    return false;
  }

  ITaskFolder *pRootFolder = NULL;
  hr = pService->GetFolder(_bstr_t(L"\\"), &pRootFolder);
  if (FAILED(hr)) {
    pService->Release();
    if (comInitialized)
      CoUninitialize();
    return false;
  }

  // Remove task if it exists
  pRootFolder->DeleteTask(
      (_bstr_t(L"AutoStartFlutter_") + _bstr_t(taskId.c_str())).GetBSTR(), 0);

  ITaskDefinition *pTask = NULL;
  hr = pService->NewTask(0, &pTask);
  pService->Release();
  if (FAILED(hr)) {
    pRootFolder->Release();
    if (comInitialized)
      CoUninitialize();
    return false;
  }

  ITriggerCollection *pTriggers = NULL;
  hr = pTask->get_Triggers(&pTriggers);
  if (FAILED(hr)) {
    pRootFolder->Release();
    pTask->Release();
    if (comInitialized)
      CoUninitialize();
    return false;
  }

  ITrigger *pTrigger = NULL;
  hr = pTriggers->Create(TASK_TRIGGER_TIME, &pTrigger);
  pTriggers->Release();
  if (FAILED(hr)) {
    pRootFolder->Release();
    pTask->Release();
    if (comInitialized)
      CoUninitialize();
    return false;
  }

  ITimeTrigger *pTimeTrigger = NULL;
  hr = pTrigger->QueryInterface(IID_ITimeTrigger, (void **)&pTimeTrigger);
  pTrigger->Release();
  if (FAILED(hr)) {
    pRootFolder->Release();
    pTask->Release();
    if (comInitialized)
      CoUninitialize();
    return false;
  }

  // Convert milliseconds timestamp to ISO 8601 string for Task Scheduler
  // format: YYYY-MM-DDTHH:MM:SS
  time_t t = (time_t)(timestamp / 1000);
  struct tm tm_buf;
  gmtime_s(&tm_buf, &t);
  wchar_t timeStr[100];
  swprintf(timeStr, 100, L"%04d-%02d-%02dT%02d:%02d:%02dZ",
           tm_buf.tm_year + 1900, tm_buf.tm_mon + 1, tm_buf.tm_mday,
           tm_buf.tm_hour, tm_buf.tm_min, tm_buf.tm_sec);

  pTimeTrigger->put_StartBoundary(_bstr_t(timeStr));
  pTimeTrigger->Release();

  IActionCollection *pActions = NULL;
  hr = pTask->get_Actions(&pActions);
  if (FAILED(hr)) {
    pRootFolder->Release();
    pTask->Release();
    if (comInitialized)
      CoUninitialize();
    return false;
  }

  IAction *pAction = NULL;
  hr = pActions->Create(TASK_ACTION_EXEC, &pAction);
  pActions->Release();
  if (FAILED(hr)) {
    pRootFolder->Release();
    pTask->Release();
    if (comInitialized)
      CoUninitialize();
    return false;
  }

  IExecAction *pExecAction = NULL;
  hr = pAction->QueryInterface(IID_IExecAction, (void **)&pExecAction);
  pAction->Release();
  if (FAILED(hr)) {
    pRootFolder->Release();
    pTask->Release();
    if (comInitialized)
      CoUninitialize();
    return false;
  }

  wchar_t exePath[MAX_PATH];
  GetModuleFileNameW(NULL, exePath, MAX_PATH);

  std::wstring args = std::wstring(L"--scheduled-task-id=") +
                       Utf8ToUtf16(taskId) + L" --callback-handle=" +
                       std::to_wstring(callbackHandle);

  pExecAction->put_Path(_bstr_t(exePath));
  pExecAction->put_Arguments(_bstr_t(args.c_str()));
  pExecAction->Release();

  IRegisteredTask *pRegisteredTask = NULL;
  hr = pRootFolder->RegisterTaskDefinition(
      (_bstr_t(L"AutoStartFlutter_") + _bstr_t(taskId.c_str())).GetBSTR(), pTask,
      TASK_CREATE_OR_UPDATE, _variant_t(), _variant_t(),
      TASK_LOGON_INTERACTIVE_TOKEN, _variant_t(L""), &pRegisteredTask);

  pRootFolder->Release();
  pTask->Release();
  if (FAILED(hr)) {
    if (comInitialized)
      CoUninitialize();
    return false;
  }

  pRegisteredTask->Release();
  if (comInitialized)
    CoUninitialize();
  return true;
}

} // namespace auto_start_flutter


FLUTTER_PLUGIN_EXPORT void AutoStartFlutterPluginRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  auto_start_flutter::AutoStartFlutterPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
