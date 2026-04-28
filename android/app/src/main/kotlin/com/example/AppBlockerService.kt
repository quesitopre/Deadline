package com.example.deadline_app

import android.accessibilityservice.AccessibilityService
import android.content.Intent
import android.view.accessibility.AccessibilityEvent

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

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event?.eventType != AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) return
        val pkg = event.packageName?.toString() ?: return
        val appName = blockedPackages.entries.firstOrNull { it.value == pkg }?.key ?: return

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