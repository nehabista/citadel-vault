/// Supported import formats for CSV files from other password managers.
enum ImportFormat {
  bitwarden,
  onePassword,
  lastPass,
  chrome,
  unknown,
}

/// Auto-detect the CSV format from its header row.
///
/// Uses distinctive header columns to identify each password manager's
/// export format. Returns [ImportFormat.unknown] if no match is found.
ImportFormat detectFormat(List<String> headers) {
  final lower = headers.map((h) => h.trim().toLowerCase()).toSet();

  // Bitwarden: has 'login_uri' AND 'login_username'
  if (lower.contains('login_uri') && lower.contains('login_username')) {
    return ImportFormat.bitwarden;
  }

  // LastPass: has 'grouping' AND 'extra'
  if (lower.contains('grouping') && lower.contains('extra')) {
    return ImportFormat.lastPass;
  }

  // 1Password: has 'title' AND 'url' AND 'username' (case-insensitive)
  if (lower.contains('title') &&
      lower.contains('url') &&
      lower.contains('username')) {
    return ImportFormat.onePassword;
  }

  // Chrome: has all of 'name', 'url', 'username', 'password'
  if (lower.contains('name') &&
      lower.contains('url') &&
      lower.contains('username') &&
      lower.contains('password')) {
    return ImportFormat.chrome;
  }

  return ImportFormat.unknown;
}
