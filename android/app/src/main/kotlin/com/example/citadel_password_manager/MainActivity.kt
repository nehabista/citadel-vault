package com.example.citadel_password_manager

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.example.citadel_password_manager.clipboard.ClipboardHelper

class MainActivity : FlutterActivity() {

    private val clipboardChannel = "com.citadel/clipboard"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Register clipboard MethodChannel for sensitive copy and auto-clear.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, clipboardChannel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "copy" -> {
                        val text = call.argument<String>("text") ?: ""
                        val isSensitive = call.argument<Boolean>("isSensitive") ?: true
                        ClipboardHelper.copyToClipboard(this, text, isSensitive)
                        result.success(null)
                    }
                    "clear" -> {
                        ClipboardHelper.clearClipboard(this)
                        result.success(null)
                    }
                    "scheduleClear" -> {
                        val delayMs = call.argument<Number>("delayMs")?.toLong() ?: 30000L
                        ClipboardHelper.scheduleClipboardClear(this, delayMs)
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
