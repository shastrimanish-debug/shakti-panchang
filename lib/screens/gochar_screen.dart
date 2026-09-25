import 'package:flutter/material.dart';
import '../services/gochar_service.dart';
import '../services/sade_sati_service.dart';

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

  @override
  Widget build(BuildContext context) {
    final d = _data;
    final s = _sade;
    return Scaffold(
      appBar: AppBar(title: const Text('दैनिक गोचर')),
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
            if (d.yogas.isNotEmpty) ...[
              const SizedBox(height: 8),
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
}
