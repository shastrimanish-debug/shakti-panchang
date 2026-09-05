import 'package:flutter/material.dart';
import '../services/geocoding_service.dart';
import '../services/location_store.dart';

class LocationsScreen extends StatefulWidget {
  final SavedLocation? current;
  const LocationsScreen({super.key, this.current});

  @override
  State<LocationsScreen> createState() => _LocationsScreenState();
}

class _LocationsScreenState extends State<LocationsScreen> {
  final store = LocationStore();
  final geo = GeocodingService();
  final search = TextEditingController();
  List<SavedLocation> saved = [];
  List<PlaceResult> results = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    saved = await store.all();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  Future<void> _savePlace(PlaceResult p) async {
    final s = SavedLocation(
      name: p.displayName,
      latitude: p.latitude,
      longitude: p.longitude,
    );
    await store.save(s);
    await store.setSelected(s);
    if (!mounted) return;
    Navigator.pop(context, s);
  }

  Future<void> _manual() async {
    final name = TextEditingController();
    final lat = TextEditingController();
    final lon = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('स्थान जोड़ें'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: name, decoration: const InputDecoration(labelText: 'नाम')),
            TextField(controller: lat, keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Latitude')),
            TextField(controller: lon, keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Longitude')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('रद्द')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('सेव')),
        ],
      ),
    );
    final la = double.tryParse(lat.text);
    final lo = double.tryParse(lon.text);
    if (ok == true && name.text.trim().isNotEmpty && la != null && lo != null &&
        la >= -90 && la <= 90 && lo >= -180 && lo <= 180) {
      final s = SavedLocation(name: name.text.trim(), latitude: la, longitude: lo);
      await store.save(s);
      await store.setSelected(s);
      if (mounted) Navigator.pop(context, s);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('📍 मेरे स्थान')),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(
          controller: search,
          decoration: InputDecoration(
            labelText: 'शहर / गाँव खोजें',
            hintText: 'Vadodara, Mumbai, Burhanpur...',
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: const Icon(Icons.search),
              onPressed: () async {
                results = await geo.search(search.text);
                if (mounted) setState(() {});
              },
            ),
          ),
          onChanged: (v) async {
            if (v.trim().length < 3) {
              setState(() => results = []);
              return;
            }
            final r = await geo.search(v);
            if (mounted) setState(() => results = r);
          },
        ),
        if (results.isNotEmpty) ...[
          const SizedBox(height: 8),
          Card(child: Column(
            children: results.map((p) => ListTile(
              title: Text(p.displayName),
              subtitle: Text('${p.latitude.toStringAsFixed(4)}, ${p.longitude.toStringAsFixed(4)}'),
              trailing: const Icon(Icons.add_location_alt),
              onTap: () => _savePlace(p),
            )).toList(),
          )),
        ],
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _manual,
          icon: const Icon(Icons.edit_location_alt),
          label: const Text('Latitude / Longitude से स्थान जोड़ें'),
        ),
        const SizedBox(height: 18),
        const Text('सेव किए हुए स्थान', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        ...saved.map((s) => Card(
          child: ListTile(
            leading: const Icon(Icons.location_on),
            title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.w800)),
            subtitle: Text('${s.latitude.toStringAsFixed(4)}, ${s.longitude.toStringAsFixed(4)}'),
            onTap: () async {
              await store.setSelected(s);
              if (mounted) Navigator.pop(context, s);
            },
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                await store.remove(s);
                await _load();
              },
            ),
          ),
        )),
        const SizedBox(height: 18),
        const Text(
          'पंचांग, सूर्य समय और पर्व/व्रत की गणना स्थान के अनुसार बदल सकती है।',
          style: TextStyle(fontSize: 12, color: Colors.black54),
        ),
      ],
    ),
  );
}
