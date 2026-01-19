package co.techFlow.auto_start_flutter

import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.provider.Settings
import java.util.Locale

object AutoStartIntents {

    fun getIntents(context: Context): List<Intent> {
        val intents = mutableListOf<Intent>()
        val manufacturer = Build.MANUFACTURER.lowercase(Locale.ROOT)

        when (manufacturer) {
            "xiaomi", "redmi", "poco" -> {
                intents.add(ComponentName("com.miui.securitycenter", "com.miui.permcenter.autostart.AutoStartManagementActivity").toIntent())
                intents.add(ComponentName("com.miui.securitycenter", "com.miui.powercenter.PowerSettings").toIntent())
            }
            "oppo" -> {
                intents.add(ComponentName("com.coloros.safecenter", "com.coloros.safecenter.permission.startup.StartupAppListActivity").toIntent())
                intents.add(ComponentName("com.coloros.safecenter", "com.coloros.safecenter.startupapp.StartupAppListActivity").toIntent())
                intents.add(ComponentName("com.oppo.safe", "com.oppo.safe.permission.startup.StartupAppListActivity").toIntent())
                intents.add(ComponentName("com.coloros.safe", "com.coloros.safe.permission.startup.StartupAppListActivity").toIntent())
                intents.add(ComponentName("com.coloros.safe", "com.coloros.safe.permission.startup.FakeActivity").toIntent())
                intents.add(ComponentName("com.coloros.safecenter", "com.coloros.safecenter.permission.startup.FakeActivity").toIntent())
            }
            "vivo" -> {
                intents.add(ComponentName("com.vivo.permissionmanager", "com.vivo.permissionmanager.activity.BgStartUpManagerActivity").toIntent())
                intents.add(ComponentName("com.iqoo.secure", "com.iqoo.secure.ui.phoneoptimize.AddWhiteListActivity").toIntent())
                intents.add(ComponentName("com.iqoo.secure", "com.iqoo.secure.ui.phoneoptimize.BgStartUpManager").toIntent())
            }
            "huawei", "honor" -> {
                intents.add(ComponentName("com.huawei.systemmanager", "com.huawei.systemmanager.startupmgr.ui.StartupNormalAppListActivity").toIntent())
                intents.add(ComponentName("com.huawei.systemmanager", "com.huawei.systemmanager.optimize.process.ProtectActivity").toIntent())
                intents.add(ComponentName("com.huawei.systemmanager", "com.huawei.systemmanager.appcontrol.activity.StartupAppControlActivity").toIntent())
                intents.add(ComponentName("com.hihonor.systemmanager", "com.hihonor.systemmanager.startupmgr.ui.StartupNormalAppListActivity").toIntent())
                intents.add(ComponentName("com.hihonor.systemmanager", "com.hihonor.systemmanager.optimize.process.ProtectActivity").toIntent())
                intents.add(ComponentName("com.hihonor.systemmanager", "com.hihonor.systemmanager.appcontrol.activity.StartupAppControlActivity").toIntent())
            }
            "samsung" -> {
                intents.add(ComponentName("com.samsung.android.lool", "com.samsung.android.sm.battery.ui.BatteryActivity").toIntent())
                intents.add(ComponentName("com.samsung.android.sm", "com.samsung.android.sm.ui.battery.BatteryActivity").toIntent())
                intents.add(ComponentName("com.samsung.android.lool", "com.samsung.android.sm.ui.battery.BatteryActivity").toIntent())
            }
            "oneplus" -> {
                intents.add(ComponentName("com.oneplus.security", "com.oneplus.security.chainlaunch.view.ChainLaunchAppListActivity").toIntent())
                // Newer OnePlus devices (ColorOS based)
                intents.add(ComponentName("com.coloros.safecenter", "com.coloros.safecenter.permission.startup.StartupAppListActivity").toIntent())
                intents.add(ComponentName("com.coloros.safecenter", "com.coloros.safecenter.startupapp.StartupAppListActivity").toIntent())
                intents.add(ComponentName("com.oppo.safe", "com.oppo.safe.permission.startup.StartupAppListActivity").toIntent())
                intents.add(ComponentName("com.coloros.safe", "com.coloros.safe.permission.startup.StartupAppListActivity").toIntent())
            }
            "infinix", "tecno", "itel" -> {
                 intents.add(ComponentName("com.transsion.phonemaster", "com.cyin.himgr.autostart.AutoStartActivity").toIntent())
            }
            "nokia" -> {
                intents.add(ComponentName("com.evenwell.powersaving.g3", "com.evenwell.powersaving.g3.exception.PowerSaverExceptionActivity").toIntent())
            }
            "asus" -> {
                intents.add(ComponentName("com.asus.mobilemanager", "com.asus.mobilemanager.autostart.AutoStartActivity").toIntent())
                intents.add(ComponentName("com.asus.mobilemanager", "com.asus.mobilemanager.entry.FunctionActivity").toIntent())
            }
            "letv" -> {
                 intents.add(ComponentName("com.letv.android.letvsafe", "com.letv.android.letvsafe.AutobootManageActivity").toIntent())
            }
            "meizu" -> {
                intents.add(ComponentName("com.meizu.safe", "com.meizu.safe.permission.SmartBGActivity").toIntent())
                intents.add(ComponentName("com.meizu.safe", "com.meizu.safe.permission.PermissionAppActivity").toIntent())
            }
            "htc" -> {
                 intents.add(ComponentName("com.htc.pitroad", "com.htc.pitroad.landingpage.activity.LandingPageActivity").toIntent())
            }
            "realme" -> {
                 if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                     intents.add(Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS))
                 }
            }
        }
        return intents
    }

    private fun ComponentName.toIntent(): Intent {
        return Intent().apply {
            component = this@toIntent
        }
    }
}
