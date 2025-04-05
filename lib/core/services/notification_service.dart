import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:azan_app/core/services/prayer_time_service.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  Future<void> initNotifications() async {
    tz.initializeTimeZones();
    var initializationSettings = const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'));

    await _notificationsPlugin.initialize(initializationSettings);
  }

  Future<void> scheduleAzanNotifications() async {
    Map<String, DateTime> prayerTimes =
        await PrayerTimeService().getPrayerTimes();
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      'azan_channel',
      'azan_notifications',
      channelDescription: 'Channel for Azan notifications',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('azan_sound'),
      enableVibration: true,
      // vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
    );
    for (var entry in prayerTimes.entries) {
      _notificationsPlugin.zonedSchedule(
        entry.key.hashCode,
        'Azan ${entry.key}',
        'Time for azan ${entry.key}',
        tz.TZDateTime.from(entry.value, tz.local),
        NotificationDetails(android: androidPlatformChannelSpecifics),
        matchDateTimeComponents: DateTimeComponents.time,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    }
  }
}
