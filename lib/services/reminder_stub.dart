/// Web stub — local notifications are Android/iOS only.
class ReminderService {
  static final ReminderService instance = ReminderService._();
  ReminderService._();

  Future<void> init() async {}

  Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime when,
  }) async {}

  Future<void> scheduleDaily({required int id, required String title, required String body, required DateTime firstWhen}) async {}
  Future<void> scheduleWeekly({required int id, required String title, required String body, required DateTime firstWhen}) async {}
  Future<void> cancel(int id) async {}
}
