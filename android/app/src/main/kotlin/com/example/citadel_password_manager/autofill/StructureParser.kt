package com.example.citadel_password_manager.autofill

import android.app.assist.AssistStructure
import android.view.autofill.AutofillId

/**
 * Parsed result from traversing an [AssistStructure].
 *
 * Contains the autofill IDs for username and password fields,
 * the web domain (if any), and the requesting app's package name.
 */
data class ParsedStructure(
    val usernameId: AutofillId? = null,
    val passwordId: AutofillId? = null,
    val webDomain: String? = null,
    val packageName: String? = null,
    val allAutofillIds: List<AutofillId> = emptyList()
)

/**
 * Traverses an [AssistStructure] to locate username/password fields
 * and extract the web domain or package name for credential matching.
 */
object StructureParser {

    /**
     * Parse the given [structure] and return a [ParsedStructure] with
     * identified autofill fields and domain information.
     */
    fun parse(structure: AssistStructure): ParsedStructure {
        var usernameId: AutofillId? = null
        var passwordId: AutofillId? = null
        var webDomain: String? = null
        val allIds = mutableListOf<AutofillId>()

        for (i in 0 until structure.windowNodeCount) {
            val windowNode = structure.getWindowNodeAt(i)
            traverseNode(windowNode.rootViewNode) { node ->
                val autofillId = node.autofillId ?: return@traverseNode
                val hints = node.autofillHints

                // Extract web domain from the first node that reports one
                if (webDomain == null && !node.webDomain.isNullOrEmpty()) {
                    webDomain = node.webDomain
                }

                if (hints != null && hints.isNotEmpty()) {
                    allIds.add(autofillId)

                    for (hint in hints) {
                        when (hint) {
                            android.view.View.AUTOFILL_HINT_USERNAME,
                            android.view.View.AUTOFILL_HINT_EMAIL_ADDRESS -> {
                                if (usernameId == null) {
                                    usernameId = autofillId
                                }
                            }
                            android.view.View.AUTOFILL_HINT_PASSWORD -> {
                                if (passwordId == null) {
                                    passwordId = autofillId
                                }
                            }
                        }
                    }
                } else {
                    // Fallback: check HTML attributes for fields without hints
                    val htmlInfo = node.htmlInfo
                    if (htmlInfo != null && htmlInfo.tag?.equals("input", ignoreCase = true) == true) {
                        val attrs = htmlInfo.attributes
                        val typeAttr = attrs?.firstOrNull {
                            it.first.equals("type", ignoreCase = true)
                        }?.second

                        when (typeAttr?.lowercase()) {
                            "email", "text" -> {
                                if (usernameId == null) {
                                    allIds.add(autofillId)
                                    usernameId = autofillId
                                }
                            }
                            "password" -> {
                                if (passwordId == null) {
                                    allIds.add(autofillId)
                                    passwordId = autofillId
                                }
                            }
                        }
                    }
                }
            }
        }

        val packageName = structure.activityComponent?.packageName

        return ParsedStructure(
            usernameId = usernameId,
            passwordId = passwordId,
            webDomain = webDomain,
            packageName = packageName,
            allAutofillIds = allIds
        )
    }

    /**
     * Recursively traverse the view node tree in depth-first order.
     */
    private fun traverseNode(
        node: AssistStructure.ViewNode?,
        visitor: (AssistStructure.ViewNode) -> Unit
    ) {
        if (node == null) return
        visitor(node)
        for (i in 0 until node.childCount) {
            traverseNode(node.getChildAt(i), visitor)
        }
    }
}
