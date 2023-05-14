package com.example.voice_control

import android.accessibilityservice.AccessibilityService
import android.graphics.Rect
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo
import android.util.Log
import android.graphics.Path
import android.accessibilityservice.GestureDescription
import android.content.Context
import android.graphics.Color
import android.os.Build
import android.graphics.PixelFormat
import android.view.Gravity
import android.view.WindowManager
import android.widget.FrameLayout


class MyAccessibilityService : AccessibilityService() {

    override fun onAccessibilityEvent(event: AccessibilityEvent) {
        when (event.eventType) {
            AccessibilityEvent.TYPE_VIEW_CLICKED -> {
                val clickedNodeInfo = event.source
                val rect = Rect()
                clickedNodeInfo?.getBoundsInScreen(rect)
                FlutterCommunication.sendClickedViewInfo(clickedNodeInfo?.packageName, rect.centerX(), rect.centerY())
            }
        }
    }

    override fun onInterrupt() {
        // Handle service interruptions, if necessary
    }

    companion object {
        private var instance: MyAccessibilityService? = null

        fun getInstance(): MyAccessibilityService? {
            return instance
        }
    }

    override fun onCreate() {
        super.onCreate()
        instance = this
        Log.d("MyTag", "onCreate")
    }

    override fun onDestroy() {
        super.onDestroy()
        instance = null
        Log.d("MyTag", "onDestroy")
    }

    fun getWindowContent(): List<Map<String, Any?>>? {
        val rootNodeInfo = rootInActiveWindow ?: return null
        val widgets = findNodes(rootNodeInfo)
//        lightenNode(widgets.last())
        Log.d("MyMAP", "LENGTH: ${widgets.size}")
        return widgets.map { accessibilityNodeInfoToMap(it) }
    }

    private fun findNodes(nodeInfo: AccessibilityNodeInfo): List<AccessibilityNodeInfo> {
        val nodes = mutableListOf<AccessibilityNodeInfo>()

        for (i in 0 until nodeInfo.childCount) {
            val childNode = nodeInfo.getChild(i)
            nodes.add(childNode)
            nodes.addAll(findNodes(childNode))
        }

        return nodes
    }

    private fun accessibilityNodeInfoToMap(nodeInfo: AccessibilityNodeInfo): Map<String, Any?> {
        val map = mutableMapOf<String, Any?>()

        map["packageName"] = nodeInfo.packageName
        map["className"] = nodeInfo.className
        map["text"] = nodeInfo.text
        map["contentDescription"] = nodeInfo.contentDescription
        map["viewIdResourceName"] = nodeInfo.viewIdResourceName
        map["window"] = nodeInfo.window
        map["hashCode"] = nodeInfo.hashCode()
        map["id"] = nodeInfo.toString()

        Log.d("MyMAP", "$nodeInfo")

        return map
    }


    private fun createTapPath(x: Float, y: Float): Path {
        val path = Path()
        path.moveTo(x, y)
        Log.d("MyTag", "Created path $x, $y")
        return path
    }

    fun simulateClickOnCoordinates(x: Float, y: Float) {
        Log.d("MyTag", "OUTER")
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            Log.d("MyTag", "INNER")
            val path = createTapPath(x, y)
            val gestureBuilder = GestureDescription.Builder()
            gestureBuilder.addStroke(GestureDescription.StrokeDescription(path, 0L, 75L))
            val gesture = gestureBuilder.build()

            dispatchGesture(gesture, object : GestureResultCallback() {
                override fun onCompleted(gestureDescription: GestureDescription?) {
                    super.onCompleted(gestureDescription)
                    Log.d("MyTag", "Gesture completed")
                }

                override fun onCancelled(gestureDescription: GestureDescription?) {
                    super.onCancelled(gestureDescription)
                    Log.d("MyTag", "Gesture cancelled")
                }
            }, null)
        } else {
            Log.e("MyTag", "API level is lower than 21, dispatchGesture is not available")
        }
    }

    private fun lightenNode(node: AccessibilityNodeInfo?) {
        if (node == null) return

        // Highlight the node with an overlay
        createOverlay(node)

        // Process the node's children
        for (i in 0 until node.childCount) {
            lightenNode(node.getChild(i))
        }
    }

    private fun createOverlay(node: AccessibilityNodeInfo) {
        val windowManager = getSystemService(Context.WINDOW_SERVICE) as WindowManager

        val params = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            WindowManager.LayoutParams(
                WindowManager.LayoutParams.WRAP_CONTENT,
                WindowManager.LayoutParams.WRAP_CONTENT,
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
                WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS,
                PixelFormat.TRANSLUCENT
            )
        } else {
            TODO("VERSION.SDK_INT < O")
        }
        params.gravity = Gravity.START or Gravity.TOP

        val overlay = FrameLayout(this)
        overlay.setBackgroundColor(Color.argb(100, 255, 241, 118))

        // Get the bounds of the target view
        val boundsInScreen = Rect()
        node.getBoundsInScreen(boundsInScreen)

        // Set the overlay position and size to match the target view
        params.x = boundsInScreen.left
        params.y = boundsInScreen.top
        params.width = boundsInScreen.width()
        params.height = boundsInScreen.height()

        windowManager.addView(overlay, params)
    }
}