package com.example.deadline_app

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity(){
    private val CHANNEL = "deadline_app/blocker"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
}
override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        if (intent.action == "SHOW_OVERLAY") {
            val appName = intent.getStringExtra("appName") ?: return
            MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CHANNEL)
                .invokeMethod("showOverlay", mapOf("appName" to appName))
        }
    }
}
