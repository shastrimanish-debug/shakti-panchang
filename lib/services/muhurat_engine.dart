import '../models/panchang_models.dart';
import 'inauspicious_service.dart';

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
  List<MuhuratWindow> dailyNamed({
    required SolarTimes solar,
    required int weekday,
  }) {
    final noon = _solarNoon(solar);
    final dayMs = solar.sunset.difference(solar.sunrise).inMilliseconds;
    final slot = Duration(milliseconds: dayMs ~/ 15);
    final nightMid = solar.sunset.add(
      Duration(milliseconds: solar.nextSunrise.difference(solar.sunset).inMilliseconds ~/ 2),
    );
    final list = <MuhuratWindow>[
      MuhuratWindow(
        title: 'ब्रह्म मुहूर्त',
        start: solar.sunrise.subtract(const Duration(minutes: 96)),
        end: solar.sunrise.subtract(const Duration(minutes: 48)),
        description: 'जप, ध्यान, अध्ययन — दिन का श्रेष्ठ आरंभ।',
      ),
      MuhuratWindow(
        title: 'सूर्योदय',
        start: solar.sunrise,
        end: solar.sunrise,
        description: 'संध्या वंदन, स्नान, अर्घ्य, दान।',
      ),
      MuhuratWindow(
        title: 'अभिजित मुहूर्त',
        start: noon.subtract(const Duration(minutes: 24)),
        end: noon.add(const Duration(minutes: 24)),
        description: weekday == DateTime.wednesday
            ? 'बुधवार को अभिजित वर्जित।'
            : 'विजय काल — समस्त शुभ कार्य।',
      ),
      MuhuratWindow(
        title: 'विजय मुहूर्त',
        start: solar.sunrise.add(slot * 10),
        end: solar.sunrise.add(slot * 11),
        description: 'कार्यसिद्धि, यात्रा, नया आरंभ।',
      ),
      MuhuratWindow(
        title: 'अमृत काल',
        start: solar.sunrise.add(Duration(milliseconds: (dayMs * 0.35).round())),
        end: solar.sunrise.add(Duration(milliseconds: (dayMs * 0.45).round())),
        description: 'मांगलिक व नवीन कार्य।',
      ),
      MuhuratWindow(
        title: 'गोधूलि मुहूर्त',
        start: solar.sunset.subtract(const Duration(minutes: 24)),
        end: solar.sunset.add(const Duration(minutes: 24)),
        description: 'गृह प्रवेश, गो-सेवा, सांध्य पूजन।',
      ),
      MuhuratWindow(
        title: 'प्रदोष काल',
        start: solar.sunset,
        end: solar.sunset.add(const Duration(minutes: 48)),
        description: 'शिव पूजन, दीपदान।',
      ),
      MuhuratWindow(
        title: 'निशीथ काल',
        start: nightMid.subtract(const Duration(minutes: 24)),
        end: nightMid.add(const Duration(minutes: 24)),
        description: 'मध्यरात्रि — सामान्य शुभ कार्य न करें।',
      ),
      ...InauspiciousService.daytime(solar.sunrise, solar.sunset, weekday),
    ];
    return list;
  }

  List<MuhuratWindow> forActivity({
    required MuhuratActivity activity,
    required SolarTimes solar,
    required int weekday,
  }) {
    final named = dailyNamed(solar: solar, weekday: weekday);
    MuhuratWindow pick(String title) =>
        named.firstWhere((w) => w.title == title, orElse: () => named.first);

    final brahma = pick('ब्रह्म मुहूर्त');
    final abhijit = pick('अभिजित मुहूर्त');
    final godhuli = pick('गोधूलि मुहूर्त');
    final vijaya = pick('विजय मुहूर्त');
    final morning = MuhuratWindow(
      title: 'प्रातः शुभ काल',
      start: solar.sunrise.add(const Duration(minutes: 24)),
      end: solar.sunrise.add(const Duration(hours: 2)),
      description: 'दैनिक शुभ कार्यों के लिए प्रातःकालीन विंडो।',
    );
    final afternoon = MuhuratWindow(
      title: 'मध्याह्न शुभ काल',
      start: _solarNoon(solar).subtract(const Duration(minutes: 48)),
      end: _solarNoon(solar).add(const Duration(minutes: 72)),
      description: 'व्यापार और सामान्य कार्य; राहुकाल जाँचें।',
    );
    final evening = MuhuratWindow(
      title: 'सायं शुभ काल',
      start: solar.sunset.subtract(const Duration(hours: 2)),
      end: solar.sunset.subtract(const Duration(minutes: 24)),
      description: 'सायंकालीन सामान्य कार्य।',
    );

    switch (activity) {
      case MuhuratActivity.general:
        return [brahma, abhijit, vijaya, godhuli];
      case MuhuratActivity.education:
        return [brahma, morning, abhijit];
      case MuhuratActivity.naming:
        return [morning, abhijit, vijaya];
      case MuhuratActivity.business:
        return [morning, abhijit, afternoon];
      case MuhuratActivity.vehiclePurchase:
        return [morning, abhijit, afternoon];
      case MuhuratActivity.property:
        return [morning, abhijit, vijaya];
      case MuhuratActivity.houseEntry:
        return [morning, abhijit, godhuli];
      case MuhuratActivity.marriage:
        return [morning, abhijit, godhuli, vijaya];
      case MuhuratActivity.travel:
        return [morning, vijaya, evening];
    }
  }

  DateTime _solarNoon(SolarTimes s) => s.sunrise.add(
        Duration(
          milliseconds: s.sunset.difference(s.sunrise).inMilliseconds ~/ 2,
        ),
      );
}
