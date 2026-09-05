import 'package:flutter/material.dart';
import '../services/kundali_profile_store.dart';

const Color _bhojBg = Color(0xFFF4E8D1);
const Color _bhojCard = Color(0xFFFAF2E4);
const Color _bhojBrown = Color(0xFF5C3A21);
const Color _bhojBorder = Color(0xFF8C6239);

class SavedProfilesScreen extends StatefulWidget {
  const SavedProfilesScreen({super.key});

  @override
  State<SavedProfilesScreen> createState() => _SavedProfilesScreenState();
}

class _SavedProfilesScreenState extends State<SavedProfilesScreen> {
  List<Map<String, dynamic>> _savedProfiles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    final profiles = await KundaliProfileStore.getSavedProfiles();
    if (!mounted) return;
    setState(() {
      _savedProfiles = profiles;
      _isLoading = false;
    });
  }

  Future<void> _deleteProfile(int index) async {
    await KundaliProfileStore.deleteProfileData(_savedProfiles[index]);
    _loadProfiles(); 
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('प्रोफाइल सफलतापूर्वक हटा दी गई!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bhojBg,
      appBar: AppBar(
        backgroundColor: _bhojBrown,
        foregroundColor: _bhojBg,
        title: const Text(
          'सेव की गई कुंडलियाँ',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _bhojBrown))
          : _savedProfiles.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history_rounded, size: 80, color: _bhojBrown.withValues(alpha: 0.5)),
                      const SizedBox(height: 16),
                      const Text(
                        'कोई भी सेव की गई कुंडली नहीं मिली।\nनई कुंडली बनाएं और उसे सेव करें!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: _bhojBrown, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _savedProfiles.length,
                  itemBuilder: (context, index) {
                    final profile = _savedProfiles[index];
                    return Card(
                      color: _bhojCard,
                      elevation: 3,
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: _bhojBorder, width: 1.2),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: CircleAvatar(
                          radius: 26,
                          backgroundColor: _bhojBrown,
                          child: Text(
                            profile['name']?.substring(0, 1).toUpperCase() ?? '?',
                            style: const TextStyle(color: _bhojBg, fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(
                          profile['name'] ?? 'अज्ञात जातक',
                          style: const TextStyle(fontWeight: FontWeight.w900, color: _bhojBrown, fontSize: 18),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('📍 स्थान: ${profile['place'] ?? 'अज्ञात'}', style: const TextStyle(color: Colors.black87)),
                              const SizedBox(height: 4),
                              Text('📅 जन्म: ${profile['date']} | ⏰ ${profile['time']}', style: const TextStyle(color: Colors.black87)),
                            ],
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                backgroundColor: _bhojCard,
                                title: const Text('प्रोफाइल हटाएं?', style: TextStyle(color: _bhojBrown, fontWeight: FontWeight.bold)),
                                content: const Text('क्या आप सच में इस सेव की गई कुंडली को हटाना चाहते हैं?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: const Text('रद्द करें', style: TextStyle(color: _bhojBrown)),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(ctx);
                                      _deleteProfile(index);
                                    },
                                    child: const Text('हटाएं', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        onTap: () {
                          Navigator.pop(context, profile);
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
