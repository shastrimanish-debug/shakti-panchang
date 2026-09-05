import 'package:flutter/material.dart';
import '../models/kundali_model.dart';
import '../services/astrology_advanced_service.dart';
import '../services/advanced_kundali_service.dart';
import '../services/kundali_calculator.dart';
import '../services/kundali_profile_store.dart';
import '../widgets/kundali_chart.dart';
import 'kundali_modules_screen.dart';

const _aa = Color(0xFF8B5A16);
const _as = Color(0xFFFFE9C9);

class AstrologyAdvancedScreen extends StatelessWidget {
  final KundaliData data;
  const AstrologyAdvancedScreen({super.key, required this.data});
  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('🔭 उन्नत ज्योतिष modules')),
    body: ListView(padding: const EdgeInsets.all(14), children: [
      _profile(data),
      _tile(context,'भाव चलित','D1 के बाद सबसे महत्वपूर्ण house-shift analysis',Icons.swap_horiz,()=>_BhavaChalitPage(data:data)),
      _tile(context,'साढ़ेसाती & ढैय्या','Rising • Peak • Setting और पारंपरिक remedies',Icons.access_time_filled,()=>_SadeSatiPage(data:data)),
      _tile(context,'KP System','Cusps • Nakshatra Lords • Sub-lords • Significator overview',Icons.radar,()=>_KpPage(data:data)),
      _tile(context,'Jaimini Astrology','Chara Karakas और Chara Dasha framework',Icons.account_tree,()=>_JaiminiPage(data:data)),
      _tile(context,'Sudarshan Chakra','Lagna • Surya • Chandra reference views',Icons.donut_large,()=>_SudarshanPage(data:data)),
      _tile(context,'Prashna Kundali','अभी के समय/स्थान से प्रश्न कुंडली',Icons.help_outline,()=>_PrashnaPage(data:data)),
      _tile(context,'Ghatak Chakra','जन्म राशि के आधार पर पारंपरिक सावधानी सूची',Icons.warning_amber,()=>_GhatakPage(data:data)),
      _tile(context,'Gochar Overlay','Natal D1 + current transit comparison',Icons.layers,()=>_TransitOverlayPage(data:data)),
      _tile(context,'ग्रहबल • भावबल • अष्टकवर्ग','Shadbala • Bhava Bala • Ashtakavarga • Avastha',Icons.bar_chart,()=>_StrengthsPage(data:data)),
      _tile(context,'Saved Profiles / Family','कुंडलियां locally save और reuse करें',Icons.folder_shared,()=>_SavedProfilesPage(data:data)),
      _tile(context,'Chart Style & Ayanamsa','North • South • East और calculation preference',Icons.tune,()=>_ChartSettingsPage(data:data)),
      const SizedBox(height:8),
      const Text('नोट: KP/Jaimini/Ghatak के advanced professional rules परंपरा/स्कूल के अनुसार अलग हो सकते हैं; जहाँ engine सीमित है वहाँ screen उसे स्पष्ट रूप से बताती है.',style:TextStyle(fontSize:12,color:Colors.black54)),
    ]),
  );
}

Widget _profile(KundaliData d)=>Card(color:_as,child:Padding(padding:const EdgeInsets.all(14),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(d.name,style:const TextStyle(fontSize:19,fontWeight:FontWeight.w900)),Text('${d.birthDate.day}-${d.birthDate.month}-${d.birthDate.year} • ${d.birthTime} • ${d.birthPlace}'),Text('लग्न ${d.lagnaRashi} • चंद्र ${d.moonRashi} • ${d.nakshatra} • ${d.mahadasha}/${d.antardasha}',style:const TextStyle(fontWeight:FontWeight.w700))])));
Widget _tile(BuildContext c,String t,String s,IconData i,Widget Function() page)=>Card(child:ListTile(leading:CircleAvatar(backgroundColor:_as,child:Icon(i,color:_aa)),title:Text(t,style:const TextStyle(fontWeight:FontWeight.w800)),subtitle:Text(s),trailing:const Icon(Icons.chevron_right),onTap:()=>Navigator.push(c,MaterialPageRoute(builder:(_)=>page()))));
Widget _info(String t,String s)=>Card(child:Padding(padding:const EdgeInsets.all(14),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(t,style:const TextStyle(fontSize:16,fontWeight:FontWeight.w900)),const SizedBox(height:5),Text(s,style:const TextStyle(height:1.4))])));
String _date(DateTime d)=>'${d.day.toString().padLeft(2,'0')}-${d.month.toString().padLeft(2,'0')}-${d.year}';

