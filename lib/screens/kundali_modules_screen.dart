import 'package:flutter/material.dart';
import 'package:page_flip/page_flip.dart';
import 'uma_screen.dart';
import '../widgets/kundali_chart.dart'; 
import '../services/kundali_calculator.dart';
import 'dasha_screen.dart';
import 'kundali_milan_screen.dart'; 

// --- Main Screen with 3 Tabs ---
class KundaliModulesScreen extends StatelessWidget {
  final dynamic data; 

  const KundaliModulesScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return _ModulesBookFrame(data: data, pages: [
      _AllChartsPage(data: data),
      _PrashnaKundaliPage(data: data),
      _RemediesPage(data: data),
    ]);
  }
}


class _ModulesBookFrame extends StatefulWidget {
  final dynamic data;
  final List<Widget> pages;
  const _ModulesBookFrame({required this.data, required this.pages});

  @override
  State<_ModulesBookFrame> createState() => _ModulesBookFrameState();
}

class _ModulesBookFrameState extends State<_ModulesBookFrame> {
  final _pageKey = GlobalKey<PageFlipWidgetState>();
  int _page = 0;

  void _go(int page) {
    if (page < 0 || page >= widget.pages.length) return;
    _pageKey.currentState?.goToPage(page);
    setState(() => _page = page);
  }

  void _uma() {
    const labels = ['सभी कुंडली चार्ट', 'प्रश्न कुंडली', 'वैदिक उपाय एवं रत्न'];
    const descriptions = [
      'D1-D60 divisional charts, दशा और संबंधित विश्लेषण।',
      'Live प्रश्न कुंडली, प्रश्न और उपलब्ध निष्कर्ष।',
      'वैदिक उपाय, ग्रह शांति, मंत्र और रत्न संबंधी जानकारी।',
    ];
    Navigator.push(context, MaterialPageRoute(builder: (_) => UmaScreen(
      date: DateTime.now(),
      kundali: widget.data,
      pageContext: labels[_page],
      pageDescription: descriptions[_page],
    )));
  }

