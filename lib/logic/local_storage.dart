import 'package:shared_preferences/shared_preferences.dart';

/// Lightweight local storage for non-sensitive app state.
///
/// Uses [SharedPreferences] (unencrypted) intentionally because:
/// 1. This is read during splash/onboarding BEFORE the Drift database or
///    vault key are available, so SettingsDao cannot be used at that point.
/// 2. The only data stored here is the onboarding completion flag, which is
///    a non-sensitive boolean and does not require encryption.
///
/// **Security note:** Do NOT store sensitive data (passwords, tokens, keys)
/// in this class. Use [SettingsDao] (Drift) or [FlutterSecureStorage] instead.
class LocalStorageSharedPref {
  static const String _key = 'ghumphir';
  static const String _onboardingKey = 'onboarding';

  static Future<void> saveOnboardingStatus(bool value) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setBool('$_key$_onboardingKey', value);
  }

  static Future<bool> getOnboardingStatus() async {
    final pref = await SharedPreferences.getInstance();
    return pref.getBool('$_key$_onboardingKey') ?? false;
  }
}