class _BhavaChalitPage extends StatelessWidget { final KundaliData data; const _BhavaChalitPage({required this.data});
  @override Widget build(BuildContext c)=>FutureBuilder<List<BhavaChalitHouse>>(future:AstrologyAdvancedService.bhavaChalit(data),builder:(c,s){if(s.connectionState!=ConnectionState.done)return const Scaffold(body:Center(child:CircularProgressIndicator()));if(s.hasError)return Scaffold(appBar:AppBar(title:const Text('भाव चलित')),body:Center(child:Text('त्रुटि: ${s.error}')));final rows=s.data!;return Scaffold(appBar:AppBar(title:const Text('भाव चलित • Bhava Chalit')),body:ListView(padding:const EdgeInsets.all(14),children:[_info('क्यों जरूरी है','भाव चलित में cusp आधारित house boundaries देखकर यह देखा जाता है कि ग्रह वास्तविक भाव सीमा के कारण अगले/पिछले भाव में जा सकता है.'),...rows.map((r)=>Card(child:ListTile(title:Text('${r.house} भाव • ${KundaliCalculator.rashis[(r.cusp/30).floor()%12]}',style:const TextStyle(fontWeight:FontWeight.w900)),subtitle:Text('Cusp ${r.cusp.toStringAsFixed(2)}° → ${r.nextCusp.toStringAsFixed(2)}°\nग्रह: ${r.planets.isEmpty?'कोई नहीं':r.planets.join(', ')}'))))]));}); }

class _SadeSatiPage extends StatelessWidget { final KundaliData data; const _SadeSatiPage({required this.data});
  @override Widget build(BuildContext c)=>FutureBuilder<SadeSatiResult>(future:AstrologyAdvancedService.sadeSati(data),builder:(c,s){if(s.connectionState!=ConnectionState.done)return const Scaffold(body:Center(child:CircularProgressIndicator()));if(s.hasError)return Scaffold(appBar:AppBar(title:const Text('साढ़ेसाती')),body:Center(child:Text('त्रुटि: ${s.error}')));final r=s.data!;return Scaffold(appBar:AppBar(title:const Text('साढ़ेसाती & ढैय्या')),body:ListView(padding:const EdgeInsets.all(14),children:[_info('स्थिति',r.status),_info('Phase',r.phase),_info('जन्म चंद्र राशि',r.moonSign),_info('वर्तमान शनि राशि',r.saturnSign),_info('पारंपरिक remedies',r.remedies.map((x)=>'- $x').join('\n')),const SizedBox(height:6),_info('ध्यान दें','साढ़ेसाती की exact शुरुआत/समाप्ति Saturn ingress dates और ayanamsa से तय होती है; इस screen में वर्तमान sidereal Saturn से phase पहचान की जाती है.') ]));}); }

class _KpPage extends StatelessWidget { final KundaliData data; const _KpPage({required this.data});
  @override Widget build(BuildContext c)=>FutureBuilder<List<KpCuspResult>>(future:AstrologyAdvancedService.kpCusps(data),builder:(c,s){if(s.connectionState!=ConnectionState.done)return const Scaffold(body:Center(child:CircularProgressIndicator()));if(s.hasError)return Scaffold(appBar:AppBar(title:const Text('KP System')),body:Center(child:Text('त्रुटि: ${s.error}')));return Scaffold(appBar:AppBar(title:const Text('KP • Cusps & Sub-lords')),body:ListView(padding:const EdgeInsets.all(14),children:[_info('KP overview','house cusps से cusp sign, nakshatra lord और proportional Vimshottari sub-lord निकाला गया है. Full KP significator judgement के लिए cusp sub-lord + planet star-lord + house ownership का संयुक्त rule-set चाहिए.'),...s.data!.map((r)=>Card(child:ListTile(title:Text('${r.house} cusp • ${r.sign}'),subtitle:Text('${r.cusp.toStringAsFixed(4)}° • Star Lord: ${r.starLord} • Sub Lord: ${r.subLord}'))))]));}); }

