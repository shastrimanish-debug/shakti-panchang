import 'package:flutter/material.dart';
import '../services/sade_sati_service.dart';

class GocharScreen extends StatefulWidget {
  const GocharScreen({super.key});

  @override
  State<GocharScreen> createState() => _GocharScreenState();
}

class _GocharScreenState extends State<GocharScreen> {
  String _moon = 'मीन';
  SadeSatiStatus? _status;
  String? _error;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      _error = null;
      _status = SadeSatiService.forMoonRashi(_moon);
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = _status;
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
          if (_error != null) Text(_error!),
          if (s != null) ...[
            Card(
              child: ListTile(
                title: Text('शनि ${s.shaniRashi} • चंद्र से भाव ${s.houseFromMoon}'),
                subtitle: Text(s.summary),
              ),
            ),
            const SizedBox(height: 8),
            const Text('साढ़े साती चरण', style: TextStyle(fontWeight: FontWeight.w900)),
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
