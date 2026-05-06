package com.example.deadline_app

import android.accessibilityservice.AccessibilityService
import android.content.Intent
import android.view.accessibility.AccessibilityEvent
import android.os.SystemClock

class AppBlockerService : AccessibilityService() {

    // Must match your Flutter blockedApps list
    private val blockedPackages = mapOf(
        "Youtube"    to "com.google.android.youtube",
        "Instagram"  to "com.instagram.android",
        "Tiktok"     to "com.zhiliaoapp.musically",
        "Twitter/X"  to "com.twitter.android",
        "Reddit"     to "com.reddit.frontpage",
        "Snapchat"   to "com.snapchat.android",
    )

    private var lastOverlayTime = 0L
    private val COOLDOWN_MS = 3000L // 3 second cooldown between triggers

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event?.eventType != AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) return
        val pkg = event.packageName?.toString() ?: return
        if (pkg == "com.example.deadline_app") return 

        val appName = blockedPackages.entries
        .firstOrNull { it.value == pkg }?.key 
        ?: return
        
        //Read SharedPreferences
        val prefs = getSharedPreferences("blocker_prefs", MODE_PRIVATE)
        val blockedApps = prefs.getString("blocked_apps", "")
            ?.split(",")?.filter { it.isNotEmpty() } ?: emptyList()
        val isTimerRunning = prefs.getBoolean("timer_running", false)

        if (!blockedApps.contains(appName) || !isTimerRunning) return // 

        val now = SystemClock.elapsedRealtime()
        if (now - lastOverlayTime < COOLDOWN_MS) return
        lastOverlayTime = now

        // Send intent to MainActivity to trigger the Flutter overlay
        val intent = Intent(this, MainActivity::class.java).apply {
            action = "SHOW_OVERLAY"
            putExtra("appName", appName)
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP
        }
        startActivity(intent)
    }
    override fun onInterrupt() {}
}