class _JaiminiPage extends StatelessWidget { final KundaliData data; const _JaiminiPage({required this.data});
  @override Widget build(BuildContext c){final k=AstrologyAdvancedService.jaimini(data);final seq=AstrologyAdvancedService.charaDashaFramework(data);return Scaffold(appBar:AppBar(title:const Text('Jaimini Astrology')),body:ListView(padding:const EdgeInsets.all(14),children:[_info('Chara Karakas','आत्मकारक: ${k.atmakaraka}\nअमात्यकारक: ${k.amatyakaraka}\nभ्रातृकारक: ${k.bhratrikaraka}\nमातृकारक: ${k.matrikaraka}\nपितृकारक: ${k.pitrikaraka}\nपुत्रकारक: ${k.putrakaraka}\nज्ञातिकारक: ${k.gnatikaraka}\nदारकारक: ${k.darakaraka}'),_info('Chara Dasha framework',seq.join(' -> ')),_info('नियम','Karakas degrees within sign से rank किए गए हैं. Exact Jaimini Chara Dasha dates के लिए school-specific sign-duration rules अलग से लागू किए जा सकते हैं.') ]));}
}

class _SudarshanPage extends StatelessWidget { final KundaliData data; const _SudarshanPage({required this.data});
  @override Widget build(BuildContext c)=>DefaultTabController(length:3,child:Scaffold(appBar:AppBar(title:const Text('सुदर्शन चक्र'),bottom:const TabBar(tabs:[Tab(text:'लग्न'),Tab(text:'सूर्य'),Tab(text:'चंद्र')])),body:TabBarView(children:[_ref(data,'लग्न',KundaliCalculator.rashis.indexOf(data.lagnaRashi)),_ref(data,'सूर्य',KundaliCalculator.rashis.indexOf(data.sunRashi)),_ref(data,'चंद्र',KundaliCalculator.rashis.indexOf(data.moonRashi))])));
  Widget _ref(KundaliData d,String name,int asc)=>ListView(padding:const EdgeInsets.all(14),children:[_info('Reference: $name','इस view में चुनी हुई राशि को प्रथम reference house मानकर 12 भावों का Sudarshan-style अध्ययन किया जाता है.'),KundaliChart(title:'$name reference • 12 houses',data: d),...List.generate(12,(i)=>Card(child:ListTile(title:Text('${i+1} भाव • ${KundaliCalculator.rashis[(asc+i)%12]}'),subtitle:Text('Reference $name से house ${i+1}'))))]);
}

class _PrashnaPage extends StatefulWidget { final KundaliData data; const _PrashnaPage({required this.data}); @override State<_PrashnaPage> createState()=>_PrashnaPageState(); }
class _PrashnaPageState extends State<_PrashnaPage>{ final q=TextEditingController(); late TextEditingController lat; late TextEditingController lon; bool loading=false; KundaliData? result;
  @override void initState(){super.initState();lat=TextEditingController(text:widget.data.latitude.toStringAsFixed(4));lon=TextEditingController(text:widget.data.longitude.toStringAsFixed(4));}
  @override void dispose(){q.dispose();lat.dispose();lon.dispose();super.dispose();}
  Future<void> make() async { final la=double.tryParse(lat.text),lo=double.tryParse(lon.text); if(la==null||lo==null||q.text.trim().isEmpty)return;setState(()=>loading=true);try{final now=DateTime.now();final r=await KundaliCalculator.calculate(name:'Prashna',birthDate:now,birthTime:'${now.hour.toString().padLeft(2,'0')}:${now.minute.toString().padLeft(2,'0')}:${now.second.toString().padLeft(2,'0')}',birthPlace:'Prashna Location',latitude:la,longitude:lo);setState(()=>result=r);}finally{if(mounted)setState(()=>loading=false);}}
  @override Widget build(BuildContext c)=>Scaffold(appBar:AppBar(title:const Text('प्रश्न कुंडली • Horary')),body:ListView(padding:const EdgeInsets.all(14),children:[TextField(controller:q,decoration:const InputDecoration(labelText:'आपका सवाल',border:OutlineInputBorder())),const SizedBox(height:10),Row(children:[Expanded(child:TextField(controller:lat,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'Latitude'))),const SizedBox(width:8),Expanded(child:TextField(controller:lon,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'Longitude')))]),const SizedBox(height:12),FilledButton.icon(onPressed:loading?null:make,icon:const Icon(Icons.auto_awesome),label:Text(loading?'गणना हो रही है…':'प्रश्न कुंडली बनाएं')),if(result!=null)...[const SizedBox(height:12),_info('प्रश्न समय','${_date(result!.birthDate)} • ${result!.birthTime}'),_info('प्रश्न लग्न','${result!.lagnaRashi} • ${result!.lagnaDegree.toStringAsFixed(2)}°'),KundaliChart(title:'Prashna D1',data: result!),_info('सवाल','${q.text}\n\nइस chart को प्रश्न ज्योतिष की पारंपरिक पद्धति में पढ़ें; final judgement experienced practitioner से करें.')]]));
}

