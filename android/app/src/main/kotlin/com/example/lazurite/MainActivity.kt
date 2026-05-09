package org.stormlightlabs.lazurite

import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onPause() {
        clearLockInterferingWindowFlags()
        super.onPause()
    }

    override fun onStop() {
        clearLockInterferingWindowFlags()
        super.onStop()
    }

    private fun clearLockInterferingWindowFlags() {
        window.clearFlags(
            WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON or
                WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON or
                WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD
        )
    }
}
