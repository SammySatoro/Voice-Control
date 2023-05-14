package com.example.voice_control

import io.flutter.plugin.common.MethodChannel

object FlutterCommunication {
    private var methodChannel: MethodChannel? = null

    fun setMethodChannel(channel: MethodChannel) {
        methodChannel = channel
    }

    fun sendWidgets(widgets: List<String>) {
        methodChannel?.invokeMethod("onWidgets", widgets)
    }

    fun sendClickedViewInfo(packageName: CharSequence?, x: Int, y: Int) {
        methodChannel?.invokeMethod("onViewClicked", mapOf("packageName" to packageName, "x" to x, "y" to y))
    }
}