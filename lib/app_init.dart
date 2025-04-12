import 'package:azan_app/core/services/location_service.dart';
import 'package:azan_app/core/services/notification_service.dart';
import 'package:azan_app/core/services/prayer_time_service.dart';
import 'package:azan_app/core/services/settings_service.dart';
import 'package:azan_app/models/app_settings.dart';

class AppInit {
  static late AppSettings _appSettings;
  static late PrayerTimeService _prayerTimeService;
  static late NotificationService _notificationService;
  static late LocationService _locationService;
  static bool _isInitialized = false;
  
  static Future<void> initialize() async {
    if (_isInitialized) return;
    _appSettings = await SettingsService().loadSettings();

    // Initialize services with settings
    _locationService = LocationService();
    _prayerTimeService = PrayerTimeService(settings: _appSettings, locationService: _locationService);
    _notificationService = NotificationService(settings: _appSettings);

    await _notificationService.init();
    
    _isInitialized = true;
  }

  static AppSettings get settings => _appSettings;
  static LocationService get locationService => _locationService;
  static PrayerTimeService get prayerTimeService => _prayerTimeService;
  static NotificationService get notificationService => _notificationService;
}