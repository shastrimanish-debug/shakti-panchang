import 'package:flutter/material.dart';
import '../models/panchang_models.dart';
import '../services/disha_service.dart';
import '../services/yatra_service.dart';
import '../services/yatra_advisor_service.dart';
import '../services/geocoding_service.dart';
import '../services/uma_ai_service.dart';
import '../services/solar_service.dart';
import 'digital_compass_screen.dart';

class YatraScreen extends StatefulWidget {
  final double fromLat;
  final double fromLon;
  final String fromName;
  final DateTime date;
  final PlaceResult? initialPlace;

  const YatraScreen({
    super.key,
    required this.fromLat,
    required this.fromLon,
    required this.fromName,
    required this.date,
    this.initialPlace,
  });

  @override
  State<YatraScreen> createState() => _YatraScreenState();
}

class _YatraScreenState extends State<YatraScreen> {
  final toLat = TextEditingController();
  final toLon = TextEditingController();
  final toName = TextEditingController();
  final uma = UmaAiService();
  final geo = GeocodingService();

  List<PlaceResult> suggestions = const [];
  YatraResult? result;
  YatraAdvice? advice;
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime(widget.date.year, widget.date.month, widget.date.day);
    if (widget.initialPlace != null) {
      final p = widget.initialPlace!;
      toName.text = p.displayName;
      toLat.text = p.latitude.toString();
      toLon.text = p.longitude.toString();
    }
  }

  @override
  void dispose() {
    toLat.dispose();
    toLon.dispose();
    toName.dispose();
    super.dispose();
  }

  Future<void> pickDate() async {
    final d = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDate: selectedDate.isBefore(DateTime.now().subtract(const Duration(days: 1)))
          ? DateTime.now()
          : selectedDate,
    );
    if (d != null) setState(() {
      selectedDate = DateTime(d.year, d.month, d.day);
      result = null;
      advice = null;
    });
  }

  void calculate() {
    final lat = double.tryParse(toLat.text.trim());
    final lon = double.tryParse(toLon.text.trim());
    if (lat == null || lon == null || lat < -90 || lat > 90 || lon < -180 || lon > 180) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Destination latitude/longitude sahi bharein.')),
      );
      return;
    }

    final shool = DishaService.avoided(selectedDate);
    final r = YatraService.check(
      fromLat: widget.fromLat,
      fromLon: widget.fromLon,
      toLat: lat,
      toLon: lon,
      shoolDirection: shool,
    );
    final solar = SolarService.forDate(
      date: selectedDate,
      latitude: widget.fromLat,
      longitude: widget.fromLon,
    );
    final times = SolarTimes(
      sunrise: solar.sunrise,
      sunset: solar.sunset,
      nextSunrise: solar.nextSunrise,
    );
    final a = YatraAdvisorService.advise(
      solar: times,
      weekday: selectedDate.weekday,
      direction: r.direction,
      blockedDirection: shool,
    );

    setState(() {
      result = r;
      advice = a;
    });
  }

  Future<void> speak() async {
    final r = result;
    final a = advice;
    if (r == null || a == null) return;
    final dest = toName.text.isEmpty ? 'tumhare shahar' : toName.text;
    await uma.speak(
      'Suno. ${widget.fromName} se $dest ${r.direction} disha mein hai. '
      'Aaj dishashool ${DishaService.avoided(selectedDate)} mein hai. ${a.summary}',
    );
  }

  String fmt(DateTime x) =>
      '${x.hour.toString().padLeft(2, '0')}:${x.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final r = result;
    final a = advice;
    return Scaffold(
      appBar: AppBar(title: const Text('Yatra muhurat')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.calendar_month),
              title: const Text('Yatra ki tarikh'),
              subtitle: Text('${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'),
              trailing: const Icon(Icons.edit_calendar),
              onTap: pickDate,
            ),
          ),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'From: ${widget.fromName}\nUs din ka dishashool: ${DishaService.avoided(selectedDate)}',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: toName,
            decoration: InputDecoration(
              labelText: 'Gantavya shahar / gaon',
              hintText: 'jaise Mumbai, Ujjain, Vadodara',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: const Icon(Icons.search),
                onPressed: () async {
                  final r = await geo.search(toName.text);
                  if (!mounted) return;
                  setState(() => suggestions = r);
                },
              ),
            ),
            onChanged: (v) async {
              if (v.trim().length < 3) {
                setState(() => suggestions = const []);
                return;
              }
              final r = await geo.search(v);
              if (!mounted) return;
              setState(() => suggestions = r);
            },
          ),
          if (suggestions.isNotEmpty)
            Card(
              child: Column(
                children: suggestions.map((p) => ListTile(
                  title: Text(p.displayName),
                  subtitle: Text('${p.latitude.toStringAsFixed(5)}, ${p.longitude.toStringAsFixed(5)}'),
                  onTap: () => setState(() {
                    toName.text = p.displayName;
                    toLat.text = p.latitude.toString();
                    toLon.text = p.longitude.toString();
                    suggestions = const [];
                  }),
                )).toList(),
              ),
            ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: calculate,
            icon: const Icon(Icons.navigation_rounded),
            label: const Text('Disha + shubh yatra samay'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DigitalCompassScreen(
                    shoolDirection: DishaService.avoided(selectedDate),
                    targetBearing: result?.bearing,
                    targetName: toName.text.trim().isEmpty ? null : toName.text.trim(),
                    blocked: result?.directionShool ?? false,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.explore_rounded),
            label: const Text('Vaidik disha-soochak kholen'),
          ),
          if (r != null && a != null) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(' ${r.direction}',
                        style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 8),
                    Text('Bearing: ${r.bearing.toStringAsFixed(1)}'),
                    const SizedBox(height: 10),
                    Text(
                      r.directionShool ? 'Dishashool se prabhavit' : 'Dishashool se seedhe varjit nahi',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 8),
                    Text(a.summary),
                    if (a.blockedTimes.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      const Text('Rahu / Yamaganda / Gulika',
                          style: TextStyle(fontWeight: FontWeight.w900)),
                      const SizedBox(height: 4),
                      ...a.blockedTimes.map((p) => ListTile(
                        dense: true,
                        leading: const Icon(Icons.block_rounded),
                        title: Text('${p.name} • ${fmt(p.start)} – ${fmt(p.end)}'),
                        subtitle: Text(p.meaning),
                      )),
                    ],
                    const SizedBox(height: 14),
                    const Text('Behtar yatra window',
                        style: TextStyle(fontWeight: FontWeight.w900)),
                    const SizedBox(height: 6),
                    ...a.suitable.take(6).map((p) => ListTile(
                      dense: true,
                      leading: Icon(
                        p.nature == ChoghadiyaNature.auspicious
                            ? Icons.check_circle
                            : Icons.remove_circle_outline,
                      ),
                      title: Text('${p.name} • ${fmt(p.start)} – ${fmt(p.end)}'),
                      subtitle: Text(p.meaning),
                    )),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: speak,
                      icon: const Icon(Icons.volume_up_rounded),
                      label: const Text('Uma se sunen'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
