package com.example.voice_control

import android.app.AppOpsManager
import android.app.usage.UsageStats
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel


class MainActivity: FlutterActivity() {
    private val channel = "widgets-channel"
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel)
        FlutterCommunication.setMethodChannel(methodChannel)
        methodChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "getWidgets" -> {
                    val packageName = call.argument<String>("packageName")
                    if (packageName != null) {
                        val widgets = MyAccessibilityService.getInstance()?.getWindowContent()
                        result.success(widgets)
                    } else {
                        result.error("INVALID_PACKAGE_NAME", "Package name is null or empty", null)
                    }
                }
                "openAccessibilitySettings" -> {
                    openAccessibility()
                    requestUsageStatsPermission()
                }
                "clickAt" -> {
                    val x = call.argument<Int>("x")
                    val y = call.argument<Int>("y")
                    if (x != null && y != null) {
                        MyAccessibilityService.getInstance()?.simulateClickOnCoordinates(x.toFloat(), y.toFloat())
                    } else {
                        result.error("INVALID_ARGUMENTS", "Invalid or missing arguments", null)
                    }
                }
                "getOpenedApplication" -> {
                    val packageName = getCurrentlyOpenedApplication(this)
                    if (packageName != null) {
                        result.success(packageName)
                    } else {
                        result.error("NULL_PACKAGE_NAME", "Failed to get the currently opened application", null)
                    }
                } else -> result.notImplemented()
            }
        }
    }


    private fun openAccessibility() {
        val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)
        startActivity(intent)
    }

    private fun getCurrentlyOpenedApplication(context: Context): String? {
        val usageStatsManager = context.getSystemService(USAGE_STATS_SERVICE) as UsageStatsManager
        val currentTime = System.currentTimeMillis()
        val usageStatsList = usageStatsManager.queryUsageStats(
            UsageStatsManager.INTERVAL_DAILY,
            currentTime - 1000 * 60 * 60,
            currentTime
        )
        if (usageStatsList != null && !usageStatsList.isEmpty()) {
            var recentUsageStat: UsageStats? = null
            for (usageStat in usageStatsList) {
                if (recentUsageStat == null || recentUsageStat.lastTimeUsed < usageStat.lastTimeUsed) {
                    recentUsageStat = usageStat
                }
            }
            return recentUsageStat!!.packageName
        }
        return null
    }

    @Suppress("DEPRECATION")
    private fun checkUsageStatsPermission(context: Context): Boolean {
        val appOpsManager = context.getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = appOpsManager.checkOpNoThrow(
            AppOpsManager.OPSTR_GET_USAGE_STATS,
            android.os.Process.myUid(),
            context.packageName
        )
        return mode == AppOpsManager.MODE_ALLOWED
    }

    private fun requestUsageStatsPermission() {
        val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS)
        context.startActivity(intent)
    }
}
