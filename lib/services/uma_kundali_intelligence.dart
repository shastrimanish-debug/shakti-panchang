import '../models/kundali_model.dart';

class UmaKundaliIntelligence {
  const UmaKundaliIntelligence();

  String answer(String question, KundaliData d) {
    final q=question.toLowerCase();
    if(_has(q,['career','करियर','नौकरी','job','business','व्यवसाय'])) return _career(d);
    if(_has(q,['finance','पैसा','धन','कमाई','income','wealth','आर्थिक'])) return _finance(d);
    if(_has(q,['marriage','विवाह','शादी','पति','पत्नी','relationship'])) return _marriage(d);
    if(_has(q,['education','शिक्षा','पढ़ाई','पढ़ाई','study','exam'])) return _education(d);
    if(_has(q,['health','स्वास्थ्य','सेहत','बीमारी','रोग'])) return _health(d);
    if(_has(q,['dasha','दशा','महादशा','अंतरदशा','प्रत्यंतर'])) return _dasha(d);
    if(_has(q,['nakshatra','नक्षत्र','पाद','चरण'])) return 'आपका जन्म नक्षत्र ${d.nakshatra}, चरण ${d.charan} और चंद्र राशि ${d.moonRashi} है।';
    return 'कुंडली के मुख्य संकेत: लग्न ${d.lagnaRashi}, चंद्र राशि ${d.moonRashi}, नक्षत्र ${d.nakshatra}। वर्तमान दशा ${_current(d).maha}/${_current(d).antar} है।';
  }
  String _career(KundaliData d)=>'करियर में 10वाँ और नौकरी में 6वाँ भाव प्रमुख है। 10वें भाव में ${_h(d,10)}, 6वें में ${_h(d,6)}, 7वें में ${_h(d,7)} हैं। वर्तमान दशा ${_current(d).maha}/${_current(d).antar} है।';
  String _finance(KundaliData d)=>'धन में 2रा और 11वाँ भाव प्रमुख हैं। 2रे में ${_h(d,2)}, 11वें में ${_h(d,11)}, 9वें में ${_h(d,9)} हैं। वर्तमान दशा ${_current(d).maha}/${_current(d).antar} है।';
  String _marriage(KundaliData d)=>'विवाह में 7वाँ भाव मुख्य है। 7वें भाव में ${_h(d,7)} हैं। शुक्र की स्थिति ${_p(d,'शुक्र')} है। समय निर्धारण में दशा और गोचर साथ देखने चाहिए।';
  String _education(KundaliData d)=>'शिक्षा में 4था और 5वाँ भाव महत्वपूर्ण हैं। 4थे में ${_h(d,4)}, 5वें में ${_h(d,5)} हैं। बुध की स्थिति ${_p(d,'बुध')} है।';
  String _health(KundaliData d)=>'पारंपरिक ज्योतिषीय स्वास्थ्य विश्लेषण में लग्न और 6वाँ भाव देखा जाता है। पहले भाव में ${_h(d,1)} और 6वें में ${_h(d,6)} हैं। यह चिकित्सकीय निदान नहीं है।';
  String _dasha(KundaliData d){final x=_current(d);return 'वर्तमान विम्शोत्तरी दशा: महादशा ${x.maha}, अंतरदशा ${x.antar}।';}
  ({String maha,String antar}) _current(KundaliData d){final n=DateTime.now();final m=d.dashaPeriods.firstWhere((x)=>!n.isBefore(x.startDate)&&n.isBefore(x.endDate),orElse:()=>d.dashaPeriods.last);final a=d.antarPeriods.firstWhere((x)=>x.maha==m.planet&&!n.isBefore(x.startDate)&&n.isBefore(x.endDate),orElse:()=>d.antarPeriods.firstWhere((x)=>x.maha==m.planet));return (maha:m.planet,antar:a.antar);}
  String _h(KundaliData d,int h){final x=d.planets.where((p)=>p.house==h).map((p)=>p.planet).toList();return x.isEmpty?'कोई प्रमुख ग्रह नहीं':x.join(', ');}
  String _p(KundaliData d,String n){for(final p in d.planets){if(p.planet==n)return '${p.rashi}, भाव ${p.house}';}return 'उपलब्ध नहीं';}
  bool _has(String q,List<String> w)=>w.any(q.contains);
}
