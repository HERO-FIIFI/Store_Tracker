import 'package:shared_preferences/shared_preferences.dart';

class PinLockService {
  static const String _pinKey = 'app_pin';
  static const String _pinEnabledKey = 'pin_enabled';

  Future<bool> isPinEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_pinEnabledKey) ?? false;
  }

  Future<void> setPinEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_pinEnabledKey, enabled);
  }

  Future<bool> hasPin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_pinKey) != null;
  }

  Future<void> setPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pinKey, pin);
    await setPinEnabled(true);
  }

  Future<bool> verifyPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    final storedPin = prefs.getString(_pinKey);
    return storedPin == pin;
  }

  Future<void> removePin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pinKey);
    await setPinEnabled(false);
  }

  Future<void> disablePin() async {
    await setPinEnabled(false);
  }

  Future<void> enablePin() async {
    final hasStoredPin = await hasPin();
    if (hasStoredPin) {
      await setPinEnabled(true);
    }
  }
}