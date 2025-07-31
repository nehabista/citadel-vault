import 'package:shared_preferences/shared_preferences.dart';

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
