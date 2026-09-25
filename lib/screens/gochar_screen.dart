import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/gochar_service.dart';
import '../services/sade_sati_service.dart';
import 'uma_screen.dart';

class GocharScreen extends StatefulWidget {
  const GocharScreen({super.key});

  @override
  State<GocharScreen> createState() => _GocharScreenState();
}

class _GocharScreenState extends State<GocharScreen> {
  String _moon = 'मीन';
  DailyGocharData? _data;
  SadeSatiStatus? _sade;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await GocharService.calculate(natalMoon: _moon);
      final sade = SadeSatiService.forMoonRashi(_moon);
      if (!mounted) return;
      setState(() {
        _data = data;
        _sade = sade;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '$e';
        _loading = false;
      });
    }
  }

  String _shareText(DailyGocharData d) {
    final vakri = d.planets.where((p) => p.isRetrograde).map((p) => p.planet).join(', ');
    final buf = StringBuffer()
      ..writeln('दैनिक नवग्रह गोचर • शक्ति पंचांग')
      ..writeln('स्थान: ${d.place} • लग्न ${d.lagnaRashi} • चंद्र ${d.moonRashi}')
      ..writeln();
    for (final p in d.planets) {
      buf.writeln(
        '${p.symbol} ${p.planet}: ${p.rashi} ${p.degreeInRashi.toStringAsFixed(1)}° — ${p.statusText} (${p.dignity})',
      );
    }
    if (d.yogas.isNotEmpty) {
      buf.writeln();
      buf.writeln('गोचर योग:');
      for (final y in d.yogas) {
        buf.writeln('• ${y.name}: ${y.description}');
      }
    }
    if (vakri.isNotEmpty) buf.writeln('\nवक्री: $vakri');
    buf.writeln(
      'चंद्र ~${d.moonHoursToNextSign.toStringAsFixed(1)} घंटे में ${d.nextMoonRashi} में जाएँगे।',
    );
    buf.writeln('॥ शुभम् भवतु • शक्ति पंचांग ॥');
    return buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    final d = _data;
    final s = _sade;
    final sun = d?.planets.where((p) => p.planet == 'सूर्य').firstOrNull;
    final vakri = d?.planets.where((p) => p.isRetrograde).toList() ?? const [];
    final ast = d?.planets.where((p) => p.isCombust).toList() ?? const [];
    return Scaffold(
      appBar: AppBar(
        title: const Text('दैनिक गोचर'),
        actions: [
          if (d != null)
            IconButton(
              tooltip: 'कॉपी करें',
              icon: const Icon(Icons.copy_rounded),
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: _shareText(d)));
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('गोचर विवरण कॉपी हो गया')),
                );
              },
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('जन्म चंद्र राशि', style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: SadeSatiService.rashis
                .map((r) => ChoiceChip(
                      label: Text(r),
                      selected: _moon == r,
                      onSelected: (_) {
                        setState(() => _moon = r);
                        _refresh();
                      },
                    ))
                .toList(),
          ),
          const SizedBox(height: 14),
          if (_loading) const LinearProgressIndicator(),
          if (_error != null) Text(_error!),
          if (d != null) ...[
            Row(
              children: [
                Expanded(
                  child: _snap('सूर्य गोचर', sun?.rashi ?? '—', sun == null ? '' : '${sun.degreeInRashi.toStringAsFixed(1)}°'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _snap('चंद्र गोचर', d.moonRashi, '~${d.moonHoursToNextSign.toStringAsFixed(0)} घं शेष'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _snap(
                    'वक्री (${vakri.length})',
                    vakri.isEmpty ? 'सभी मार्गी' : vakri.map((p) => p.planet).join(', '),
                    ast.isEmpty ? 'कोई अस्त नहीं' : '${ast.map((p) => p.planet).join(', ')} अस्त',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Card(
              child: ListTile(
                title: Text('${d.place} • लग्न ${d.lagnaRashi} • चंद्र ${d.moonRashi}'),
                subtitle: Text(
                  'चंद्र ${d.nextMoonRashi} में लगभग ${d.moonHoursToNextSign.toStringAsFixed(1)} घंटे में जाएँगे '
                  '(${d.moonRemainingDegrees.toStringAsFixed(1)}° शेष)',
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text('आज के ग्रह गोचर', style: TextStyle(fontWeight: FontWeight.w900)),
            for (final p in d.planets)
              Card(
                color: p.isCombust ? const Color(0xFFFFEBEE) : null,
                child: ListTile(
                  leading: Text(p.symbol, style: const TextStyle(fontSize: 22)),
                  title: Text(
                    '${p.planet} • ${p.rashi} ${p.degreeInRashi.toStringAsFixed(1)}°',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: Text(
                    '${p.statusText} • ${p.dignity}\nलग्न से भाव ${p.houseFromLagna} • चंद्र से भाव ${p.houseFromMoon}',
                  ),
                  isThreeLine: true,
                ),
              ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'सुझाव: दैनिक गोचर को चंद्र राशि से देखने पर मन, लाभ और स्वास्थ्य का फल स्पष्ट दिखता है। L = लग्न से भाव, M = चंद्र से भाव।',
                style: TextStyle(height: 1.4),
              ),
            ),
            if (d.yogas.isNotEmpty) ...[
              const Text('गोचर योग', style: TextStyle(fontWeight: FontWeight.w900)),
              for (final y in d.yogas)
                Card(
                  color: const Color(0xFFE8F5E9),
                  child: ListTile(
                    title: Text(y.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                    subtitle: Text('${y.planets.join(', ')}\n${y.description}'),
                  ),
                ),
            ],
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => UmaScreen(
                    date: DateTime.now(),
                    pageContext: 'दैनिक गोचर',
                    pageDescription: 'आज का नवग्रह गोचर फल और सात्विक उपाय',
                  ),
                ),
              ),
              icon: const Icon(Icons.auto_awesome),
              label: const Text('उमा से गोचर फल पूछें'),
            ),
          ],
          if (s != null) ...[
            const SizedBox(height: 12),
            const Text('शनि साढ़े साती / ढैया', style: TextStyle(fontWeight: FontWeight.w900)),
            Card(
              child: ListTile(
                title: Text('शनि ${s.shaniRashi} • चंद्र से भाव ${s.houseFromMoon}'),
                subtitle: Text(s.summary),
              ),
            ),
            for (final p in s.phases)
              Card(
                color: p.active ? const Color(0xFFFFF3CD) : null,
                child: ListTile(
                  title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                  subtitle: Text('${p.shaniRashi} • ${p.window}\n${p.description}'),
                  trailing: Text(p.active ? 'अभी' : p.intensity),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _snap(String title, String value, String sub) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(value, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900)),
            if (sub.isNotEmpty)
              Text(sub, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
