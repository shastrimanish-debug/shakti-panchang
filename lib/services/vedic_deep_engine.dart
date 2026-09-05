import '../models/kundali_model.dart';

class VedicDeepEngine {
  
  // 1. Planetary Conjunctions & Aspects Analysis (युति और दृष्टि विश्लेषण)
  static List<String> analyzeConjunctionsAndAspects(List<PlanetPosition> planets) {
    List<String> insights = [];

    // Map planets by house for quick lookup
    Map<int, List<PlanetPosition>> houseMap = {};
    for (var p in planets) {
      houseMap.putIfAbsent(p.house, () => []);
      houseMap[p.house]!.add(p);
    }

    // A. Conjunctions (युति - एक ही भाव में ग्रहों का होना)
    houseMap.forEach((house, list) {
      if (list.length > 1) {
        String pNames = list.map((e) => e.planet).join(', ');
        if (list.any((e) => e.planet == 'सूर्य') && list.any((e) => e.planet == 'बुध')) {
          insights.add('✨ **बुधदित्य योग (भाव $house):** सूर्य और बुध की युति से जातक तीव्र बुद्धि, उच्च प्रशासनिक क्षमता और उत्कृष्ट संवाद कौशल से युक्त होता है।');
        } else if (list.any((e) => e.planet == 'चन्द्र') && list.any((e) => e.planet == 'गुरु')) {
          insights.add('✨ **गजकेसरी योग (भाव $house):** चंद्रमा और गुरु का यह संयोग जातक को यशस्वी, ज्ञानी, समाज में उच्च प्रतिष्ठा और अपार धन-संपदा प्रदान करता है।');
        } else if (list.any((e) => e.planet == 'सूर्य') && list.any((e) => e.planet == 'गुरु')) {
          insights.add('✨ **पितृ-गुरु योग (भाव $house):** सूर्य और गुरु की युति जातक को वैचारिक रूप से मजबूत, न्यायप्रिय, और उच्च पद या सलाहकार बनाती है।');
        } else if (list.any((e) => e.planet == 'मंगल') && list.any((e) => e.planet == 'शनि')) {
          insights.add('⚡ **अंगारक-विष योग प्रभाव (भाव $house):** मंगल और शनि की युति जीवन में संघर्ष, कार्यक्षेत्र में अचानक रुकावटें और क्रोध की अधिकता दे सकती है; धैर्य आवश्यक है।');
        } else {
          insights.add('🪐 **ग्रह युति (भाव $house):** इस भाव में [$pNames] की युति के कारण इनके मिले-जुले प्रभाव (विशेषकर ऊर्जा, मानसिक स्थिति और कार्यक्षेत्र पर) देखने को मिलेंगे।');
        }
      }
    });

    // B. Special Vedic Aspects (दृष्टियाँ - 7वीं, 4थी, 8वीं, 5वीं, 9वीं दृष्टि)
    for (var p in planets) {
      int h = p.house;
      
      // Saturn's special aspects (3rd and 10th from itself)
      if (p.planet == 'शनि') {
        int h3 = ((h + 2 - 1) % 12) + 1;
        int h10 = ((h + 9 - 1) % 12) + 1;
        insights.add('👁️ **शनि की विशेष दृष्टि:** शनि भाव $h में बैठकर भाव $h3 और भाव $h10 पर पूर्ण दृष्टि डाल रहा है, जिससे इन भावों से जुड़े कार्यों में विलंब, अनुशासन और अंततः स्थायित्व प्राप्त होता है।');
      }
      
      // Mars's special aspects (4th and 8th)
      if (p.planet == 'मंगल') {
        int h4 = ((h + 3 - 1) % 12) + 1;
        int h8 = ((h + 7 - 1) % 12) + 1;
        insights.add('👁️ **मंगल की विशेष दृष्टि:** मंगल भाव $h से अपनी विशेष चौथी दृष्टि ($h4) और आठवीं दृष्टि ($h8) के माध्यम से ऊर्जा, पराक्रम और भूमि-भवन से जुड़े मामलों को प्रभावित कर रहा है।');
      }

      // Jupiter's special aspects (5th and 9th)
      if (p.planet == 'गुरु') {
        int h5 = ((h + 4 - 1) % 12) + 1;
        int h9 = ((h + 8 - 1) % 12) + 1;
        insights.add('👁️ **देवगुरु बृहस्पति की दृष्टि:** गुरु भाव $h से अपनी पंचम दृष्टि ($h5) और नवम दृष्टि ($h9) से जहाँ भी देख रहे हैं, वहाँ वृद्धि, भाग्य और सुरक्षा का कवच प्रदान कर रहे हैं।');
      }
    }

    if (insights.isEmpty) {
      insights.add('कुंडली में ग्रह स्वतंत्र रूप से अपने भावों को प्रभावित कर रहे हैं। विशेष युति या भारी दृष्टियों का प्रभाव मध्यम है।');
    }

    return insights;
  }

