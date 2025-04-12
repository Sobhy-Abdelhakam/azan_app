enum PrayerName { fajr, dhuhr, asr, maghrib, isha }

class PrayerTime {
  final PrayerName name;
  final DateTime time;
  final bool isNext;
  PrayerTime({
    required this.name,
    required this.time,
    this.isNext = false,
  });
}
