import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class ReminderService {
  static final ReminderService instance = ReminderService._();
  ReminderService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _ready = false;

  Future<void> init() async {
    if (_ready) return;
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwin = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const settings = InitializationSettings(android: android, iOS: darwin, macOS: darwin);
    await _plugin.initialize(settings);

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();
    final iosPlugin = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    await iosPlugin?.requestPermissions(alert: true, badge: true, sound: true);
    _ready = true;
  }

  Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime when,
  }) async {
    await init();
    if (when.isBefore(DateTime.now())) return;

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(when, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'shakti_panchang_reminders',
          'Shakti Panchang Reminders',
          channelDescription: 'उमा के शुभ समय और यात्रा reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  Future<void> scheduleDaily({required int id, required String title, required String body, required DateTime firstWhen}) async {
    await init();
    if (firstWhen.isBefore(DateTime.now())) return;
    await _plugin.zonedSchedule(id, title, body, tz.TZDateTime.from(firstWhen, tz.local),
      const NotificationDetails(android: AndroidNotificationDetails('shakti_panchang_reminders','Shakti Panchang Reminders', channelDescription: 'उमा reminders', importance: Importance.high, priority: Priority.high)),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle, matchDateTimeComponents: DateTimeComponents.time);
  }

  Future<void> scheduleWeekly({required int id, required String title, required String body, required DateTime firstWhen}) async {
    await init();
    if (firstWhen.isBefore(DateTime.now())) return;
    await _plugin.zonedSchedule(id, title, body, tz.TZDateTime.from(firstWhen, tz.local),
      const NotificationDetails(android: AndroidNotificationDetails('shakti_panchang_reminders','Shakti Panchang Reminders', channelDescription: 'उमा reminders', importance: Importance.high, priority: Priority.high)),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle, matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime);
  }

  Future<void> cancel(int id) async {
    await init();
    await _plugin.cancel(id);
  }
}