  // 2. Micro-Level Vimshottari Mahadasha-Antardasha Deep Prediction
  static Map<String, String> getVimshottariMicroAnalysis(String mahadasha, String antardasha) {
    String title = 'महादशा: $mahadasha • अंतर्दशा: $antardasha';
    StringBuffer details = StringBuffer();

    // Deep predictive matrix based on classical Vedic combinations
    if (mahadasha.contains('गुरु') && antardasha.contains('शनि')) {
      details.writeln('• **सूक्ष्म फलादेश:** गुरु में शनि की अंतर्दशा एक कर्मप्रधान काल है। ज्ञान (गुरु) और अनुशासन/श्रम (शनि) का यह मेल जीवन में बड़े पेशेवर बदलाव, नई जिम्मेदारियों और दीर्घकालिक निवेश के लिए अत्यंत शुभ है।');
      details.writeln('• **सावधानी:** कार्यस्थल पर वाणी में संयम रखें और जोड़ों (joints) के दर्द या थकान से बचें।');
    } else if (mahadasha.contains('सूर्य') && antardasha.contains('चंद्र')) {
      details.writeln('• **सूक्ष्म फलादेश:** सूर्य-चंद्रमा का यह संयोजन राजा और रानी का मिलन माना जाता है। मान-सम्मान में वृद्धि, सरकारी या उच्चाधिकारियों से लाभ और जनता से जुड़े कार्यों में सफलता मिलती है।');
      details.writeln('• **सावधानी:** मानसिक रूप से अति-संवेदनशील होने से बचें; निर्णय अपने आत्मविश्वास से लें।');
    } else if (mahadasha.contains('राहु') && antardasha.contains('गुरु')) {
      details.writeln('• **सूक्ष्म फलादेश (चांडाळ योग प्रभाव सा):** राहु की महत्वाकांक्षाओं के साथ गुरु का ज्ञान जुड़ा है। यह काल विदेश यात्रा, उच्च शिक्षा या तकनीकी अनुसंधान (Research) के लिए अचानक बड़े अवसर खोलता है।');
      details.writeln('• **सावधानी:** शॉर्टकट तरीकों से धन कमाने या अनैतिक निर्णयों से पूरी तरह दूर रहें।');
    } else if (mahadasha.contains('शनि') && antardasha.contains('बुध')) {
      details.writeln('• **सूक्ष्म फलादेश:** शनि और बुध दोनों मित्र ग्रह हैं। यह समय व्यापार विस्तार, पक्के अनुबंधों (Contracts), हिसाब-किताब, और लेखन/आईटी सेक्टर के जातकों के लिए स्वर्णकाल साबित होता है।');
      details.writeln('• **सावधानी:** कागजी दस्तावेजों और कानूनी समझौतों में हस्ताक्षर करने से पहले दो बार जांच लें।');
    } else {
      // General comprehensive fallback based on Mahadasha lord nature
      details.writeln('• **वर्तमान दशा का मूल प्रभाव:** $mahadasha महादशा के अंतर्गत $antardasha की यह अंतर्दशा जातक के जीवन में उस ग्रह विशेष के स्वामित्व वाले भावों के फल सक्रिय कर रही है।');
      details.writeln('• **विशेषीय सूत्र:** इस अवधि में यदि संबंधित ग्रह कुंडली में योगकारक (शुभ) स्थिति में हैं, तो भाग्योदय, धन लाभ और परिवार में मांगलिक कार्य संपन्न होंगे। यदि मारक या पीड़ित हैं, तो नियमित दान और मंत्र जाप से श्रेष्ठ परिणाम प्राप्त किए जा सकते हैं।');
    }

    return {
      'title': title,
      'analysis': details.toString(),
    };
  }
}
