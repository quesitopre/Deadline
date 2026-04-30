package com.example.deadline_app

import android.content.Intent
import android.content.SharedPreferences
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity(){
    private val CHANNEL = "deadline_app/blocker"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                val prefs = getSharedPreferences("blocker_prefs", MODE_PRIVATE)
                when (call.method) {
                   "updateBlockedApps" -> {
                        val apps = call.argument<List<String>>("apps") ?: emptyList()
                        prefs.edit().putString("blocked_apps", apps.joinToString(",")).apply()
                        result.success(null)
                    }
                    "updateTimerState" -> {
                        val running = call.argument<Boolean>("running") ?: false
                        prefs.edit().putBoolean("timer_running", running).apply()
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
}

override fun onNewIntent(intent: Intent) {
    super.onNewIntent(intent)
    if (intent.action == "SHOW_OVERLAY") {
        val appName = intent.getStringExtra("appName") ?: return
        val prefs = getSharedPreferences("blocker_prefs", MODE_PRIVATE)
        val blockedApps = prefs.getString("blocked_apps", "")
            ?.split(",")?.filter { it.isNotEmpty() } ?: emptyList()
        val isTimerRunning = prefs.getBoolean("timer_running", false)

            //show overlay if app is on blocked list
        if (blockedApps.contains(appName) && isTimerRunning) {
            MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CHANNEL)
                .invokeMethod("showOverlay", mapOf("appName" to appName))
            }
        }
    }
}