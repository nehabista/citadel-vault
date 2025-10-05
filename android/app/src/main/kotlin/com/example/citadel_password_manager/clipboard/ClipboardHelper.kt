package com.example.citadel_password_manager.clipboard

import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.PersistableBundle

/// Native clipboard helper for Android autofill integration.
///
/// Handles:
/// - EXTRA_IS_SENSITIVE flag on Android 13+ (API 33) per D-15
/// - Native timer-based clipboard clear that works when app is backgrounded per D-14
/// - Clipboard clear for older Android versions per D-14
object ClipboardHelper {

    private var clearHandler: Handler? = null
    private var clearRunnable: Runnable? = null

    /// Copy text to clipboard with optional sensitive flag.
    ///
    /// On Android 13+ (API 33), sets android.content.extra.IS_SENSITIVE to true
    /// which prevents the clipboard content from appearing in visual clipboard
    /// previews on the lock screen or in keyboard suggestions.
    fun copyToClipboard(context: Context, text: String, isSensitive: Boolean) {
        val clipboardManager = context.getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
        val clipData = ClipData.newPlainText("credential", text)

        if (isSensitive && Build.VERSION.SDK_INT >= 33) {
            clipData.description.extras = PersistableBundle().apply {
                putBoolean("android.content.extra.IS_SENSITIVE", true)
            }
        }

        clipboardManager.setPrimaryClip(clipData)
    }

    /// Clear the clipboard contents.
    ///
    /// On Android 9+ (API 28), uses clearPrimaryClip().
    /// On older versions, sets empty text as a fallback.
    fun clearClipboard(context: Context) {
        val clipboardManager = context.getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager

        if (Build.VERSION.SDK_INT >= 28) {
            clipboardManager.clearPrimaryClip()
        } else {
            clipboardManager.setPrimaryClip(ClipData.newPlainText("", ""))
        }
    }

    /// Schedule clipboard clear after a delay.
    ///
    /// Uses Handler on main looper so the timer works even when the app
    /// is backgrounded. Cancels any previously scheduled clear.
    fun scheduleClipboardClear(context: Context, delayMs: Long) {
        // Cancel any existing scheduled clear
        cancelScheduledClear()

        clearHandler = Handler(Looper.getMainLooper())
        clearRunnable = Runnable { clearClipboard(context) }
        clearHandler?.postDelayed(clearRunnable!!, delayMs)
    }

    /// Cancel any previously scheduled clipboard clear.
    private fun cancelScheduledClear() {
        clearRunnable?.let { clearHandler?.removeCallbacks(it) }
        clearHandler = null
        clearRunnable = null
    }
}
