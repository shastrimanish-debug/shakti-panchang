import '../models/panchang_models.dart';

enum MuhuratActivity {
  general,
  travel,
  business,
  vehiclePurchase,
  property,
  houseEntry,
  education,
  naming,
  marriage,
}

class MuhuratEngine {
  List<MuhuratWindow> forActivity({
    required MuhuratActivity activity,
    required SolarTimes solar,
    required int weekday,
  }) {
    final brahma = MuhuratWindow(
      title: 'ब्रह्म मुहूर्त',
      start: solar.sunrise.subtract(const Duration(minutes: 96)),
      end: solar.sunrise.subtract(const Duration(minutes: 48)),
      description: 'ध्यान, पूजा, जप और अध्ययन के लिए पारंपरिक शुभ समय।',
    );

    final abhijit = MuhuratWindow(
      title: 'अभिजित मुहूर्त',
      start: _solarNoon(solar).subtract(const Duration(minutes: 24)),
      end: _solarNoon(solar).add(const Duration(minutes: 24)),
      description: 'दोपहर का पारंपरिक शुभ काल; विशेष कार्य में अन्य पंचांग दोष भी देखें।',
    );

    final godhuli = MuhuratWindow(
      title: 'गोधूलि मुहूर्त',
      start: solar.sunset.subtract(const Duration(minutes: 24)),
      end: solar.sunset.add(const Duration(minutes: 24)),
      description: 'संध्या के आसपास का पारंपरिक काल।',
    );

    final morning = MuhuratWindow(
      title: 'प्रातः शुभ काल',
      start: solar.sunrise.add(const Duration(minutes: 24)),
      end: solar.sunrise.add(const Duration(hours: 2)),
      description: 'दैनिक शुभ कार्यों के लिए उपयोगी प्रातःकालीन विंडो।',
    );

    final afternoon = MuhuratWindow(
      title: 'मध्याह्न शुभ काल',
      start: _solarNoon(solar).subtract(const Duration(minutes: 48)),
      end: _solarNoon(solar).add(const Duration(minutes: 72)),
      description: 'व्यापार और सामान्य कार्यों के लिए उपयोगी समय; पंचांग दोष जाँचें।',
    );

    final evening = MuhuratWindow(
      title: 'सायं शुभ काल',
      start: solar.sunset.subtract(const Duration(hours: 2)),
      end: solar.sunset.subtract(const Duration(minutes: 24)),
      description: 'सायंकालीन सामान्य कार्यों के लिए सुझाया गया समय।',
    );

    switch (activity) {
      case MuhuratActivity.general:
        return [brahma, abhijit, godhuli];

      case MuhuratActivity.education:
        return [brahma, morning, abhijit];

      case MuhuratActivity.naming:
        return [morning, abhijit];

      case MuhuratActivity.business:
        return [morning, abhijit, afternoon];

      case MuhuratActivity.vehiclePurchase:
        return [morning, abhijit, afternoon];

      case MuhuratActivity.property:
        return [morning, abhijit];

      case MuhuratActivity.houseEntry:
        return [morning, abhijit, godhuli];

      case MuhuratActivity.marriage:
        return [morning, abhijit, godhuli];

      case MuhuratActivity.travel:
        // Travel should not blindly use every generic muhurta; the
        // direction/dishashool engine must be checked separately.
        return [morning, abhijit, evening];
    }
  }

  DateTime _solarNoon(SolarTimes s) => s.sunrise.add(
        Duration(
          milliseconds:
              s.sunset.difference(s.sunrise).inMilliseconds ~/ 2,
        ),
      );
}
