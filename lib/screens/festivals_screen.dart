import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/festival_service.dart';

class FestivalsScreen extends StatefulWidget {
  final DateTime date;
  const FestivalsScreen({super.key, required this.date});

  @override
  State<FestivalsScreen> createState() => _FestivalsScreenState();
}

class _FestivalsScreenState extends State<FestivalsScreen> {
  late int _year;
  String _q = '';
  String _centuryQ = '';
  bool _century = false;
  List<CenturySearchResult> _centuryHits = const [];
  bool _searching = false;

  @override
  void initState() {
    super.initState();
    _year = widget.date.year;
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('EEE, d MMM yyyy', 'hi_IN');
    final upcoming = FestivalService.upcoming(widget.date, count: 10);
    final yearList = FestivalService.forYear(_year)
        .where((f) => _q.isEmpty || f.name.toLowerCase().contains(_q.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('हिंदी त्योहार तिथियाँ')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: false, label: Text('वार्षिक सूची')),
              ButtonSegment(value: true, label: Text('200 वर्ष खोज')),
            ],
            selected: {_century},
            onSelectionChanged: (s) => setState(() => _century = s.first),
          ),
          const SizedBox(height: 12),
          if (!_century) ...[
            const Text('आगामी पर्व', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            ...upcoming.map((x) => _card(x, fmt, highlight: true)),
            const SizedBox(height: 16),
            Row(
              children: [
                IconButton(
                  onPressed: () => setState(() => _year = (_year - 1).clamp(1925, 2125)),
                  icon: const Icon(Icons.chevron_left),
                ),
                Expanded(
                  child: Text('वर्ष $_year  •  विक्रम संवत् ${_year + 57}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.w900)),
                ),
                IconButton(
                  onPressed: () => setState(() => _year = (_year + 1).clamp(1925, 2125)),
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
            TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'त्योहार खोजें',
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => setState(() => _q = v),
            ),
            const SizedBox(height: 8),
            ...yearList.map((x) => _card(x, fmt, highlight: false)),
          ] else ...[
            TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'दीपावली, होली, महाशिवरात्रि, करवा चौथ…',
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => _centuryQ = v,
              onSubmitted: (_) => _runCentury(),
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: _searching ? null : _runCentury,
              child: Text(_searching ? 'खोज हो रही है…' : '1925–2125 में खोजें'),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              children: ['दीपावली', 'होली', 'महाशिवरात्रि', 'करवा चौथ', 'जन्माष्टमी', 'दशहरा', 'गणेश चतुर्थी']
                  .map((p) => ActionChip(
                        label: Text(p),
                        onPressed: () {
                          _centuryQ = p;
                          _runCentury();
                        },
                      ))
                  .toList(),
            ),
            const SizedBox(height: 8),
            ..._centuryHits.take(40).map((h) => Card(
                  child: ListTile(
                    title: Text(h.festival.name, style: const TextStyle(fontWeight: FontWeight.w900)),
                    subtitle: Text(fmt.format(h.festival.date)),
                    trailing: Text('${h.year}', style: const TextStyle(fontWeight: FontWeight.w800)),
                  ),
                )),
            if (_centuryHits.length > 40)
              Text('और ${_centuryHits.length - 40} परिणाम…', textAlign: TextAlign.center),
          ],
        ],
      ),
    );
  }

  Future<void> _runCentury() async {
    final q = _centuryQ.trim();
    if (q.isEmpty) return;
    setState(() => _searching = true);
    await Future<void>.delayed(Duration.zero);
    final hits = FestivalService.searchAcross(query: q);
    if (!mounted) return;
    setState(() {
      _centuryHits = hits;
      _searching = false;
    });
  }

  Widget _card(FestivalItem x, DateFormat fmt, {required bool highlight}) {
    return Card(
      color: highlight ? const Color(0xFFFFF4DC) : null,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFB56A00),
          child: Text('${x.date.day}',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
        ),
        title: Text(x.name, style: const TextStyle(fontWeight: FontWeight.w900)),
        subtitle: Text('${fmt.format(x.date)} • ${x.type}${x.description == null ? '' : '\n${x.description}'}'),
        isThreeLine: x.description != null,
      ),
    );
  }
}
