/// Domain extraction and comparison for phishing defense.
///
/// Per D-15: Simple domain extraction that takes the last 2 segments
/// of the hostname as the registered domain. Does not handle compound
/// TLDs like .co.uk (acceptable tradeoff for v1).
///
/// This is a static utility class with pure functions and no external
/// dependencies. Phase 4 wires this into the autofill service per D-17.
class DomainComparator {
  // Prevent instantiation.
  DomainComparator._();

  /// Extract the registered domain from a URL string.
  ///
  /// Returns the last two segments of the hostname (e.g., "example.com").
  /// Returns null for null or empty input.
  ///
  /// Examples:
  /// - "https://login.example.com/path" -> "example.com"
  /// - "https://www.example.com" -> "example.com"
  /// - "example.com" -> "example.com"
  /// - null -> null
  /// - "" -> null
  static String? extractDomain(String? urlString) {
    if (urlString == null || urlString.isEmpty) {
      return null;
    }

    String normalized = urlString.trim().toLowerCase();

    // Add scheme if missing so Uri.parse works correctly
    if (!normalized.contains('://')) {
      normalized = 'https://$normalized';
    }

    try {
      final uri = Uri.parse(normalized);
      final host = uri.host;

      if (host.isEmpty) {
        return null;
      }

      final parts = host.split('.');
      if (parts.length < 2) {
        return host;
      }

      // Take last 2 segments as registered domain
      // Per D-15: simple extraction, won't handle .co.uk
      return parts.sublist(parts.length - 2).join('.');
    } catch (_) {
      return null;
    }
  }

  /// Compare two URLs by their registered domains.
  ///
  /// Returns true if:
  /// - Both domains match
  /// - Either URL is null (can't compare, don't warn -- reduces false positives)
  ///
  /// Returns false if domains are different (potential phishing).
  static bool domainsMatch(String? savedUrl, String? targetUrl) {
    final savedDomain = extractDomain(savedUrl);
    final targetDomain = extractDomain(targetUrl);

    // If either domain couldn't be extracted, return true (can't compare)
    if (savedDomain == null || targetDomain == null) {
      return true;
    }

    return savedDomain == targetDomain;
  }
}
