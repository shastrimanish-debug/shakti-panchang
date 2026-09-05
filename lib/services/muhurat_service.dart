import '../models/panchang_models.dart';

class MuhuratService {
  static List<MuhuratWindow> calculate(DateTime date, SolarTimes s) {
    final windows = <MuhuratWindow>[];

    // Brahma Muhurat: 1 hour 36 minutes before sunrise to 48 minutes before sunrise.
    windows.add(MuhuratWindow(
      title: 'ब्रह्म मुहूर्त',
      start: s.sunrise.subtract(const Duration(minutes: 96)),
      end: s.sunrise.subtract(const Duration(minutes: 48)),
      description: 'ध्यान, पूजा, अध्ययन और आध्यात्मिक कार्यों के लिए पारंपरिक शुभ समय।',
    ));

    // Abhijit Muhurat: 15 ghatis centered on local solar noon.
    final noon = s.sunrise.add(
      Duration(milliseconds: s.sunset.difference(s.sunrise).inMilliseconds ~/ 2),
    );
    windows.add(MuhuratWindow(
      title: 'अभिजित मुहूर्त',
      start: noon.subtract(const Duration(minutes: 24)),
      end: noon.add(const Duration(minutes: 24)),
      description: 'दोपहर का पारंपरिक शुभ काल; स्थानीय सूर्योदय-सूर्यास्त से गणना।',
    ));

    // Godhuli: traditional sunset-centered window.
    windows.add(MuhuratWindow(
      title: 'गोधूलि मुहूर्त',
      start: s.sunset.subtract(const Duration(minutes: 24)),
      end: s.sunset.add(const Duration(minutes: 24)),
      description: 'सूर्यास्त के आसपास का पारंपरिक संध्या काल।',
    ));

    return windows;
  }
}

