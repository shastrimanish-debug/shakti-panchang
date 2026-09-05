import 'package:flutter/material.dart';
import 'package:page_flip/page_flip.dart';
import '../models/kundali_model.dart';
import '../services/pdf_service.dart';
import '../services/kundali_calculator.dart';
import '../services/kundali_profile_store.dart'; 
import '../widgets/kundali_chart.dart'; // 🌟 असली चार्ट दिखाने के लिए इसे इम्पोर्ट किया
import 'kundali_modules_screen.dart';
import 'location_search_screen.dart'; 
import 'saved_profiles_screen.dart';
import 'uma_screen.dart';  

const Color _bhojBg = Color(0xFFF4E8D1);
const Color _bhojCard = Color(0xFFFAF2E4);
const Color _bhojBrown = Color(0xFF5C3A21);
const Color _bhojBorder = Color(0xFF8C6239);

class KundaliScreen extends StatefulWidget {
  const KundaliScreen({super.key});

  @override
  State<KundaliScreen> createState() => _KundaliScreenState();
}

class _KundaliScreenState extends State<KundaliScreen> {
  GlobalKey<PageFlipWidgetState> _pageKey = GlobalKey<PageFlipWidgetState>();
  int _page = 0;
  
  // 🌟 डिफ़ॉल्ट नाम और जगह हटा दी गई है (अब यह खाली रहेगा)
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _placeController = TextEditingController();
  
  // 🌟 डिफ़ॉल्ट तारीख और समय अब आज का (Current) रहेगा
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  
  double _lat = 0.0;
  double _lng = 0.0;

  bool _isCalculated = false;
  late KundaliData _currentKundali;

  @override
  void initState() {
    super.initState();
    // Book mode: details, chart and फल are real pages with the same page-turn interaction.
  }

