import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart'; // तेरे pubspec में यह पहले से है

const Color _bhojBg = Color(0xFFF4E8D1);
const Color _bhojCard = Color(0xFFFAF2E4);
const Color _bhojBrown = Color(0xFF5C3A21);
const Color _bhojBorder = Color(0xFF8C6239);

class LocationSearchScreen extends StatefulWidget {
  const LocationSearchScreen({super.key});

  @override
  State<LocationSearchScreen> createState() => _LocationSearchScreenState();
}

class _LocationSearchScreenState extends State<LocationSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoadingGPS = false;
  bool _isLoadingSearch = false;
  Timer? _debounce;
  List<Map<String, dynamic>> _searchResults = [];

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // 🌟 जैसे-जैसे यूजर टाइप करेगा, यह फंक्शन स्मार्ट तरीके से API कॉल करेगा
  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    if (query.trim().length < 2) {
      setState(() {
        _searchResults = [];
        _isLoadingSearch = false;
      });
      return;
    }

    setState(() {
      _isLoadingSearch = true;
    });

    // API को स्पैम से बचाने के लिए 800ms का डिले (Debounce)
    _debounce = Timer(const Duration(milliseconds: 800), () {
      _fetchPlacesFromAPI(query.trim());
    });
  }

  // 🌍 ओपन-स्ट्रीट-मैप (OpenStreetMap) से दुनिया का कोई भी गाँव/शहर ढूंढने का लॉजिक
  Future<void> _fetchPlacesFromAPI(String query) async {
    try {
      final url = Uri.parse('https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}&format=json&addressdetails=1&limit=15');
      final request = await HttpClient().getUrl(url);
      request.headers.set('User-Agent', 'ShaktiPanchangApp/1.0'); // API ब्लॉक न हो इसलिए
      final response = await request.close();

      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        final List data = jsonDecode(responseBody);
        
        if (!mounted) return;
        setState(() {
          _searchResults = data.map((place) => {
            'fullName': place['display_name'], // पूरा पता (उदा: Burhanpur, MP, India)
            'shortName': place['name'] ?? place['display_name'].toString().split(',').first, // छोटा नाम
            'lat': double.tryParse(place['lat'].toString()) ?? 0.0,
            'lng': double.tryParse(place['lon'].toString()) ?? 0.0,
          }).toList();
          _isLoadingSearch = false;
        });
      } else {
        if (!mounted) return;
        setState(() => _isLoadingSearch = false);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingSearch = false);
    }
  }

  // 🛰️ असली लाइव GPS लोकेशन निकालने का लॉजिक
  Future<void> _fetchCurrentGPSLocation() async {
    setState(() {
      _isLoadingGPS = true;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showError('GPS बंद है। कृपया लोकेशन चालू करें।');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showError('लोकेशन की अनुमति नहीं मिली।');
          return;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        _showError('लोकेशन की अनुमति हमेशा के लिए बंद है। कृपया सेटिंग्स से चालू करें।');
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium),
      );
      
      String placeName = 'आपका वर्तमान स्थान (GPS)';
      
      // GPS कोऑर्डिनेट्स से शहर का नाम निकालने का प्रयास (Reverse Geocoding)
      try {
         final url = Uri.parse('https://nominatim.openstreetmap.org/reverse?lat=${position.latitude}&lon=${position.longitude}&format=json');
         final req = await HttpClient().getUrl(url);
         req.headers.set('User-Agent', 'ShaktiPanchangApp/1.0');
         final res = await req.close();
         if (res.statusCode == 200) {
           final body = await res.transform(utf8.decoder).join();
           final data = jsonDecode(body);
           if (data['name'] != null) {
             placeName = data['name'];
           }
         }
      } catch(e) {
        // अगर नाम न मिले तो डिफॉल्ट इस्तेमाल करें
      }

      if (!mounted) return;
      setState(() {
        _isLoadingGPS = false;
      });

      Navigator.pop(context, {
        'name': placeName,
        'lat': position.latitude,
        'lng': position.longitude,
      });
    } catch (e) {
      _showError('लोकेशन निकालने में समस्या आई।');
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    setState(() => _isLoadingGPS = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _selectCity(Map<String, dynamic> city) {
    Navigator.pop(context, {
      'name': city['shortName'], 
      'lat': city['lat'],
      'lng': city['lng'],
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bhojBg,
      appBar: AppBar(
        backgroundColor: _bhojBrown,
        foregroundColor: _bhojBg,
        title: const Text(
          'जन्म स्थान चुनें',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, letterSpacing: 0.5),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            color: _bhojBrown,
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 20, top: 10),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged, // 🌟 अब टाइप करते ही सर्च होगा
                  style: const TextStyle(color: _bhojBrown, fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    hintText: 'दुनिया का कोई भी शहर या गाँव खोजें',
                    hintStyle: TextStyle(color: _bhojBrown.withValues(alpha: 0.6)),
                    filled: true,
                    fillColor: _bhojCard,
                    prefixIcon: const Icon(Icons.search_rounded, color: _bhojBrown),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, color: _bhojBrown),
                            onPressed: () {
                              _searchController.clear();
                              _onSearchChanged('');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber.shade700,
                      foregroundColor: _bhojBrown,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _isLoadingGPS ? null : _fetchCurrentGPSLocation,
                    icon: _isLoadingGPS
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(color: _bhojBrown, strokeWidth: 2.5),
                          )
                        : const Icon(Icons.my_location_rounded),
                    label: Text(
                      _isLoadingGPS ? 'लोकेशन खोजी जा रही है...' : 'अपनी वर्तमान GPS लोकेशन का उपयोग करें',
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: _isLoadingSearch
                ? const Center(child: CircularProgressIndicator(color: _bhojBrown))
                : _searchResults.isEmpty && _searchController.text.isNotEmpty
                    ? const Center(
                        child: Text(
                          'कोई शहर नहीं मिला।\nकृपया अंग्रेजी में सही स्पेलिंग लिखें।',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: _bhojBrown, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _searchResults.length,
                        separatorBuilder: (context, index) => const Divider(color: _bhojBorder, height: 1),
                        itemBuilder: (context, index) {
                          final city = _searchResults[index];
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            leading: const CircleAvatar(
                              backgroundColor: _bhojBrown,
                              child: Icon(Icons.location_on_rounded, color: _bhojBg, size: 20),
                            ),
                            title: Text(
                              city['shortName'],
                              style: const TextStyle(fontWeight: FontWeight.bold, color: _bhojBrown, fontSize: 16),
                            ),
                            subtitle: Text(
                              city['fullName'], // पूरा पता दिखाएगा
                              style: TextStyle(color: Colors.black.withValues(alpha: 0.7), fontSize: 12),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: _bhojBorder),
                            onTap: () => _selectCity(city),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