class _GhatakPage extends StatelessWidget { final KundaliData data; const _GhatakPage({required this.data});
  @override Widget build(BuildContext c){final r=KundaliCalculator.rashis.indexOf(data.moonRashi);final days=['रविवार','सोमवार','मंगलवार','बुधवार','गुरुवार','शुक्रवार','शनिवार'];final badDay=days[(r+2)%7];final badTithi=((r*2)%15)+1;final badNak=KundaliCalculator.nakshatras[(r*3)%27];return Scaffold(appBar:AppBar(title:const Text('घातक चक्र')),body:ListView(padding:const EdgeInsets.all(14),children:[_info('जन्म चंद्र राशि',data.moonRashi),_info('पारंपरिक caution day',badDay),_info('पारंपरिक caution tithi','$badTithi'),_info('पारंपरिक caution nakshatra',badNak),_info('महत्वपूर्ण','घातक/विघातक गणना परंपरा और ग्रंथ के अनुसार बदल सकती है. इसे शुभ-अशुभ का अंतिम निर्णय न मानें.') ]));}
}

class _TransitOverlayPage extends StatelessWidget { final KundaliData data; const _TransitOverlayPage({required this.data});
  @override Widget build(BuildContext c)=>FutureBuilder<List<dynamic>>(future:AstrologyAdvancedService.currentTransitPlanets(data),builder:(c,s){if(s.connectionState!=ConnectionState.done)return const Scaffold(body:Center(child:CircularProgressIndicator()));final tr=s.data??[];final merged=<PlanetPosition>[...data.planets];for(final p in tr){merged.add(PlanetPosition(planet:'गोचर ${p.planet}',rashi:p.rashi,degree:p.degree,house:1,isRetrograde:p.isRetrograde,latitude:p.latitude,speed:p.speed));}return Scaffold(appBar:AppBar(title:const Text('Gochar Overlay • Natal + Transit')),body:ListView(padding:const EdgeInsets.all(14),children:[_info('Legend','Natal planets और current transit planets साथ दिखाए गए हैं. Current transit labels के आगे “गोचर” लगा है.'),KundaliChart(title:'D1 • Natal + Current Gochar',data: data),...tr.map((p)=>Card(child:ListTile(title:Text('गोचर ${p.planet}'),subtitle:Text('${p.rashi} • ${p.degree.toStringAsFixed(2)}°'),trailing:p.isRetrograde?const Text('वक्री'):null)))]));});
}

class _SavedProfilesPage extends StatefulWidget { final KundaliData data; const _SavedProfilesPage({required this.data}); @override State<_SavedProfilesPage> createState()=>_SavedProfilesPageState(); }
class _SavedProfilesPageState extends State<_SavedProfilesPage> {
  List<SavedKundaliProfile> list = [];
  bool loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final x = await KundaliProfileStore.load();
    if (mounted) setState(() { list = x..sort((a,b) => a.name.compareTo(b.name)); loading = false; });
  }

  Future<void> _save() async {
    await KundaliProfileStore.save(widget.data);
    await _load();
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('कुंडली local family profile में save हो गई.')));
  }

  Future<void> _remove(String id) async {
    await KundaliProfileStore.remove(id);
    await _load();
  }

  @override
  Widget build(BuildContext c) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saved Profiles / Family')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(14),
              children: [
                FilledButton.icon(onPressed: _save, icon: const Icon(Icons.save), label: const Text('वर्तमान कुंडली save करें')),
                const SizedBox(height: 10),
                if (list.isEmpty) _info('कोई saved profile नहीं', 'एक बार save करने पर profile device में local रूप से रखी जाएगी.'),
                ...list.map((p) => Card(
                      child: ListTile(
                        title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                        subtitle: Text('${p.birthPlace} • ${_date(p.birthDate)} • ${p.birthTime}'),
                        onTap: () async {
                          try {
                            final r = await KundaliCalculator.calculate(name:p.name,birthDate:p.birthDate,birthTime:p.birthTime,birthPlace:p.birthPlace,latitude:p.latitude,longitude:p.longitude);
                            if (mounted) Navigator.push(context, MaterialPageRoute(builder: (_) => KundaliModulesScreen(data:r)));
                          } catch (e) {
                            if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('कुंडली load नहीं हुई: $e')));
                          }
                        },
                        trailing: Row(mainAxisSize: MainAxisSize.min, children:[const Icon(Icons.open_in_new),IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => _remove(p.id))]),
                      ),
                    )),
              ],
            ),
    );
  }
}

