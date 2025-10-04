package com.example.citadel_password_manager

import android.content.ComponentName
import android.content.Intent
import android.os.Bundle
import android.provider.Settings
import android.view.autofill.AutofillManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    companion object {
        private const val AUTOFILL_CHANNEL = "com.citadel/autofill"
        private const val CLIPBOARD_CHANNEL = "com.citadel/clipboard"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Register autofill status and settings channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, AUTOFILL_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getAutofillStatus" -> {
                    val autofillManager = getSystemService(AutofillManager::class.java)
                    val isEnabled = autofillManager?.hasEnabledAutofillServices() == true
                    result.success(isEnabled)
                }
                "openAutofillSettings" -> {
                    try {
                        val intent = Intent(Settings.ACTION_REQUEST_SET_AUTOFILL_SERVICE).apply {
                            data = android.net.Uri.parse(
                                "package:${applicationContext.packageName}"
                            )
                        }
                        startActivity(intent)
                        result.success(true)
                    } catch (e: Exception) {
                        // Fallback: open general autofill settings
                        try {
                            val fallbackIntent = Intent(Settings.ACTION_REQUEST_SET_AUTOFILL_SERVICE)
                            startActivity(fallbackIntent)
                            result.success(true)
                        } catch (_: Exception) {
                            result.error("SETTINGS_ERROR", "Cannot open autofill settings", null)
                        }
                    }
                }
                else -> result.notImplemented()
            }
        }

        // Register clipboard channel (bridge to native clipboard APIs)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CLIPBOARD_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "copy" -> {
                    val text = call.argument<String>("text") ?: ""
                    val isSensitive = call.argument<Boolean>("isSensitive") ?: true
                    val clipboardManager = getSystemService(android.content.ClipboardManager::class.java)
                    val clip = android.content.ClipData.newPlainText("Citadel", text)
                    if (isSensitive && android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.TIRAMISU) {
                        clip.description.extras = android.os.PersistableBundle().apply {
                            putBoolean("android.content.extra.IS_SENSITIVE", true)
                        }
                    }
                    clipboardManager?.setPrimaryClip(clip)
                    result.success(true)
                }
                "clear" -> {
                    val clipboardManager = getSystemService(android.content.ClipboardManager::class.java)
                    if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.P) {
                        clipboardManager?.clearPrimaryClip()
                    } else {
                        clipboardManager?.setPrimaryClip(
                            android.content.ClipData.newPlainText("", "")
                        )
                    }
                    result.success(true)
                }
                "scheduleClear" -> {
                    val delayMs = call.argument<Int>("delayMs") ?: 30000
                    android.os.Handler(mainLooper).postDelayed({
                        val clipboardManager = getSystemService(android.content.ClipboardManager::class.java)
                        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.P) {
                            clipboardManager?.clearPrimaryClip()
                        } else {
                            clipboardManager?.setPrimaryClip(
                                android.content.ClipData.newPlainText("", "")
                            )
                        }
                    }, delayMs.toLong())
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        handleAutofillIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleAutofillIntent(intent)
    }

    /**
     * Handle intents from the autofill service.
     * When the vault is locked and autofill is requested, the service
     * sends an intent with autofill_request=true to trigger unlock.
     */
    private fun handleAutofillIntent(intent: Intent?) {
        if (intent == null) return

        if (intent.getBooleanExtra("autofill_request", false)) {
            // The app was launched from autofill auth response -- show unlock screen.
            // The Flutter side handles this via the autofill channel state.
            flutterEngine?.dartExecutor?.binaryMessenger?.let { messenger ->
                MethodChannel(messenger, AUTOFILL_CHANNEL).invokeMethod(
                    "onAutofillAuthRequest", null
                )
            }
        }

        if (intent.getBooleanExtra("autofill_fill_complete", false)) {
            val vaultItemId = intent.getStringExtra("vault_item_id")
            if (vaultItemId != null) {
                flutterEngine?.dartExecutor?.binaryMessenger?.let { messenger ->
                    MethodChannel(messenger, AUTOFILL_CHANNEL).invokeMethod(
                        "onFillComplete", mapOf("vaultItemId" to vaultItemId)
                    )
                }
            }
        }
    }
}
