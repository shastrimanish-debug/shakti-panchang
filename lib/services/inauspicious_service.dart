import '../models/panchang_models.dart';

class InauspiciousService {
  // Segment indexes counted from sunrise. These are the standard weekday
  // sequences for Rahu Kalam, Yamaganda and Gulika.
  static const rahu = {
    1: 1, 2: 6, 3: 4, 4: 5, 5: 2, 6: 3, 7: 7,
  };
  static const yama = {
    1: 4, 2: 3, 3: 2, 4: 1, 5: 0, 6: 6, 7: 5,
  };
  static const gulika = {
    1: 6, 2: 5, 3: 4, 4: 3, 5: 2, 6: 1, 7: 0,
  };

  static List<MuhuratWindow> daytime(DateTime sunrise, DateTime sunset, int weekday) {
    final part = sunset.difference(sunrise).inMilliseconds ~/ 8;
    DateTime at(int index) => sunrise.add(Duration(milliseconds: part * index));
    return [
      MuhuratWindow(
        title: 'राहु काल',
        start: at(rahu[weekday]!),
        end: at(rahu[weekday]! + 1),
        description: 'महत्वपूर्ण शुभ कार्य/नई शुरुआत से बचने का पारंपरिक काल।',
      ),
      MuhuratWindow(
        title: 'यमगण्ड',
        start: at(yama[weekday]!),
        end: at(yama[weekday]! + 1),
        description: 'नई शुरुआत के लिए पारंपरिक रूप से प्रतिकूल समय।',
      ),
      MuhuratWindow(
        title: 'गुलिक काल',
        start: at(gulika[weekday]!),
        end: at(gulika[weekday]! + 1),
        description: 'पारंपरिक काल-विभाजन; कार्य के अनुसार विचार करें।',
      ),
    ];
  }
}
