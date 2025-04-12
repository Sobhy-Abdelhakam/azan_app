import 'package:azan_app/models/app_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const _notifKey = 'notifications_enabled';
  static const _soundKey = 'azan_sound_enabled';
  static const _methodKey = 'calc_method';
  static const _locationTypeKey = 'location_type';
  static const _manualCityKey = 'manual_city';
  static const _manualCountryKey = 'manual_country';

  Future<AppSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return AppSettings(
      notificationsEnabled: prefs.getBool(_notifKey) ?? true,
      azanSoundEnabled: prefs.getBool(_soundKey) ?? true,
      calculationMethod:CalculationMethodOption.values[prefs.getInt(_methodKey) ?? 0],
      locationType: LocationType.values[prefs.getInt(_locationTypeKey) ?? 0],
      manualCity: prefs.getString(_manualCityKey) ?? '',
      manualCountry: prefs.getString(_manualCountryKey) ?? '',
    );
  }

  Future<void> saveSettings(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notifKey, settings.notificationsEnabled);
    await prefs.setBool(_soundKey, settings.azanSoundEnabled);
    await prefs.setInt(_methodKey, settings.calculationMethod.index);
    await prefs.setInt(_locationTypeKey, settings.locationType.index);
    await prefs.setString(_manualCityKey, settings.manualCity);
    await prefs.setString(_manualCountryKey, settings.manualCountry);
  }

  Future<void> resetSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
