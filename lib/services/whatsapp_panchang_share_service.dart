// lib/services/whatsapp_panchang_share_service.dart
// Shakti Panchang - 1-Click WhatsApp Daily Suprabhat Panchang Card Builder

class WhatsAppPanchangShareService {
  static const List<String> _suvicharList = [
    'कर्मण्येवाधिकारस्ते मा फलेषु कदाचन। निष्काम कर्म ही जीवन की सच्ची शांति और विजय का मार्ग है।',
    'सत्य और धर्म की राह कठिन अवश्य हो सकती है, पर अंततः विजय सत्य की ही होती है। शुभ प्रभात!',
    'ईश्वर पर अटूट विश्वास और स्वयं पर भरोसा हर असंभव कार्य को संभव बना देता है। आपका दिन मंगलमय हो।',
    'जिस प्रकार दीपक अंधकार को मिटा देता है, उसी प्रकार ज्ञान और विनम्रता मनुष्य के जीवन को आलोकित करते हैं।',
    'परोपकाराय फलन्ति वृक्षाः परोपकाराय वहन्ति नद्यः। सेवा और परोपकार ही मानव जीवन का सर्वोच्च आभूषण है।',
    'मन के हारे हार है, मन के जीते जीत। सकारात्मक सोच के साथ आज के दिन का सुंदर आरंभ करें।',
    'समय और प्रारब्ध उसी का साथ देते हैं जो अटूट संकल्प और पुरुषार्थ के साथ आगे बढ़ता है। जय श्री राम!',
  ];

  static String getDailySuvichar(DateTime date) {
    final index = (date.day + date.month) % _suvicharList.length;
    return _suvicharList[index];
  }

  static String buildWhatsAppShareText({
    required DateTime date,
    required String weekday,
    required String tithi,
    required String paksha,
    required String masa,
    required String samvat,
    required String nakshatra,
    required String yoga,
    required String karana,
    required String sunrise,
    required String sunset,
    required String lunarRashi,
    required String solarRashi,
    required String abhijitMuhurat,
    required String rahuKaal,
    required String panchakName,
    required String bhadraStatus,
    List<String> specialYogas = const [],
    String locationName = 'उज्जैन',
  }) {
    final suvichar = getDailySuvichar(date);
    final dayStr = '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

    final yogaText = specialYogas.isNotEmpty
        ? '\n🌟 *विशेष योग:* ${specialYogas.join(", ")}'
        : '';

    return '''॥ श्री गणेशाय नमः ॥
🚩 *सनातन शक्ति पंचांग* 🚩
📍 *स्थान:* $locationName
📅 *दिनांक:* $dayStr ($weekday)
🌕 *संवत्सर:* $samvat | $masa मास ($paksha पक्ष)

━━━━━━━━━━━━━━━━━━━
🌸 *दैनिक पंचांग के ५ मुख्य अंग:*
१. *तिथि:* $tithi
२. *नक्षत्र:* $nakshatra
३. *योग:* $yoga
४. *करण:* $karana
५. *वार:* $weekday

━━━━━━━━━━━━━━━━━━━
🌅 *सूर्योदय:* $sunrise | 🌇 *सूर्यास्त:* $sunset
🌙 *चन्द्र राशि:* $lunarRashi | ☀️ *सूर्य राशि:* $solarRashi$yogaText
⚡ *पञ्चक स्थिति:* $panchakName
🛡️ *भद्रा स्थिति:* $bhadraStatus

━━━━━━━━━━━━━━━━━━━
✨ *शुभ-अशुभ मुहूर्त:*
🟢 *अभिजित मुहूर्त:* $abhijitMuhurat (विजय मुहूर्त)
🔴 *राहुकाल:* $rahuKaal (शुभ कार्य त्याज्य)

━━━━━━━━━━━━━━━━━━━
🌺 *आज का प्रेरक सुविचार:*
"$suvichar"

📲 *सनातन शक्ति पंचांग ऐप* द्वारा प्रामाणिक पंचांग गणना।
सर्वे भवन्तु सुखिनः सर्वे सन्तु निरामयाः। 🕉️''';
  }
}
