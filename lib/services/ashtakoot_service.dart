import '../models/kundali_model.dart';
import 'kundali_calculator.dart';

class AshtakootResult {
  final List<AshtakootItem> items;
  final double total;
  final String verdict;
  const AshtakootResult({required this.items,required this.total,required this.verdict});
}
class AshtakootItem {
  final String name;
  final double score;
  final double max;
  final String note;
  const AshtakootItem({required this.name,required this.score,required this.max,required this.note});
}

class AshtakootService {
  static AshtakootResult calculate(KundaliData a,KundaliData b){
    final items=<AshtakootItem>[];
    final ar=KundaliCalculator.rashis.indexOf(a.moonRashi), br=KundaliCalculator.rashis.indexOf(b.moonRashi);
    items.add(AshtakootItem(name:'वर्ण',score:_varna(a.moonRashi,b.moonRashi),max:1,note:'चंद्र राशियों के पारंपरिक वर्ण स्तर पर आधारित।'));
    items.add(AshtakootItem(name:'वश्य',score:_vashya(a.moonRashi,b.moonRashi),max:2,note:'चंद्र राशियों की पारंपरिक वश्य श्रेणियों पर आधारित।'));
    items.add(AshtakootItem(name:'तारा',score:_tara(a,b),max:3,note:'जन्म नक्षत्र से नक्षत्र दूरी और शुभ/अशुभ तारा गणना।'));
    items.add(AshtakootItem(name:'योनि',score:_yoni(a.yoni,b.yoni),max:4,note:'नक्षत्र-योनि की पारंपरिक मैत्री/विरोध श्रेणी।'));
    items.add(AshtakootItem(name:'ग्रह मैत्री',score:_grahaMaitri(ar,br),max:5,note:'चंद्र राशियों के स्वामियों की प्राकृतिक मैत्री।'));
    items.add(AshtakootItem(name:'गण',score:_gana(a.gana,b.gana),max:6,note:'देव/मनुष्य/राक्षस गण की पारंपरिक संगति।'));
    items.add(AshtakootItem(name:'भकूट',score:_bhakoot(ar,br),max:7,note:'चंद्र राशियों की 2/12, 5/9 और 6/8 स्थितियों का पारंपरिक नियम; cancellation rules अलग से देखे जा सकते हैं।'));
    items.add(AshtakootItem(name:'नाड़ी',score:a.nadi==b.nadi?0:8,max:8,note:a.nadi==b.nadi?'एक ही नाड़ी: पारंपरिक नाड़ी दोष संकेत।':'अलग नाड़ी: सामान्यतः नाड़ी कूट अनुकूल।'));
    final total=items.fold<double>(0,(s,x)=>s+x.score);
    final verdict=total>=28?'बहुत अच्छा पारंपरिक गुण मिलान':total>=24?'अच्छा पारंपरिक गुण मिलान':total>=18?'मध्यम/विस्तृत विश्लेषण आवश्यक':'कम गुण; विस्तृत कुंडली मिलान आवश्यक';
    return AshtakootResult(items:items,total:total,verdict:verdict);
  }

  static double _varna(String a,String b){final rank=(String s)=>const {'ब्राह्मण':4,'क्षत्रिय':3,'वैश्य':2,'शूद्र':1}[s]??1;final x=rank(a),y=rank(b);return x>=y?1:0;}
  static String _vashyaGroup(String r){if(const ['मेष','वृषभ'].contains(r))return 'चतुष्पद';if(const ['मिथुन','कन्या','तुला','कुंभ'].contains(r))return 'मानव';if(r=='कर्क')return 'जलचर';if(const ['सिंह'].contains(r))return 'वनचर';return 'चतुष्पद';}
  static double _vashya(String a,String b){final x=_vashyaGroup(a),y=_vashyaGroup(b);if(x==y)return 2;if((x=='मानव'&&y=='चतुष्पद')||(y=='मानव'&&x=='चतुष्पद'))return 1;if((x=='जलचर'&&y=='मानव')||(y=='जलचर'&&x=='मानव'))return 1;return .5;}
  static double _tara(KundaliData a,KundaliData b){final ai=KundaliCalculator.nakshatras.indexOf(a.nakshatra),bi=KundaliCalculator.nakshatras.indexOf(b.nakshatra);final x=((bi-ai+27)%27)%9+1;final y=((ai-bi+27)%27)%9+1;bool good(int n)=>const [1,2,4,6,8].contains(n);if(good(x)&&good(y))return 3;if(good(x)||good(y))return 1.5;return 0;}
  static const _yoniFriends={'अश्व':{'अश्व','गज','मृग'},'गज':{'गज','अश्व'},'मेढ़ा':{'मेढ़ा','वानर'},'सर्प':{'सर्प','नकुल'},'श्वान':{'श्वान'},'मार्जार':{'मार्जार','मूषक'},'मूषक':{'मूषक','मार्जार'},'गौ':{'गौ','महिष'},'महिष':{'महिष','गौ'},'व्याघ्र':{'व्याघ्र','मृग'},'मृग':{'मृग','व्याघ्र','अश्व'},'वानर':{'वानर','मेढ़ा'},'नकुल':{'नकुल','सर्प'},'सिंह':{'सिंह'}};
  static double _yoni(String a,String b){if(a==b)return 4;if(_yoniFriends[a]?.contains(b)==true||_yoniFriends[b]?.contains(a)==true)return 3;return 1.5;}
  static const _lord={'मेष':'मंगल','वृषभ':'शुक्र','मिथुन':'बुध','कर्क':'चंद्र','सिंह':'सूर्य','कन्या':'बुध','तुला':'शुक्र','वृश्चिक':'मंगल','धनु':'गुरु','मकर':'शनि','कुंभ':'शनि','मीन':'गुरु'};
  static const _friend={'सूर्य':{'सूर्य','चंद्र','मंगल','गुरु'},'चंद्र':{'सूर्य','चंद्र','बुध'},'मंगल':{'सूर्य','चंद्र','गुरु'},'बुध':{'सूर्य','शुक्र'},'गुरु':{'सूर्य','चंद्र','मंगल'},'शुक्र':{'बुध','शनि'},'शनि':{'बुध','शुक्र'}};
  static double _grahaMaitri(int a,int b){final x=_lord[KundaliCalculator.rashis[a]]!,y=_lord[KundaliCalculator.rashis[b]]!;if(x==y)return 5;final xf=_friend[x]!.contains(y),yf=_friend[y]!.contains(x);if(xf&&yf)return 5;if(xf||yf)return 4;return 2;}
  static double _gana(String a,String b){if(a==b)return 6;if((a=='मनुष्य'&&b=='देव')||(b=='मनुष्य'&&a=='देव'))return 5;if((a=='मनुष्य'&&b=='राक्षस')||(b=='मनुष्य'&&a=='राक्षस'))return 1;if((a=='देव'&&b=='राक्षस')||(b=='देव'&&a=='राक्षस'))return 0;return 2;}
  static double _bhakoot(int a,int b){final d=((b-a+12)%12)+1;final reverse=((a-b+12)%12)+1;if((d==2&&reverse==12)||(d==12&&reverse==2)||(d==5&&reverse==9)||(d==9&&reverse==5)||(d==6&&reverse==8)||(d==8&&reverse==6))return 0;return 7;}
}
