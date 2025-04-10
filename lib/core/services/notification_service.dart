import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:azan_app/core/services/prayer_time_service.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final AwesomeNotifications _awesomeNotifications = AwesomeNotifications();
  final String azanChannelKey = 'azan_channel';

  Future<void> init() async {
    bool granted = await _awesomeNotifications.isNotificationAllowed();

    if (!granted) {
      granted = await _awesomeNotifications.requestPermissionToSendNotifications();
    }
    if (granted) {
      await _awesomeNotifications.initialize(
        null,
        [azanNotificationChannel()],
        debug: true,
      );
    }
  }

  Future<void> scheduleANotification(String title, DateTime time) async {
    // skip if time has passed
    if (time.isBefore(DateTime.now())) return;

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

  NotificationChannel azanNotificationChannel() {
    return NotificationChannel(
      channelKey: azanChannelKey,
      channelName: 'Azan Notifications',
      channelDescription: 'Channel for Azan notifications',
      importance: NotificationImportance.High,
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
}
