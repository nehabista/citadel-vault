package com.example.citadel_password_manager.autofill

import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.service.autofill.Dataset
import android.service.autofill.FillResponse
import android.service.autofill.InlineSuggestionsRequest
import android.view.autofill.AutofillValue
import android.widget.RemoteViews
import com.example.citadel_password_manager.MainActivity
import com.example.citadel_password_manager.R

/**
 * Builds [FillResponse] objects containing credential [Dataset]s
 * for the Android Autofill Framework.
 */
object AutofillResponseBuilder {

    private const val MAX_DATASETS = 5
    private const val AUTH_REQUEST_CODE = 1001

    /**
     * Build a [FillResponse] with datasets for the given [credentials].
     *
     * @param context       Android context for RemoteViews and PendingIntent
     * @param credentials   List of credential maps from Flutter vault query
     * @param parsed        Parsed structure with autofill IDs
     * @param inlineRequest Inline suggestions request (Android 11+), nullable
     * @return              A [FillResponse] or null if no credentials
     */
    fun buildFillResponse(
        context: Context,
        credentials: List<Map<String, Any?>>,
        parsed: ParsedStructure,
        inlineRequest: InlineSuggestionsRequest?
    ): FillResponse? {
        if (credentials.isEmpty()) return null

        val responseBuilder = FillResponse.Builder()

        credentials.take(MAX_DATASETS).forEachIndexed { index, credential ->
            val displayName = credential["displayName"] as? String ?: "Citadel"
            val username = credential["username"] as? String ?: ""
            val password = credential["password"] as? String ?: ""
            val vaultItemId = credential["id"] as? String

            val datasetBuilder = Dataset.Builder()

            // Dropdown presentation via RemoteViews
            val presentation = RemoteViews(context.packageName, R.layout.autofill_dataset)
            presentation.setTextViewText(R.id.title, displayName)
            presentation.setTextViewText(R.id.subtitle, username)

            // Set username field value
            if (parsed.usernameId != null) {
                datasetBuilder.setValue(
                    parsed.usernameId,
                    AutofillValue.forText(username),
                    presentation
                )
            }

            // Set password field value
            if (parsed.passwordId != null) {
                val pwPresentation = if (parsed.usernameId == null) {
                    // Only show presentation on password if no username field
                    presentation
                } else {
                    RemoteViews(context.packageName, R.layout.autofill_dataset).also {
                        it.setTextViewText(R.id.title, displayName)
                        it.setTextViewText(R.id.subtitle, username)
                    }
                }
                datasetBuilder.setValue(
                    parsed.passwordId,
                    AutofillValue.forText(password),
                    pwPresentation
                )
            }

            // Inline suggestions for Android 11+ keyboards
            if (inlineRequest != null && Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                val inlinePresentation = InlinePresenter.build(
                    context, displayName, username, inlineRequest, index
                )
                if (inlinePresentation != null) {
                    if (parsed.usernameId != null) {
                        datasetBuilder.setValue(
                            parsed.usernameId,
                            AutofillValue.forText(username),
                            presentation,
                            inlinePresentation
                        )
                    }
                    if (parsed.passwordId != null) {
                        val pwPres = RemoteViews(context.packageName, R.layout.autofill_dataset).also {
                            it.setTextViewText(R.id.title, displayName)
                            it.setTextViewText(R.id.subtitle, username)
                        }
                        datasetBuilder.setValue(
                            parsed.passwordId,
                            AutofillValue.forText(password),
                            pwPres,
                            inlinePresentation
                        )
                    }
                }
            }

            // PendingIntent for fill-complete callback (e.g., TOTP auto-copy)
            if (vaultItemId != null) {
                val callbackIntent = Intent(context, MainActivity::class.java).apply {
                    putExtra("autofill_fill_complete", true)
                    putExtra("vault_item_id", vaultItemId)
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK
                }
                val pendingIntent = PendingIntent.getActivity(
                    context,
                    index,
                    callbackIntent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                datasetBuilder.setAuthentication(pendingIntent.intentSender)
            }

            try {
                responseBuilder.addDataset(datasetBuilder.build())
            } catch (_: Exception) {
                // Skip datasets that fail to build (e.g., no values set)
            }
        }

        return try {
            responseBuilder.build()
        } catch (_: Exception) {
            null
        }
    }

    /**
     * Build an authentication response for when the vault is locked.
     * Directs the user to the main app for unlock before autofilling.
     *
     * @param context Android context
     * @param parsed  Parsed structure with collected autofill IDs
     * @return        A [FillResponse] requiring authentication
     */
    fun buildAuthResponse(context: Context, parsed: ParsedStructure): FillResponse {
        val authIntent = Intent(context, MainActivity::class.java).apply {
            putExtra("autofill_request", true)
            flags = Intent.FLAG_ACTIVITY_NEW_TASK
        }

        val pendingIntent = PendingIntent.getActivity(
            context,
            AUTH_REQUEST_CODE,
            authIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val presentation = RemoteViews(context.packageName, R.layout.autofill_auth)

        val responseBuilder = FillResponse.Builder()

        val autofillIds = parsed.allAutofillIds.toTypedArray()
        if (autofillIds.isNotEmpty()) {
            responseBuilder.setAuthentication(
                autofillIds,
                pendingIntent.intentSender,
                presentation
            )
        }

        return responseBuilder.build()
    }
}