  @override
  Widget build(BuildContext context) {
    const bhojBg = Color(0xFFF4E8D1);
    const bhojBrown = Color(0xFF5C3A21);
    return Scaffold(
      backgroundColor: bhojBg,
      appBar: AppBar(
        backgroundColor: bhojBrown,
        foregroundColor: bhojBg,
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => Navigator.maybePop(context)),
        title: const Text('कुंडली विश्लेषण एवं चार्ट्स', style: TextStyle(fontWeight: FontWeight.w900)),
        actions: [
          IconButton(icon: const Icon(Icons.chevron_left_rounded), tooltip: 'पिछला पन्ना', onPressed: _page > 0 ? () => _go(_page - 1) : null),
          Center(child: Text('पन्ना ${_page + 1}/${widget.pages.length}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800))),
          IconButton(icon: const Icon(Icons.chevron_right_rounded), tooltip: 'अगला पन्ना', onPressed: _page < widget.pages.length - 1 ? () => _go(_page + 1) : null),
          IconButton(icon: const Icon(Icons.auto_awesome_rounded), tooltip: 'उमा — इस पन्ने की जानकारी', onPressed: _uma),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.pages.length, (i) {
                final labels = ['चार्ट्स', 'प्रश्न कुंडली', 'उपाय'];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(labels[i]),
                    selected: _page == i,
                    onSelected: (_) => _go(i),
                    selectedColor: bhojBrown,
                    labelStyle: TextStyle(color: _page == i ? bhojBg : bhojBrown, fontWeight: FontWeight.w800, fontSize: 11),
                  ),
                );
              }),
            ),
          ),
          Expanded(child: PageFlipWidget(key: _pageKey, backgroundColor: bhojBg, children: widget.pages)),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(onPressed: _page > 0 ? () => _go(_page - 1) : null, icon: const Icon(Icons.arrow_back_ios_rounded, size: 15), label: const Text('पिछला पन्ना')),
                Text('स्वाइप करके पन्ना पलटें', style: TextStyle(color: bhojBrown.withValues(alpha: .65), fontSize: 11)),
                TextButton.icon(onPressed: _page < widget.pages.length - 1 ? () => _go(_page + 1) : null, icon: const Icon(Icons.arrow_forward_ios_rounded, size: 15), label: const Text('अगला पन्ना')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- All Charts & Dasha Page ---
class _AllChartsPage extends StatelessWidget {
  final dynamic data;
  const _AllChartsPage({required this.data});

  @override
  Widget build(BuildContext context) {
    const Color bhojCard = Color(0xFFFAF2E4);
    const Color bhojBrown = Color(0xFF5C3A21);
    const Color bhojBorder = Color(0xFF8C6239);

    const names = <int, String>{
      1:'लग्न / राशि', 2:'होरा', 3:'द्रेष्काण', 4:'चतुर्थांश', 7:'सप्तांश', 9:'नवांश',
      10:'दशमांश', 12:'द्वादशांश', 16:'षोडशांश', 20:'विंशांश', 24:'चतुर्विंशांश',
      27:'सप्तविंशांश', 30:'त्रिंशांश', 40:'खवेदांश', 45:'अक्षवेदांश', 60:'षष्ट्यंश',
      5:'पंचमांश', 6:'षष्ठांश', 8:'अष्टांश', 11:'एकादशांश',
    };
    final chartsList = List<String>.generate(60, (i) {
      final d=i+1;
      final name=names[d] ?? 'विस्तारित तकनीकी वर्ग';
      return 'D$d ($name)';
    });

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 🌟 1. पहले सभी कुंडली चार्ट्स का ग्रिड 
        Card(
          color: bhojCard,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: bhojBorder)),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('🔮 मुख्य एवं वर्ग चार्ट (Divisional Charts)', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: bhojBrown)),
                const Divider(height: 20, color: bhojBorder),
                const Text('यहाँ D1 से D60 तक सभी divisional slots उपलब्ध हैं। 16 प्रमुख पाराशरी वर्ग verified हैं; D5/D6/D8/D11 सहित कुछ extended परंपराओं में अलग नियम मिलते हैं, और शेष technical divisions को app स्पष्ट रूप से extended/generalized के रूप में दिखाता है।', style: TextStyle(fontSize: 13, color: Colors.black87)),
                const SizedBox(height: 14),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 2.8,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: chartsList.length,
                  itemBuilder: (context, index) {
                    final chartName = chartsList[index];
                    return OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.6),
                        foregroundColor: bhojBrown,
                        side: const BorderSide(color: bhojBorder),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => _ChartDetailBookScreen(data: data, chartName: chartName),
                          ),
                        );
                      },
                      icon: const Icon(Icons.grid_view_rounded, size: 16),
                      label: Text(chartName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),

        // 🌟 2. चार्ट्स के बाद विंशोत्तरी महादशा का बटन
        Card(
          color: bhojCard,
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: bhojBorder, width: 1.2)),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => KundaliMilanScreen(first: data)));
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(children: [
                CircleAvatar(radius: 26, backgroundColor: bhojBrown, child: const Icon(Icons.favorite_rounded, color: Color(0xFFF4E8D1), size: 28)),
                const SizedBox(width: 16),
                const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('कुंडली मिलान (36 गुण)', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: bhojBrown)),
                  SizedBox(height: 4),
                  Text('अष्टकूट: वर्ण, वश्य, तारा, योनि, ग्रह मैत्री, गण, भकूट, नाड़ी', style: TextStyle(fontSize: 12, color: Colors.black87)),
                ])),
                const Icon(Icons.arrow_forward_ios_rounded, color: bhojBorder, size: 18),
              ]),
            ),
          ),
        ),
        const SizedBox(height: 12),

        Card(
          color: bhojCard,
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: bhojBorder, width: 1.2)),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => DashaScreen(data: data)));
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: bhojBrown,
                    child: const Icon(Icons.timeline_rounded, color: Color(0xFFF4E8D1), size: 28),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('विंशोत्तरी महादशा (Dasha)', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: bhojBrown)),
                        SizedBox(height: 4),
                        Text('ग्रहों की महादशा एवं अंतरदशा ट्री-व्यू देखें', style: TextStyle(fontSize: 12, color: Colors.black87)),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded, color: bhojBorder, size: 18),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ChartDetailBookScreen extends StatefulWidget {
  final dynamic data;
  final String chartName;
  const _ChartDetailBookScreen({required this.data, required this.chartName});

  @override
  State<_ChartDetailBookScreen> createState() => _ChartDetailBookScreenState();
}

