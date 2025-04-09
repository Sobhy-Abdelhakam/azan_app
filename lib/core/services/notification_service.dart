import 'dart:async';
import 'dart:io';

import 'package:azan_app/core/services/audio_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:azan_app/core/services/prayer_time_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() {
    return _instance;
  }
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final StreamController<NotificationResponse> selectNotificationStream =
      StreamController<NotificationResponse>.broadcast();

  Future<void> init() async {
    tz.initializeTimeZones();

    //   final String? timeZoneName = await FlutterTimezone.getLocalTimezone();
    // tz.setLocalLocation(tz.getLocation(timeZoneName!));

    final String currentTimeZone = DateTime.now().timeZoneName;
    tz.setLocalLocation(tz.getLocation(currentTimeZone));

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: selectNotificationStream.add,
    );
    _isAndroidPermissionGranted().then((granted) {
      if (!granted) {
        _requestAndroidPermission().then((value) {
          print('Notification permission granted');
        }).catchError((error) {
          print('Error requesting notification permission: $error');
        });
      }
    });
  }

  Future<void> scheduleANotification(String title, DateTime time) async {
    final now = DateTime.now();
    // skip if time has passed
    if (time.isBefore(now)) return;
    await _notificationsPlugin.zonedSchedule(
      title.hashCode,
      'Azan $title',
      'title for $title prayer',
      tz.TZDateTime.from(time, tz.local),
      // tz.TZDateTime.now(tz.getLocation('Africa/Cairo'))
      //     .add(const Duration(seconds: 3)),
      _notificationDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time, // for daily repeat
    );
    print('Scheduled notification for $title at $time');
    print(
        'test ${tz.TZDateTime.from(time, tz.local).add(const Duration(seconds: 3))}');
  }

  Future<void> scheduleNotifi() async {
    // _notificationsPlugin.show(0, 'title', 'body', _notificationDetails());
    scheduleANotification(
        'AzanTest', DateTime.now().add(const Duration(seconds: 3)));
    // _notificationsPlugin.zonedSchedule(0, 'title', 'body', tz.TZDateTime.from(DateTime.now().add(const Duration(seconds: 5)), tz.local), _notificationDetails('id', 'title', 'body'), androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle);
  }

  Future<void> scheduleAzanNotifications() async {
    Map<String, DateTime> prayerTimes =
        await PrayerTimeService().getPrayerTimes();
    for (var entry in prayerTimes.entries) {
      scheduleANotification(entry.key, entry.value);
      // if (entry.value.isBefore(DateTime.now())) {
      //   continue;
      // }
      // await _notificationsPlugin.zonedSchedule(
      //   entry.key.hashCode,
      //   'Azan ${entry.key}',
      //   'Time for azan ${entry.key}',
      //   tz.TZDateTime.from(entry.value, tz.local),
      //   notificationDetails,
      //   matchDateTimeComponents: DateTimeComponents.time, // for daily repeat
      //   androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      // );
      // print('Scheduled notification for ${entry.key} at ${entry.value}');
    }
  }

  Future<void> cancelAzanNotifications() async {
    Map<String, DateTime> prayerTimes =
        await PrayerTimeService().getPrayerTimes();
    for (var entry in prayerTimes.entries) {
      _notificationsPlugin.cancel(entry.key.hashCode);
    }
  }

  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  NotificationDetails _notificationDetails() {
    String channelId = 'azan_channel';
    String channelTitle = 'Azan Notifications';
    String channelDescription = 'Channel for Azan notifications';
    return NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelTitle,
        channelDescription: channelDescription,
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        // sound: const RawResourceAndroidNotificationSound('azan_sound'),
        enableVibration: true,
        // vibrationPattern: Int64List.fromList([0, 1000, 500, 1000])
      ),
    );
  }

  Future<bool> _isAndroidPermissionGranted() async {
    return await _notificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.areNotificationsEnabled() ??
        false;
  }

  Future<void> _requestAndroidPermission() async {
    final androidImplementation =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidImplementation != null) {
      final bool? granted =
          await androidImplementation?.requestNotificationsPermission();
      if (granted != null && granted) {
        throw Exception('Notification permission not granted');
      }
    } else {
      throw Exception('Android implementation not found');
    }
  }
}
