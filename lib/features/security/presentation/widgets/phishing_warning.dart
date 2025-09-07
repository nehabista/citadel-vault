import 'package:flutter/material.dart';

import '../../data/services/domain_comparator.dart';

/// Dismissable phishing warning banner shown when saved and target domains
/// do not match.
///
/// Per D-16: domain mismatch warnings for phishing defense.
/// Per D-17: builds UI only; Phase 4 wires into autofill service.
class PhishingWarning extends StatefulWidget {
  const PhishingWarning({
    super.key,
    required this.savedUrl,
    required this.targetUrl,
    this.onCancel,
    this.onProceed,
  });

  /// The URL saved in the vault item.
  final String savedUrl;

  /// The URL of the site requesting autofill.
  final String targetUrl;

  /// Called when the user cancels (do not autofill).
  final VoidCallback? onCancel;

  /// Called when the user chooses to proceed despite the mismatch.
  final VoidCallback? onProceed;

  @override
  State<PhishingWarning> createState() => _PhishingWarningState();
}

class _PhishingWarningState extends State<PhishingWarning> {
  bool _dismissed = false;

  @override
  Widget build(BuildContext context) {
    // If domains match or banner was dismissed, show nothing.
    if (_dismissed ||
        DomainComparator.domainsMatch(widget.savedUrl, widget.targetUrl)) {
      return const SizedBox.shrink();
    }

    final savedDomain =
        DomainComparator.extractDomain(widget.savedUrl) ?? widget.savedUrl;
    final targetDomain =
        DomainComparator.extractDomain(widget.targetUrl) ?? widget.targetUrl;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade700, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded,
                  color: Colors.amber.shade800, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Domain Mismatch Detected!',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Colors.amber.shade900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Saved: $savedDomain\nTarget: $targetDomain\n\n'
            'This could be a phishing attempt.',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              color: Colors.amber.shade900,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  setState(() => _dismissed = true);
                  widget.onCancel?.call();
                },
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Colors.amber.shade900),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () {
                  setState(() => _dismissed = true);
                  widget.onProceed?.call();
                },
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.amber.shade700,
                ),
                child: const Text('Proceed Anyway'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