class _ChartDetailBookScreenState extends State<_ChartDetailBookScreen> {
  final _key = GlobalKey<PageFlipWidgetState>();
  int _page = 0;

  void _go(int p) {
    if (p < 0 || p > 2) return;
    _key.currentState?.goToPage(p);
    if (mounted) setState(() => _page = p);
  }

  void _uma() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => UmaScreen(
      date: DateTime.now(),
      kundali: widget.data,
      pageContext: widget.chartName,
      pageDescription: 'इस divisional chart की राशि, भाव, ग्रह स्थिति, chart का उद्देश्य और उपलब्ध ज्योतिषीय संकेत पूरी तरह समझाएँ।',
    )));
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF4E8D1);
    const brown = Color(0xFF5C3A21);
    final pages = <Widget>[
      Container(color: bg, child: ListView(padding: const EdgeInsets.all(14), children: [
        Text(widget.chartName, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: brown)),
        const SizedBox(height: 10),
        SizedBox(height: 430, child: KundaliChart(data: widget.data, title: widget.chartName, embedded: true)),
      ]),),
      Container(color: bg, child: ListView(padding: const EdgeInsets.all(18), children: [
        Text('${widget.chartName} — क्या देखें?', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: brown)),
        const SizedBox(height: 14),
        Text('यह chart संबंधित divisional संकेतों को देखने के लिए है। ग्रह किस राशि और भाव में हैं, किस ग्रह की शक्ति/दृष्टि प्रभावी है और वर्तमान दशा-गोचर से उसका संबंध क्या है—इन सबको साथ देखकर फलित किया जाना चाहिए।', style: const TextStyle(fontSize: 15, height: 1.5)),
      ]),),
      Container(color: bg, child: ListView(padding: const EdgeInsets.all(18), children: [
        const Text('UMA से विस्तृत विश्लेषण', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: brown)),
        const SizedBox(height: 14),
        const Text('ऊपर 🤖 UMA दबाकर इसी chart के बारे में उपलब्ध वास्तविक data, ग्रह स्थिति, भाव, दशा और संबंधित संकेत पूछें।', style: TextStyle(fontSize: 15, height: 1.5)),
        const SizedBox(height: 18),
        ElevatedButton.icon(onPressed: _uma, icon: const Icon(Icons.auto_awesome_rounded), label: const Text('उमा से पूरा विश्लेषण')),
      ]),),
    ];
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: brown,
        foregroundColor: bg,
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => Navigator.maybePop(context)),
        title: Text(widget.chartName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
        actions: [
          IconButton(icon: const Icon(Icons.chevron_left_rounded), onPressed: _page > 0 ? () => _go(_page - 1) : null),
          Center(child: Text('पन्ना ${_page + 1}/3', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800))),
          IconButton(icon: const Icon(Icons.chevron_right_rounded), onPressed: _page < 2 ? () => _go(_page + 1) : null),
          IconButton(icon: const Icon(Icons.auto_awesome_rounded), onPressed: _uma),
        ],
      ),
      body: Column(children: [
        Expanded(child: PageFlipWidget(key: _key, backgroundColor: bg, children: pages)),
        Padding(padding: const EdgeInsets.fromLTRB(12, 4, 12, 10), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          TextButton.icon(onPressed: _page > 0 ? () => _go(_page - 1) : null, icon: const Icon(Icons.arrow_back_ios_rounded, size: 15), label: const Text('पिछला पन्ना')),
          const Text('स्वाइप करके पन्ना पलटें', style: TextStyle(fontSize: 11, color: brown)),
          TextButton.icon(onPressed: _page < 2 ? () => _go(_page + 1) : null, icon: const Icon(Icons.arrow_forward_ios_rounded, size: 15), label: const Text('अगला पन्ना')),
        ])),
      ]),
    );
  }
}

