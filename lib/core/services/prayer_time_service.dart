import 'package:adhan_dart/adhan_dart.dart';
import 'package:azan_app/core/services/location_service.dart';
import 'package:azan_app/models/app_settings.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class PrayerTimeService {
  // this class is responsible for calculating prayer times based on the user's location
  final AppSettings settings;

  PrayerTimeService({required this.settings});

  Future<Map<String, DateTime>> getPrayerTimes() async {
    Coordinates coordinates;
    
    if (settings.locationType == LocationType.manual) {
      coordinates = await _getManualCoordinates();
    } else {
      Position position = await LocationService().getUserLocation();
      coordinates = Coordinates(position.latitude, position.longitude);
      final test = await placemarkFromCoordinates(position.latitude, position.longitude);
      print('${test[0].locality}, ${test[0].country}');
    }

    CalculationParameters params = _getCalculationParameters(settings.calculationMethod);

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

  Future<Coordinates> _getManualCoordinates() async {
    try {
      final locations = await locationFromAddress(
        '${settings.manualCity}, ${settings.manualCountry}',
      );
      final loc = locations.first;
      return Coordinates(loc.latitude, loc.longitude);
    } catch (e) {
      print('Failed to get manual location, using Mecca fallback. Error: $e');
      return Coordinates(29.95375640, 31.53700030); // Cairo
    }
  }

  CalculationParameters _getCalculationParameters(CalculationMethodOption option) {
    switch (option) {
      case CalculationMethodOption.egyptian:
        return CalculationMethod.egyptian();
      case CalculationMethodOption.ummAlQura:
        return CalculationMethod.ummAlQura();
      case CalculationMethodOption.karachi:
        return CalculationMethod.karachi();
      case CalculationMethodOption.muslimWorldLeague:
        return CalculationMethod.muslimWorldLeague();
    }
  }
}
