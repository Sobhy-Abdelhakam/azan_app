import 'package:adhan_dart/adhan_dart.dart';
import 'package:azan_app/core/services/location_service.dart';
import 'package:geolocator/geolocator.dart';

class PrayerTimeService {
  // this class is responsible for calculating prayer times based on the user's location

  Future<Map<String, DateTime>> getPrayerTimes() async {
    Position position = await LocationService().getUserLocation();
    Coordinates coordinates =
        Coordinates(position.latitude, position.longitude);
    CalculationParameters params = CalculationMethod.muslimWorldLeague();

    PrayerTimes prayerTimes = PrayerTimes(
      coordinates: coordinates,
      calculationParameters: params,
      date: DateTime.now(),
    );

    return {
      'Fajr': prayerTimes.fajr!,
      'Dhuhr': prayerTimes.dhuhr!,
      'Asr': prayerTimes.asr!,
      'Maghrib': prayerTimes.maghrib!,
      'Isha': prayerTimes.isha!,
    };
  }
}
