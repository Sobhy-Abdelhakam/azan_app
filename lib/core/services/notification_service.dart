import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:azan_app/core/services/prayer_time_service.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() {
    return _instance;
  }
  NotificationService._internal();
  final AwesomeNotifications _awesomeNotifications = AwesomeNotifications();
  final String azanChannelKey = 'azan_channel';

  Future<void> init() async {
    bool granted = await _isAndroidPermissionGranted();

    if (!granted) {
      granted = await _requestAndroidPermission();
    }
    if (granted) {
      print('Notification permission granted');
      await _awesomeNotifications.initialize(
        null,
        [azanNotificationChannel()],
        debug: true,
      );
    } else {
      print('Notification permission denied');
    }
  }

  Future<void> scheduleANotification(String title, DateTime time) async {
    final now = DateTime.now();
    // skip if time has passed
    if (time.isBefore(now)) return;

    bool isAllowed = await _isAndroidPermissionGranted();
    if (!isAllowed) isAllowed = await _requestAndroidPermission();
    if (!isAllowed) return;

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: title.hashCode,
        channelKey: azanChannelKey,
        title: 'Azan $title',
        body: '$title Prayer is now!',
        fullScreenIntent: true, // Shows overlay even if locked
        wakeUpScreen: true,
        locked: true, // prevents dismissal without action
        criticalAlert: true,
      ),
      schedule: NotificationCalendar.fromDate(
        date: time,
        allowWhileIdle: true,
      ),
    );
    print('Scheduled notification for $title at $time');
    print('time is ${NotificationCalendar.fromDate(date: time)}');
  }

  Future<void> scheduleNotifi() async {
    scheduleANotification(
        'AzanTest', DateTime.now().add(const Duration(seconds: 3)));
  }

  Future<void> scheduleAzanNotifications() async {
    Map<String, DateTime> prayerTimes =
        await PrayerTimeService().getPrayerTimes();
    for (var entry in prayerTimes.entries) {
      scheduleANotification(entry.key, entry.value);
    }
  }

  Future<void> cancelAzanNotifications() async {
    await _awesomeNotifications.cancelNotificationsByChannelKey(azanChannelKey);
  }

  Future<void> cancelAllNotifications() async {
    await _awesomeNotifications.cancelAll();
  }

  NotificationChannel azanNotificationChannel() {
    String channelTitle = 'Azan Notifications';
    String channelDescription = 'Channel for Azan notifications';
    return NotificationChannel(
      channelKey: azanChannelKey,
      channelName: channelTitle,
      channelDescription: channelDescription,
      importance: NotificationImportance.Max,
      defaultPrivacy: NotificationPrivacy.Public,
      locked: true,
      playSound: true,
      soundSource: 'resource://raw/res_azan',
      defaultColor: Colors.green,
      ledColor: Colors.white,
      criticalAlerts: true,
      channelShowBadge: true,
    );
  }

  Future<bool> _isAndroidPermissionGranted() async {
    return await _awesomeNotifications.isNotificationAllowed();
  }

  Future<bool> _requestAndroidPermission() async {
    return await _awesomeNotifications.requestPermissionToSendNotifications();
  }
}