  Future<void> _openLocationSearch() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LocationSearchScreen()),
    );
    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _placeController.text = result['name'];
        _lat = (result['lat'] as num).toDouble();
        _lng = (result['lng'] as num).toDouble();
        _isCalculated = false;
      });
    }
  }

  Future<void> _openHistory() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SavedProfilesScreen()),
    );
    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _nameController.text = result['name'] ?? '';
        _placeController.text = result['place'] ?? '';
        _lat = (result['lat'] as num?)?.toDouble() ?? 0.0;
        _lng = (result['lng'] as num?)?.toDouble() ?? 0.0;
        
        try {
          if (result['date'] != null) {
            final parts = result['date'].split('-');
            if (parts.length == 3) {
              _selectedDate = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
            }
          }
          if (result['time'] != null) {
            final tParts = result['time'].split(':');
            if (tParts.length == 2) {
              _selectedTime = TimeOfDay(hour: int.parse(tParts[0]), minute: int.parse(tParts[1]));
            }
          }
        } catch (e) {
          // Fallback
        }
        
      });
      await _calculateKundali();
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(data: ThemeData.light().copyWith(primaryColor: _bhojBrown, colorScheme: const ColorScheme.light(primary: _bhojBrown)), child: child!),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _isCalculated = false;
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) => Theme(data: ThemeData.light().copyWith(primaryColor: _bhojBrown, colorScheme: const ColorScheme.light(primary: _bhojBrown)), child: child!),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        _isCalculated = false;
      });
    }
  }

  Future<void> _calculateKundali() async {
    // 🌟 वैलिडेशन: अगर नाम या जगह खाली है, तो एरर दिखाओ
    if (_nameController.text.trim().isEmpty || _placeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('कृपया जातक का नाम और जन्म स्थान दर्ज करें!')),
      );
      return;
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('कुंडली की गणना की जा रही है...')),
      );
    }

    try {
      final formattedTime = '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';
      
      final calculatedData = await KundaliCalculator.calculate(
        name: _nameController.text.trim(),
        birthDate: _selectedDate,
        birthTime: formattedTime,
        birthPlace: _placeController.text.trim(),
        latitude: _lat,
        longitude: _lng,
        timezoneHours: 5.5,
      );

      if (mounted) {
        setState(() {
          _currentKundali = calculatedData;
          _isCalculated = true;
          _page = 0;
          _pageKey = GlobalKey<PageFlipWidgetState>();
        });
      }

      await KundaliProfileStore.saveProfile({
        'name': _nameController.text.trim(),
        'place': _placeController.text.trim(),
        'lat': _lat,
        'lng': _lng,
        'date': '${_selectedDate.day}-${_selectedDate.month}-${_selectedDate.year}',
        'time': formattedTime,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('कुंडली सफलतापूर्वक जनरेट और सेव कर ली गई है!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('गणना में त्रुटि: $e')),
        );
      }
    }
  }

  void _goToPage(int page) {
    if (page < 0 || page > 2) return;
    _pageKey.currentState?.goToPage(page);
    if (mounted) setState(() => _page = page);
  }

  void _openUma() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UmaScreen(
          date: DateTime.now(),
          kundali: _isCalculated ? _currentKundali : null,
          pageContext: const ['कुंडली विवरण', 'जन्म कुंडली चक्र', 'कुंडली फल/अडवांस्ड मॉड्यूल्स'][_page],
          pageDescription: const ['जातक का नाम, जन्म स्थान, तिथि और समय तथा गणना के बाद के मुख्य तथ्य।', 'D1 लग्न कुंडली और ग्रहों की स्थिति।', 'D1-D60, दशा, प्रश्न कुंडली, मिलान और वैदिक उपायों तक पहुँच।'][_page],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      _bookContentPage(_buildInputAndSummaryTab()),
      _bookContentPage(_buildGraphicalKundaliChart()),
      _bookContentPage(_buildModulesTab()),
    ];

    return Scaffold(
      backgroundColor: _bhojBg,
      appBar: AppBar(
        backgroundColor: _bhojBrown,
        foregroundColor: _bhojBg,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'पिछले अध्याय पर जाएँ',
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text('कुंडली', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 19)),
        actions: [
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded),
            tooltip: 'पिछला पन्ना',
            onPressed: _page > 0 ? () => _goToPage(_page - 1) : null,
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Text('पन्ना ${_page + 1}/3', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded),
            tooltip: 'अगला पन्ना',
            onPressed: _page < 2 ? () => _goToPage(_page + 1) : null,
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_rounded),
            tooltip: _isCalculated ? 'सम्पूर्ण PDF रिपोर्ट' : 'पहले कुंडली की गणना करें',
            onPressed: _isCalculated ? () => PdfService.generateAndSaveKundali(context, _currentKundali) : null,
          ),
          IconButton(
            icon: const Icon(Icons.auto_awesome_rounded),
            tooltip: 'उमा — इस पन्ने की जानकारी',
            onPressed: _openUma,
          ),
          IconButton(
            icon: const Icon(Icons.history_rounded),
            tooltip: 'सेव की गई कुंडलियां',
            onPressed: _openHistory,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: _bhojBrown.withValues(alpha: .08),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _chapterDot('विवरण', 0),
                _chapterLine(),
                _chapterDot('चक्र', 1),
                _chapterLine(),
                _chapterDot('फल', 2),
              ],
            ),
          ),
          Expanded(
            child: PageFlipWidget(
              key: _pageKey,
              backgroundColor: _bhojBg,
              children: pages,
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: _page > 0 ? () => _goToPage(_page - 1) : null,
                  icon: const Icon(Icons.arrow_back_ios_rounded, size: 16),
                  label: const Text('पिछला पन्ना'),
                ),
                Text('बाएँ/दाएँ स्वाइप करके पन्ना पलटें', style: TextStyle(color: _bhojBrown.withValues(alpha: .65), fontSize: 11)),
                TextButton.icon(
                  onPressed: _page < 2 ? () => _goToPage(_page + 1) : null,
                  icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                  label: const Text('अगला पन्ना'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chapterDot(String label, int index) {
    final active = _page == index;
    return InkWell(
      onTap: () => _goToPage(index),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? _bhojBrown : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label, style: TextStyle(color: active ? _bhojBg : _bhojBrown, fontWeight: FontWeight.w800, fontSize: 12)),
      ),
    );
  }

  Widget _chapterLine() => Container(width: 22, height: 1, color: _bhojBorder);

  Widget _bookContentPage(Widget child) => Container(
    color: _bhojBg,
    child: Column(
      children: [
        if (_isCalculated) _birthDataRibbon(),
        Expanded(child: child),
      ],
    ),
  );

  Widget _birthDataRibbon() => Container(
    width: double.infinity,
    margin: const EdgeInsets.fromLTRB(12, 6, 12, 2),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
    decoration: BoxDecoration(
      color: _bhojCard,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: _bhojBorder.withValues(alpha: .65)),
    ),
    child: Text(
      'जातक: ${_currentKundali.name}  •  जन्म: ${_currentKundali.birthDate.day}-${_currentKundali.birthDate.month}-${_currentKundali.birthDate.year}  •  समय: ${_currentKundali.birthTime}  •  स्थान: ${_currentKundali.birthPlace}',
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
      style: const TextStyle(color: _bhojBrown, fontWeight: FontWeight.w800, fontSize: 11),
    ),
  );

  Widget _buildInputAndSummaryTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          color: _bhojCard,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: _bhojBorder)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('जातक का जन्म विवरण', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: _bhojBrown)),
                const SizedBox(height: 12),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'जातक का नाम', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                
                TextField(
                  controller: _placeController,
                  readOnly: true,
                  onTap: _openLocationSearch,
                  decoration: const InputDecoration(
                    labelText: 'जन्म स्थान (शहर)', 
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.location_on_rounded, color: _bhojBrown),
                  ),
                ),
                const SizedBox(height: 12),
                
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: _pickDate,
                        child: InputDecorator(
                          decoration: const InputDecoration(labelText: 'जन्म तिथि', border: OutlineInputBorder()),
                          child: Text('${_selectedDate.day}-${_selectedDate.month}-${_selectedDate.year}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: _pickTime,
                        child: InputDecorator(
                          decoration: const InputDecoration(labelText: 'जन्म समय', border: OutlineInputBorder()),
                          child: Text(_selectedTime.format(context), style: const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: _bhojBrown, foregroundColor: _bhojBg),
                    onPressed: _calculateKundali,
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('कुंडली की गणना व सेव करें', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        if (_isCalculated) ...[
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: _bhojBrown, foregroundColor: _bhojBg),
              onPressed: () => PdfService.generateAndSaveKundali(context, _currentKundali),
              icon: const Icon(Icons.picture_as_pdf_rounded),
              label: const Text('सम्पूर्ण PDF रिपोर्ट', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 10),
          Card(
            color: _bhojCard,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: _bhojBorder)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('मुख्य ज्योतिषीय तथ्य', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: _bhojBrown)),
                  const Divider(color: _bhojBorder),
                  Text('• लग्न राशि: ${_currentKundali.lagnaRashi}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text('• चंद्र राशि: ${_currentKundali.moonRashi}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text('• नक्षत्र: ${_currentKundali.nakshatra}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildGraphicalKundaliChart() {
    if (!_isCalculated) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.auto_graph_rounded, size: 64, color: _bhojBrown),
              const SizedBox(height: 14),
              const Text('चक्र अभी तैयार नहीं है', textAlign: TextAlign.center, style: TextStyle(color: _bhojBrown, fontWeight: FontWeight.w900, fontSize: 19)),
              const SizedBox(height: 8),
              const Text('दिखाई गई जन्म तिथि और समय के अनुसार वास्तविक D1 कुंडली बनाने के लिए गणना करें।', textAlign: TextAlign.center, style: TextStyle(color: _bhojBrown, fontSize: 14, height: 1.4)),
              const SizedBox(height: 18),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: _bhojBrown, foregroundColor: _bhojBg),
                onPressed: _calculateKundali,
                icon: const Icon(Icons.calculate_rounded),
                label: const Text('अभी कुंडली की गणना करें'),
              ),
            ],
          ),
        ),
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text('उत्तर भारतीय जन्म कुंडली चक्र (D1)', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: _bhojBrown)),
          const SizedBox(height: 12),
          Container(
            height: 350,
            decoration: BoxDecoration(
              color: _bhojCard,
              border: Border.all(color: _bhojBorder, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
            // 🌟 डमी लाइन्स हटाकर असली KundaliChart विजेट लगा दिया है
            child: KundaliChart(
              data: _currentKundali,
              title: 'D1 (लग्न)',
              embedded: true,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: _bhojBrown, foregroundColor: _bhojBg),
              // ✅ यहाँ context को सही से पास कर दिया गया है
              onPressed: () => PdfService.generateAndSaveKundali(context, _currentKundali),
              icon: const Icon(Icons.picture_as_pdf_rounded),
              label: const Text('सम्पूर्ण PDF रिपोर्ट डाउनलोड करें', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModulesTab() {
    if (!_isCalculated) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.auto_awesome_rounded, size: 64, color: _bhojBrown),
              const SizedBox(height: 14),
              const Text('फल एवं उन्नत मॉड्यूल तैयार नहीं हैं', textAlign: TextAlign.center, style: TextStyle(color: _bhojBrown, fontWeight: FontWeight.w900, fontSize: 19)),
              const SizedBox(height: 8),
              const Text('पहले इसी पेज पर दिखाई दे रही जन्म तिथि, समय और स्थान के साथ गणना करें।', textAlign: TextAlign.center, style: TextStyle(color: _bhojBrown, fontSize: 14, height: 1.4)),
              const SizedBox(height: 18),
              ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: _bhojBrown, foregroundColor: _bhojBg), onPressed: _calculateKundali, icon: const Icon(Icons.calculate_rounded), label: const Text('अभी गणना करें')),
            ],
          ),
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ListTile(
          tileColor: _bhojCard,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: _bhojBorder)),
          leading: const Icon(Icons.menu_book_rounded, color: _bhojBrown),
          title: const Text('अडवांस्ड कुंडली मॉड्यूल्स (D1-D60)', style: TextStyle(fontWeight: FontWeight.bold, color: _bhojBrown)),
          subtitle: const Text('प्रश्न कुंडली, वर्ग चार्ट, दशा और उपाय देखें'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => KundaliModulesScreen(data: _currentKundali)));
          },
        ),
      ],
    );
  }
}
