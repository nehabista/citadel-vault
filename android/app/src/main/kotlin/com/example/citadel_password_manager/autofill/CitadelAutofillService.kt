package com.example.citadel_password_manager.autofill

import android.os.Build
import android.os.CancellationSignal
import android.service.autofill.AutofillService
import android.service.autofill.FillCallback
import android.service.autofill.FillRequest
import android.service.autofill.InlineSuggestionsRequest
import android.service.autofill.SaveCallback
import android.service.autofill.SaveRequest
import android.util.Log
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel
import java.security.MessageDigest

/**
 * Android AutofillService implementation for Citadel Password Manager.
 *
 * This service makes Citadel a system-level autofill provider. When a user
 * focuses a login field in any app or browser, Android invokes [onFillRequest].
 * The service parses the view structure, queries the encrypted vault via
 * a Flutter MethodChannel, and returns matching credentials as autofill datasets.
 *
 * If the vault is locked, an authentication response redirects the user to
 * the main app for unlock before filling.
 */
class CitadelAutofillService : AutofillService() {

    companion object {
        private const val TAG = "CitadelAutofill"
        private const val CHANNEL_NAME = "com.citadel/autofill"
    }

    private var flutterEngine: FlutterEngine? = null
    private var channel: MethodChannel? = null

    override fun onCreate() {
        super.onCreate()
        try {
            flutterEngine = FlutterEngine(this).also { engine ->
                engine.dartExecutor.executeDartEntrypoint(
                    DartExecutor.DartEntrypoint.createDefault()
                )
                channel = MethodChannel(engine.dartExecutor.binaryMessenger, CHANNEL_NAME)
            }
        } catch (e: Exception) {
            Log.e(TAG, "Failed to initialize FlutterEngine", e)
        }
    }

    override fun onFillRequest(
        request: FillRequest,
        cancellationSignal: CancellationSignal,
        callback: FillCallback
    ) {
        val structure = request.fillContexts.lastOrNull()?.structure
        if (structure == null) {
            callback.onSuccess(null)
            return
        }

        val parsed = StructureParser.parse(structure)

        // No autofillable fields found
        if (parsed.usernameId == null && parsed.passwordId == null) {
            callback.onSuccess(null)
            return
        }

        // If engine not ready, return auth response to open app
        val currentChannel = channel
        if (currentChannel == null) {
            try {
                callback.onSuccess(AutofillResponseBuilder.buildAuthResponse(this, parsed))
            } catch (e: Exception) {
                Log.e(TAG, "Failed to build auth response", e)
                callback.onSuccess(null)
            }
            return
        }

        // Compute domain and package hashes for credential lookup
        val domainHash = parsed.webDomain?.let { sha256Hex(it) }
        val packageHash = parsed.packageName?.let { sha256Hex(it) }

        val args = mapOf(
            "domainHash" to domainHash,
            "packageHash" to packageHash
        )

        // Extract inline suggestion request for Android 11+
        val inlineRequest: InlineSuggestionsRequest? = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            request.inlineSuggestionsRequest
        } else {
            null
        }

        currentChannel.invokeMethod("queryCredentials", args, object : MethodChannel.Result {
            override fun success(result: Any?) {
                if (cancellationSignal.isCanceled) return

                try {
                    @Suppress("UNCHECKED_CAST")
                    val credentials = result as? List<Map<String, Any?>>

                    if (credentials != null && credentials.isNotEmpty()) {
                        val fillResponse = AutofillResponseBuilder.buildFillResponse(
                            this@CitadelAutofillService,
                            credentials,
                            parsed,
                            inlineRequest
                        )
                        callback.onSuccess(fillResponse)
                    } else {
                        // No matching credentials, show auth prompt to unlock/search
                        callback.onSuccess(
                            AutofillResponseBuilder.buildAuthResponse(
                                this@CitadelAutofillService, parsed
                            )
                        )
                    }
                } catch (e: Exception) {
                    Log.e(TAG, "Error building fill response", e)
                    callback.onSuccess(null)
                }
            }

            override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
                Log.e(TAG, "queryCredentials error: $errorCode - $errorMessage")
                if (!cancellationSignal.isCanceled) {
                    callback.onSuccess(null)
                }
            }

            override fun notImplemented() {
                Log.w(TAG, "queryCredentials not implemented on Dart side")
                if (!cancellationSignal.isCanceled) {
                    callback.onSuccess(null)
                }
            }
        })
    }

    override fun onSaveRequest(request: SaveRequest, callback: SaveCallback) {
        // Save not implemented in v1 -- users add credentials through the app UI
        callback.onSuccess()
    }

    override fun onDestroy() {
        flutterEngine?.destroy()
        flutterEngine = null
        channel = null
        super.onDestroy()
    }

    /**
     * Compute SHA-256 hash of the input string and return as lowercase hex.
     * Used for domain and package name hashing per zero-knowledge design.
     */
    private fun sha256Hex(input: String): String {
        val digest = MessageDigest.getInstance("SHA-256")
        val hashBytes = digest.digest(input.toByteArray(Charsets.UTF_8))
        return hashBytes.joinToString("") { "%02x".format(it) }
    }
}
