import 'package:flutter/material.dart';

import '../models/astrologer_branding.dart';
import '../services/astrologer_branding_store.dart';

class AstrologerBrandingScreen extends StatefulWidget {
  const AstrologerBrandingScreen({super.key});

  @override
  State<AstrologerBrandingScreen> createState() =>
      _AstrologerBrandingScreenState();
}

class _AstrologerBrandingScreenState extends State<AstrologerBrandingScreen> {
  final _name = TextEditingController();
  final _title = TextEditingController(text: 'ज्योतिषाचार्य');
  final _phone = TextEditingController();
  final _city = TextEditingController();
  final _sansthan = TextEditingController();
  final _spec = TextEditingController();
  final _email = TextEditingController();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    AstrologerBrandingStore.load().then((b) {
      if (!mounted) return;
      _name.text = b.name;
      _title.text = b.title;
      _phone.text = b.phone;
      _city.text = b.city;
      _sansthan.text = b.sansthan;
      _spec.text = b.specialization;
      _email.text = b.email;
      setState(() => _loading = false);
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _title.dispose();
    _phone.dispose();
    _city.dispose();
    _sansthan.dispose();
    _spec.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final b = AstrologerBranding(
      name: _name.text.trim(),
      title: _title.text.trim().isEmpty ? 'ज्योतिषाचार्य' : _title.text.trim(),
      phone: _phone.text.trim(),
      city: _city.text.trim(),
      sansthan: _sansthan.text.trim(),
      specialization: _spec.text.trim(),
      email: _email.text.trim(),
    );
    await AstrologerBrandingStore.save(b);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('ज्योतिषी ब्रांडिंग सेव हो गई। PDF कवर पर छपेगी।')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ज्योतिषी ब्रांडिंग')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'यह नाम-पता कुंडली PDF और भोजपत्र पत्रिका के आवरण पर छपेगा — वेब ऐप के Astrologer Branding जैसा।',
                  style: TextStyle(height: 1.4),
                ),
                const SizedBox(height: 16),
                _field(_name, 'ज्योतिषी का नाम', 'उदा. पं. रमेश शास्त्री'),
                _field(_title, 'उपाधि / पद', 'ज्योतिषाचार्य / वैदिक दैवज्ञ'),
                _field(_phone, 'दूरभाष', '+91 …'),
                _field(_city, 'नगर / राज्य', 'वडोदरा / काशी'),
                _field(_sansthan, 'आश्रम / संस्थान', 'श्री शक्ति ज्योतिष संस्थान'),
                _field(_spec, 'विशेषज्ञता', 'जन्म पत्रिका, मिलान, वास्तु'),
                _field(_email, 'ईमेल (वैकल्पिक)', 'pandit@example.com'),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.save_rounded),
                  label: const Text('सेव करें'),
                ),
              ],
            ),
    );
  }

  Widget _field(TextEditingController c, String label, String hint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
