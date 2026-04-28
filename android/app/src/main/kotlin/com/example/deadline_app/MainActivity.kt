package com.example.deadline_app

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity(){
    private val CHANNEL = "deadline_app/blocker"
    private var blockedApps: List<String> = emptyList()

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "updateBlockedApps") {
                    blockedApps = call.argument<List<String>>("apps") ?: emptyList()
                    result.success(null)
                }
            }
}
override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        if (intent.action == "SHOW_OVERLAY") {
            val appName = intent.getStringExtra("appName") ?: return

            //show overlay if app is on blocked list
            if (blockedApps.contains(appName)){
                MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CHANNEL)
                    .invokeMethod("showOverlay", mapOf("appName" to appName))
            }
        }
    }
}
