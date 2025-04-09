import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:azan_app/core/services/audio_service.dart';
import 'package:azan_app/core/services/prayer_time_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() {
    return _instance;
  }
  NotificationService._internal();
  final AwesomeNotifications _awesomeNotifications = AwesomeNotifications();
  final String azanChannelKey = 'azan_channel';

  Future<void> init() async {
    await _awesomeNotifications.initialize(
      null,
      [azanNotificationChannel()],
    );
    _isAndroidPermissionGranted().then((granted) {
      if (!granted) {
        _requestAndroidPermission().then((value) {
          if (value) {
            print('Notification permission granted');
          } else {
            print('Notification permission denied');
          }
        });
      }
    });
  }

  Future<void> scheduleANotification(String title, DateTime time) async {
    final now = DateTime.now();
    // skip if time has passed
    if (time.isBefore(now)) return;

    bool isAllowed = await _awesomeNotifications.isNotificationAllowed();
    if (!isAllowed) {
      isAllowed =
          await AwesomeNotifications().requestPermissionToSendNotifications();
    }
    if (!isAllowed) return;

    await AwesomeNotifications().createNotification(
      schedule: NotificationCalendar.fromDate(
        date: time,
        allowWhileIdle: true,
        preciseAlarm: true,
      ),
      content: NotificationContent(
        id: title.hashCode,
        channelKey: azanChannelKey,
        title: 'Azan $title',
        body: 'Time for azan $title',
        customSound: 'resource://raw/azan',
      ),
    );

    // await _notificationsPlugin.zonedSchedule(
    //   title.hashCode,
    //   'Azan $title',
    //   'title for $title prayer',
    //   tz.TZDateTime.from(time, tz.local),
    //   // tz.TZDateTime.now(tz.getLocation('Africa/Cairo'))
    //   //     .add(const Duration(seconds: 3)),
    //   _notificationDetails(),
    //   androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    //   matchDateTimeComponents: DateTimeComponents.time, // for daily repeat
    // );
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
      playSound: true,
      soundSource: 'resource://raw/azan',
    );
  }

  Future<bool> _isAndroidPermissionGranted() async {
    return await _awesomeNotifications.isNotificationAllowed();
  }

  Future<bool> _requestAndroidPermission() async {
    return await _awesomeNotifications.requestPermissionToSendNotifications();
  }
}
