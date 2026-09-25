import 'package:flutter/material.dart';
import 'package:page_flip/page_flip.dart';
import '../models/kundali_model.dart';
import '../services/pdf_service.dart';
import '../services/kundali_calculator.dart';
import '../services/kundali_profile_store.dart'; 
import '../widgets/kundali_chart.dart';
import 'kundali_modules_screen.dart';
import 'location_search_screen.dart'; 
import 'saved_profiles_screen.dart';
import 'uma_screen.dart';
import 'personalized_prediction_screen.dart';  

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
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _placeController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  double _lat = 0.0;
  double _lng = 0.0;
  bool _isCalculated = false;
  late KundaliData _currentKundali;

  @override
  void initState() {
    super.initState();
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
        } catch (e) {}
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
    if (_nameController.text.trim().isEmpty || _placeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('\u0915\u0943\u092a\u092f\u093e \u091c\u093e\u0924\u0915 \u0915\u093e \u0928\u093e\u092e \u0914\u0930 \u091c\u0928\u094d\u092e \u0938\u094d\u0925\u093e\u0928 \u0926\u0930\u094d\u091c \u0915\u0930\u0947\u0902!')),
      );
      return;
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('\u0915\u0941\u0902\u0921\u0932\u0940 \u0915\u0940 \u0917\u0923\u0928\u093e \u0915\u0940 \u091c\u093e \u0930\u0939\u0940 \u0939\u0948...')),
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
          const SnackBar(content: Text('\u0915\u0941\u0902\u0921\u0932\u0940 \u0938\u092b\u0932\u0924\u093e\u092a\u0942\u0930\u094d\u0935\u0915 \u091c\u0928\u0930\u0947\u091f \u0914\u0930 \u0938\u0947\u0935 \u0915\u0930 \u0932\u0940 \u0917\u0908 \u0939\u0948!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('\u0917\u0923\u0928\u093e \u092e\u0947\u0902 \u0924\u094d\u0930\u0941\u091f\u093f: $e')),
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
          pageContext: const ['\u0915\u0941\u0902\u0921\u0932\u0940 \u0935\u093f\u0935\u0930\u0923', '\u091c\u0928\u094d\u092e \u0915\u0941\u0902\u0921\u0932\u0940 \u091a\u0915\u094d\u0930', '\u0915\u0941\u0902\u0921\u0932\u0940 \u092b\u0932'][_page],
          pageDescription: const ['\u091c\u093e\u0924\u0915 \u0935\u093f\u0935\u0930\u0923', 'D1', 'D1-D60'][_page],
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
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('\u0915\u0941\u0902\u0921\u0932\u0940', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 19)),
        actions: [
          IconButton(icon: const Icon(Icons.chevron_left_rounded), onPressed: _page > 0 ? () => _goToPage(_page - 1) : null),
          Center(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 2), child: Text('\u092a\u0928\u094d\u0928\u093e ${_page + 1}/3', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)))),
          IconButton(icon: const Icon(Icons.chevron_right_rounded), onPressed: _page < 2 ? () => _goToPage(_page + 1) : null),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_rounded),
            tooltip: _isCalculated ? 'PDF' : 'calculate first',
            onPressed: _isCalculated ? () => PdfService.generateAndSaveKundali(context, _currentKundali) : null,
          ),
          IconButton(
            icon: const Icon(Icons.menu_book_rounded),
            tooltip: _isCalculated ? 'exhaustive PDF' : 'calculate first',
            onPressed: _isCalculated ? () => PdfService.generateExhaustiveKundali(context, _currentKundali) : null,
          ),
          IconButton(icon: const Icon(Icons.auto_awesome_rounded), onPressed: _openUma),
          IconButton(
            icon: const Icon(Icons.insights_rounded),
            onPressed: _isCalculated ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => PersonalizedPredictionScreen(data: _currentKundali))) : null,
          ),
          IconButton(icon: const Icon(Icons.history_rounded), onPressed: _openHistory),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: _bhojBrown.withValues(alpha: .08),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _chapterDot('\u0935\u093f\u0935\u0930\u0923', 0),
                  _chapterLine(),
                  _chapterDot('\u091a\u0915\u094d\u0930', 1),
                  _chapterLine(),
                  _chapterDot('\u092b\u0932', 2),
                ],
              ),
            ),
            Expanded(child: PageFlipWidget(key: _pageKey, backgroundColor: _bhojBg, children: pages)),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(onPressed: _page > 0 ? () => _goToPage(_page - 1) : null, icon: const Icon(Icons.arrow_back_ios_rounded, size: 16), label: const Text('prev')),
                  TextButton.icon(onPressed: _page < 2 ? () => _goToPage(_page + 1) : null, icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16), label: const Text('next')),
                ],
              ),
            ),
          ],
        ),
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
        decoration: BoxDecoration(color: active ? _bhojBrown : Colors.transparent, borderRadius: BorderRadius.circular(20)),
        child: Text(label, style: TextStyle(color: active ? _bhojBg : _bhojBrown, fontWeight: FontWeight.w800, fontSize: 12)),
      ),
    );
  }

  Widget _chapterLine() => Container(width: 22, height: 1, color: _bhojBorder);

  Widget _bookContentPage(Widget child) => Container(
    color: _bhojBg,
    child: Column(children: [if (_isCalculated) _birthDataRibbon(), Expanded(child: child)]),
  );

  Widget _birthDataRibbon() => Container(
    width: double.infinity,
    margin: const EdgeInsets.fromLTRB(12, 6, 12, 2),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
    decoration: BoxDecoration(color: _bhojCard, borderRadius: BorderRadius.circular(10), border: Border.all(color: _bhojBorder.withValues(alpha: .65))),
    child: Text(
      '${_currentKundali.name}  •  ${_currentKundali.birthDate.day}-${_currentKundali.birthDate.month}-${_currentKundali.birthDate.year}  •  ${_currentKundali.birthTime}  •  ${_currentKundali.birthPlace}',
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
                const Text('\u091c\u093e\u0924\u0915 \u091c\u0928\u094d\u092e \u0935\u093f\u0935\u0930\u0923', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: _bhojBrown)),
                const SizedBox(height: 12),
                TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                TextField(
                  controller: _placeController,
                  readOnly: true,
                  onTap: _openLocationSearch,
                  decoration: const InputDecoration(labelText: 'Place', border: OutlineInputBorder(), suffixIcon: Icon(Icons.location_on_rounded, color: _bhojBrown)),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: _pickDate,
                        child: InputDecorator(
                          decoration: const InputDecoration(labelText: 'Date', border: OutlineInputBorder()),
                          child: Text('${_selectedDate.day}-${_selectedDate.month}-${_selectedDate.year}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: _pickTime,
                        child: InputDecorator(
                          decoration: const InputDecoration(labelText: 'Time', border: OutlineInputBorder()),
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
                    label: const Text('Calculate'),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        if (_isCalculated) ...[
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: _bhojBrown, foregroundColor: _bhojBg),
              onPressed: () => PdfService.generateAndSaveKundali(context, _currentKundali),
              icon: const Icon(Icons.picture_as_pdf_rounded),
              label: const Text('PDF'),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: OutlinedButton.icon(
              onPressed: () => PdfService.generateExhaustiveKundali(context, _currentKundali),
              icon: const Icon(Icons.menu_book_rounded),
              label: const Text('\u0935\u093f\u0938\u094d\u0924\u0943\u0924 \u0915\u0941\u0902\u0921\u0932\u0940 \u092a\u0924\u094d\u0930\u093f\u0915\u093e'),
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
                  Text('\u0932\u0917\u094d\u0928 ${_currentKundali.lagnaRashi}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  Text('\u091a\u0902\u0926\u094d\u0930 ${_currentKundali.moonRashi}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  Text('\u0928\u0915\u094d\u0937\u0924\u094d\u0930 ${_currentKundali.nakshatra}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
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
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(backgroundColor: _bhojBrown, foregroundColor: _bhojBg),
          onPressed: _calculateKundali,
          icon: const Icon(Icons.calculate_rounded),
          label: const Text('Calculate'),
        ),
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text('D1', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: _bhojBrown)),
          const SizedBox(height: 12),
          Container(
            height: 350,
            decoration: BoxDecoration(color: _bhojCard, border: Border.all(color: _bhojBorder, width: 2), borderRadius: BorderRadius.circular(12)),
            child: KundaliChart(data: _currentKundali, title: 'D1', embedded: true),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: _bhojBrown, foregroundColor: _bhojBg),
              onPressed: () => PdfService.generateAndSaveKundali(context, _currentKundali),
              icon: const Icon(Icons.picture_as_pdf_rounded),
              label: const Text('PDF'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModulesTab() {
    if (!_isCalculated) {
      return Center(
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(backgroundColor: _bhojBrown, foregroundColor: _bhojBg),
          onPressed: _calculateKundali,
          icon: const Icon(Icons.calculate_rounded),
          label: const Text('Calculate'),
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
          title: const Text('D1-D60'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => KundaliModulesScreen(data: _currentKundali))),
        ),
      ],
    );
  }
}
