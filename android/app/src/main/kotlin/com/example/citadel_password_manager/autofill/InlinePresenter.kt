package com.example.citadel_password_manager.autofill

import android.app.slice.Slice
import android.content.Context
import android.graphics.drawable.Icon
import android.os.Build
import android.service.autofill.InlineSuggestionsRequest
import android.widget.inline.InlineContentView
import android.widget.inline.InlinePresentationSpec
import androidx.annotation.RequiresApi
import androidx.autofill.inline.UiVersions
import androidx.autofill.inline.v1.InlineSuggestionUi
import com.example.citadel_password_manager.R

/**
 * Builds inline presentations for Android 11+ keyboard autofill suggestions.
 *
 * Inline suggestions appear directly in the keyboard IME area,
 * providing a more seamless autofill experience.
 */
object InlinePresenter {

    /**
     * Build an [android.service.autofill.InlinePresentation] for the given credential.
     *
     * @param context       Android context for icon loading
     * @param title         Display name of the credential
     * @param subtitle      Username/email of the credential
     * @param inlineRequest The inline suggestions request from the IME
     * @param index         Index of this suggestion (keyboard has limited slots)
     * @return              An InlinePresentation, or null if index exceeds available specs
     */
    @RequiresApi(Build.VERSION_CODES.R)
    fun build(
        context: Context,
        title: String,
        subtitle: String,
        inlineRequest: InlineSuggestionsRequest,
        index: Int
    ): android.service.autofill.InlinePresentation? {
        val specs = inlineRequest.inlinePresentationSpecs
        if (index >= specs.size) return null

        val spec = specs[index]

        // Check if the IME supports v1 inline suggestions
        val style = spec.style
        if (!UiVersions.getVersions(style).contains(UiVersions.INLINE_UI_VERSION_1)) {
            return null
        }

        val contentBuilder = InlineSuggestionUi.newContentBuilder(spec.style)
        contentBuilder.setTitle(title)
        contentBuilder.setSubtitle(subtitle)

        try {
            val icon = Icon.createWithResource(context, R.mipmap.launcher_icon)
            contentBuilder.setStartIcon(icon)
        } catch (_: Exception) {
            // Icon loading may fail; continue without icon
        }

        val slice = contentBuilder.build().slice

        return android.service.autofill.InlinePresentation(slice, spec, false)
    }
}
