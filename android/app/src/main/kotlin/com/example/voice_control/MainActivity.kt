package com.example.voice_control

import android.content.Intent
import android.provider.Settings
import android.util.Log
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
                }
                "clickAt" -> {
                    val x = call.argument<Int>("x")
                    val y = call.argument<Int>("y")
                    if (x != null && y != null) {
                        MyAccessibilityService.getInstance()?.simulateClickOnCoordinates(x.toFloat(), y.toFloat())
                        Log.d("MyTag", "Simulated click at $x, $y")
                    } else {
                        result.error("INVALID_ARGUMENTS", "Invalid or missing arguments", null)
                    }
                } else -> result.notImplemented()
            }
        }
    }


    private fun openAccessibility() {
        val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)
        startActivity(intent)
    }

}