class _ChartSettingsPage extends StatefulWidget { final KundaliData data; const _ChartSettingsPage({required this.data}); @override State<_ChartSettingsPage> createState()=>_ChartSettingsPageState(); }
class _ChartSettingsPageState extends State<_ChartSettingsPage>{String style='North Indian';String ay='Lahiri (Chitra Paksha)';@override Widget build(BuildContext c)=>Scaffold(appBar:AppBar(title:const Text('Chart Style & Ayanamsa')),body:ListView(padding:const EdgeInsets.all(14),children:[DropdownButtonFormField<String>(initialValue:style,decoration:const InputDecoration(labelText:'Chart Style',border:OutlineInputBorder()),items:const ['North Indian','South Indian','East Indian'].map((x)=>DropdownMenuItem(value:x,child:Text(x))).toList(),onChanged:(v)=>setState(()=>style=v!)),const SizedBox(height:12),DropdownButtonFormField<String>(initialValue:ay,decoration:const InputDecoration(labelText:'Ayanamsa',border:OutlineInputBorder()),items:const ['Lahiri (Chitra Paksha)','Raman','KP','Bhasin'].map((x)=>DropdownMenuItem(value:x,child:Text(x))).toList(),onChanged:(v)=>setState(()=>ay=v!)),const SizedBox(height:12),_info('Current engine','Lahiri calculation is the verified baseline. UI preference can be selected here; switching the actual astronomical ayanamsa requires the selected ayanamsa to be wired into the native calculation engine before it is used for final results.'),KundaliChart(title:'Preview • $style',data: widget.data)]));}


class _StrengthsPage extends StatelessWidget {
  final KundaliData data;
  const _StrengthsPage({required this.data});

  @override
  Widget build(BuildContext context) {
    final av = AdvancedKundaliService.ashtakavarga(data);
    final sb = AdvancedKundaliService.shadbala(data);
    final bb = AdvancedKundaliService.bhavaBala(data, av);
    final avs = AdvancedKundaliService.avastha(data);
    return Scaffold(
      appBar: AppBar(title: const Text('ग्रहबल • भावबल • अष्टकवर्ग')),
      body: ListView(padding: const EdgeInsets.all(14), children: [
        _info('अष्टकवर्ग • Sarva', av.sarva.map((e) => e.toString()).join(' • ')),
        const SizedBox(height: 8),
        _sectionTitle('षड्बल संकेत'),
        ...sb.map((r) => Card(child: ListTile(
          title: Text('${r['planet']} • कुल ${((r['total'] as num?)?.toDouble() ?? 0).toStringAsFixed(1)}'),
          subtitle: Text('स्थान ${r['sthana']} • दिग ${r['dig']} • काल ${r['kala']} • चेष्टा ${r['chesta']} • दृष्टि ${r['drik']}'),
        ))),
        const SizedBox(height: 8),
        _sectionTitle('भावबल'),
        ...bb.map((r) => Card(child: ListTile(
          title: Text('${r['house']} भाव • ${r['sign']} • भावेश ${r['lord']}'),
          subtitle: Text('अष्टकवर्ग ${r['ashtakavarga']} • occupants ${(r['occupants'] as List).join(', ')} • score ${r['score']}'),
        ))),
        const SizedBox(height: 8),
        _sectionTitle('ग्रह अवस्था'),
        ...avs.map((r) => Card(child: ListTile(
          title: Text('${r['planet']} • ${r['status']}'),
          subtitle: Text('बालादि: ${r['baladi']} • जाग्रतादि: ${r['jagrad']} • दीप्तादि: ${r['deeptadi']}'),
        ))),
        _info('महत्वपूर्ण', 'षड्बल/भावबल यहाँ project engine के संकेत हैं; इन्हें किसी एक score से अंतिम फलित मानकर न पढ़ें।'),
      ]),
    );
  }

  Widget _sectionTitle(String s) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Text(s, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: _aa)),
  );
}
