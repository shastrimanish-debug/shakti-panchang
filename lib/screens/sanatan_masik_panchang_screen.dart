import 'package:flutter/material.dart';
import '../services/sanatan_masik_panchang_service.dart';

class SanatanMasikPanchangScreen extends StatefulWidget {
  const SanatanMasikPanchangScreen({super.key});
  @override
  State<SanatanMasikPanchangScreen> createState() => _SanatanMasikPanchangScreenState();
}

class _SanatanMasikPanchangScreenState extends State<SanatanMasikPanchangScreen> {
  late int _year;
  late int _month;

  @override
  void initState() {
    super.initState();
    final n = DateTime.now();
    _year = n.year;
    _month = n.month - 1;
  }

  void _shift(int delta) {
    setState(() {
      _month += delta;
      if (_month < 0) {
        _month = 11;
        _year--;
      } else if (_month > 11) {
        _month = 0;
        _year++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final m = SanatanMasikPanchangService.month(_year, _month);
    return Scaffold(
      appBar: AppBar(
        title: const Text('सनातन मासिक पंचांग'),
        actions: [
          IconButton(onPressed: () => _shift(-1), icon: const Icon(Icons.chevron_left)),
          IconButton(onPressed: () => _shift(1), icon: const Icon(Icons.chevron_right)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Text('${m.titleHi}  $_year', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          Text('विक्रम संवत ${m.vikramSamvat}'),
          const SizedBox(height: 10),
          const Row(
            children: [
              Expanded(child: Center(child: Text('रवि', style: TextStyle(fontWeight: FontWeight.w800)))),
              Expanded(child: Center(child: Text('सोम', style: TextStyle(fontWeight: FontWeight.w800)))),
              Expanded(child: Center(child: Text('मंगल', style: TextStyle(fontWeight: FontWeight.w800)))),
              Expanded(child: Center(child: Text('बुध', style: TextStyle(fontWeight: FontWeight.w800)))),
              Expanded(child: Center(child: Text('गुरु', style: TextStyle(fontWeight: FontWeight.w800)))),
              Expanded(child: Center(child: Text('शुक्र', style: TextStyle(fontWeight: FontWeight.w800)))),
              Expanded(child: Center(child: Text('शनि', style: TextStyle(fontWeight: FontWeight.w800)))),
            ],
          ),
          const SizedBox(height: 6),
          _grid(m),
          const SizedBox(height: 16),
          const Text('इस माह के व्रत-पर्व', style: TextStyle(fontWeight: FontWeight.w900)),
          ...m.days.where((d) => d.badge != null).map((d) => ListTile(
                dense: true,
                title: Text('${d.dayNumber} ${d.weekday} — ${d.badge}'),
                subtitle: Text('${d.paksha} ${d.tithi} • ${d.nakshatra}'),
              )),
        ],
      ),
    );
  }

  Widget _grid(SanatanMasikMonth m) {
    final cells = <Widget>[];
    for (var i = 0; i < m.firstWeekday; i++) {
      cells.add(const SizedBox.shrink());
    }
    for (final d in m.days) {
      Color? bg;
      if (d.today) bg = const Color(0xFFFFE0A3);
      if (d.ekadashi || d.purnima || d.amavasya) bg = const Color(0xFFFFF0D0);
      cells.add(Container(
        margin: const EdgeInsets.all(2),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFFD7B07A)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${d.dayNumber}', style: const TextStyle(fontWeight: FontWeight.w900)),
            Text(d.tithi, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 9)),
            if (d.badge != null)
              Text(d.badge!, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 8, color: Color(0xFF7A3E00))),
          ],
        ),
      ));
    }
    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 0.72,
      children: cells,
    );
  }
}