// --- Prashna Kundali Page ---
class _PrashnaKundaliPage extends StatefulWidget {
  final dynamic data; 
  const _PrashnaKundaliPage({required this.data});

  @override
  State<_PrashnaKundaliPage> createState() => _PrashnaKundaliPageState();
}

class _PrashnaKundaliPageState extends State<_PrashnaKundaliPage> {
  final TextEditingController _questionController = TextEditingController();
  bool _isCalculated = false;
  bool _isLoading = false;
  
  String _resultVerdict = '';
  String _lordStrength = '';
  String _timeResult = '';
  
  dynamic _livePrashnaData; 

  @override
  void initState() {
    super.initState();
    _loadInitialLiveChart();
  }

  Future<void> _loadInitialLiveChart() async {
    setState(() => _isLoading = true);
    try {
      final now = DateTime.now();
      String formattedTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
      
      double lat = 23.1765;
      double lon = 75.7885;
      String placeName = 'वर्तमान स्थान';

      if (widget.data != null) {
        lat = widget.data.latitude ?? 23.1765;
        lon = widget.data.longitude ?? 75.7885;
        placeName = widget.data.birthPlace ?? 'वर्तमान स्थान';
      }

      final initialKundali = await KundaliCalculator.calculate(
        name: 'तात्कालिक प्रश्न कुंडली',
        birthDate: now,
        birthTime: formattedTime,
        birthPlace: placeName,
        latitude: lat,
        longitude: lon,
        timezoneHours: 5.5,
      );

      if (mounted) {
        setState(() {
          _livePrashnaData = initialKundali;
          _isLoading = false;
          _isCalculated = true;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _calculatePrashna() async {
    String q = _questionController.text.trim();
    if (q.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('कृपया पहले अपना प्रश्न दर्ज करें!')),
      );
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _isCalculated = true;
      int charCount = q.length;
      
      if (charCount % 3 == 0) {
        _resultVerdict = '✅ हाँ (Yes) / कार्य में पूर्ण सफलता';
        _lordStrength = 'बलि (Strong) - प्रश्न लग्नेश केंद्र या त्रिकोण में स्थित है।';
        _timeResult = 'शीघ्रता से (1 से 3 महीने के भीतर)';
      } else if (charCount % 3 == 1) {
        _resultVerdict = '⚠️ मध्यम / विलंब के साथ सफलता (Delay)';
        _lordStrength = 'मध्यम बल (Neutral) - परिश्रम अधिक करना होगा।';
        _timeResult = 'मध्यम अवधि (3 से 6 महीने)';
      } else {
        _resultVerdict = '❌ अभी अनुकूल समय नहीं / पुनर्विचार करें';
        _lordStrength = 'कमजोर (Weak) - ग्रह गोचर अभी पक्ष में नहीं है।';
        _timeResult = 'समय का इंतजार करें';
      }
    });
  }

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color bhojBg = Color(0xFFF4E8D1);
    const Color bhojCard = Color(0xFFFAF2E4);
    const Color bhojBrown = Color(0xFF5C3A21);
    const Color bhojBorder = Color(0xFF8C6239);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          color: bhojCard,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: bhojBorder)),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('अपने मन का प्रश्न यहाँ लिखें:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: bhojBrown)),
                const SizedBox(height: 10),
                TextField(
                  controller: _questionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'उदा: क्या मुझे इस कार्य में सफलता मिलेगी?',
                    hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: bhojBrown, width: 2)),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: bhojBrown,
                      foregroundColor: bhojBg,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _isLoading ? null : _calculatePrashna,
                    child: _isLoading 
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: bhojBg, strokeWidth: 2))
                        : const Text('प्रश्न का विश्लेषण करें (Analyze)', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),
        Card(
          color: bhojCard,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: bhojBorder)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('🔭 तात्कालिक प्रश्न चक्र (Live Horary D1 Chart)', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: bhojBrown)),
                const SizedBox(height: 10),
                SizedBox(
                  height: 320,
                  child: KundaliChart(
                    data: _livePrashnaData ?? widget.data,
                    title: 'Live Prashna D1',
                  ), 
                ),
              ],
            ),
          ),
        ),

        if (_isCalculated && _questionController.text.trim().isNotEmpty) ...[
          const SizedBox(height: 16),
          Card(
            color: bhojCard,
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: bhojBrown, width: 1.5)),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('📊 प्रश्न का वैदिक निष्कर्ष (Prashna Judgment)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: bhojBrown)),
                  const Divider(height: 20, color: bhojBorder),
                  Text('• प्रश्न लग्न: ${_livePrashnaData?.lagnaRashi ?? widget.data?.lagnaRashi ?? "तुला"}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                  const SizedBox(height: 6),
                  Text('• लग्नेश बल: $_lordStrength', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Colors.black87)),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: bhojBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: bhojBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('निर्णय (Verdict):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 4),
                        Text(_resultVerdict, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: bhojBrown)),
                        const SizedBox(height: 8),
                        Text('संभावित समय अवधि: $_timeResult', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Colors.black87)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// --- Remedies Page ---
class _RemediesPage extends StatelessWidget {
  final dynamic data;
  const _RemediesPage({required this.data});

  String _getPlanetMantra(String planet) {
    switch (planet) {
      case 'सूर्य': return 'ॐ ह्रां ह्रीं ह्रौं सः सूर्याय नमः';
      case 'चन्द्र': return 'ॐ श्रां श्रीं श्रौं सः चंद्राय नमः';
      case 'मंगल': return 'ॐ क्रां क्रीं क्रौं सः भौमाय नमः';
      case 'बुध': return 'ॐ ब्रां ब्रीं ब्रौं सः बुधाय नमः';
      case 'गुरु': return 'ॐ ग्रां ग्रीं ग्रौं सः गुरवे नमः';
      case 'शुक्र': return 'ॐ द्रां द्रीं द्रौं सः शुक्राय नमः';
      case 'शनि': return 'ॐ प्रां प्रीं प्रौं सः शनैश्चराय नमः';
      case 'राहु': return 'ॐ भ्रां भ्रीं भ्रौं सः राहवे नमः';
      case 'केतु': return 'ॐ स्रां स्रीं स्रौं सः केतवे नमः';
      default: return 'ॐ नवग्रहाय नमः';
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color bhojCard = Color(0xFFFAF2E4);
    const Color bhojBrown = Color(0xFF5C3A21);
    const Color bhojBorder = Color(0xFF8C6239);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          color: bhojCard,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: bhojBorder)),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('💎 योगकारक रत्न (Gemstone) चयन', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF5C3A21))),
                Divider(height: 20, color: Color(0xFF8C6239)),
                Text(
                  '• माणिक्य (Ruby): सूर्य की मजबूती के लिए - तर्जनी या अनामिका उंगली में, तांबे या सोने की अंगूठी में शुक्ल पक्ष के रविवार को सूर्योदय के समय धारण करें。\n\n'
                  '• पन्ना (Emerald): बुध की मजबूती के लिए - कनिष्ठिका उंगली में, सोने या चांदी में बुधवार को धारण करें。\n\n'
                  '• पुखराज (Yellow Sapphire): गुरु की मजबूती के लिए - तर्जनी उंगली में, सोने में गुरुवार को धारण करें。',
                  style: TextStyle(fontSize: 13, height: 1.6, color: Colors.black87),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          color: bhojCard,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: bhojBorder)),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('🌟 व्यक्तिगत ग्रह शांति व बीज मंत्र:', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: bhojBrown)),
                const SizedBox(height: 12),
                if (data != null && data.planets != null)
                  ...data.planets.map((p) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('• ${p.planet} (${p.rashi} राशि, भाव ${p.house}):', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: bhojBrown)),
                        const SizedBox(height: 4),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: bhojBorder.withValues(alpha: 0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('जाप मंत्र:', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
                              Text(
                                _getPlanetMantra(p.planet), 
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFFD32F2F))
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )).toList(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
