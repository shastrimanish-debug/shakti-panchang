import 'package:flutter/material.dart';
import 'package:page_flip/page_flip.dart';

import '../config/app_config.dart';
import 'festivals_screen.dart';
import 'kundali_screen.dart';
import 'muhurat_screen.dart';
import 'reminder_screen.dart';
import 'yatra_screen.dart';
import 'panchang_detail_screen.dart';
import 'premium_screen.dart';
import 'app_settings_screen.dart';
import 'choghadiya_screen.dart';
import 'location_search_screen.dart';
import 'daily_rashifal_screen.dart';
import 'numerology_screen.dart';
import 'saved_profiles_screen.dart';
import 'vrat_katha_screen.dart';
import 'sanatan_masik_panchang_screen.dart';
import 'sade_sati_screen.dart';
import 'daily_shloka_screen.dart';
import 'hora_chakra_screen.dart';
import 'gochar_screen.dart';
import 'annual_muhurat_screen.dart';
import 'digital_compass_screen.dart';
import 'moon_phase_screen.dart';
import 'astrologer_branding_screen.dart';
import 'varga_analysis_screen.dart';
import '../services/astronomical_panchang_service.dart';
import '../models/astronomical_panchang.dart';
import '../services/solar_service.dart';
import '../services/location_store.dart';
import '../services/license_service.dart';
import '../models/panchang_models.dart';
import 'uma_screen.dart';
import '../widgets/ad_gate.dart';

const _bg = Color(0xFFF4E8D1);
const _paper = Color(0xFFFFF9EE);
const _brown = Color(0xFF5C3A21);
const _gold = Color(0xFFB56A00);

class BookHomeScreen extends StatefulWidget {
  const BookHomeScreen({super.key});

  @override
  State<BookHomeScreen> createState() => _BookHomeScreenState();
}

class _BookHomeScreenState extends State<BookHomeScreen> {
  GlobalKey<PageFlipWidgetState> _pageKey = GlobalKey<PageFlipWidgetState>();
  int _page = 0;
  int _bookStart = 0;
  SavedLocation? _location;
  Future<AstronomicalPanchang>? _panchangFuture;
  String? _panchangCacheKey;
  bool _openingPanchang = false;

  @override
  void initState() {
    super.initState();
    _primePanchang();
    LicenseService.instance.init().then((_) {
      if (mounted) setState(() {});
    });
    LocationStore().selected().then((value) {
      if (!mounted) return;
      setState(() {
        _location = value;
        _panchangFuture = null;
        _panchangCacheKey = null;
      });
      _primePanchang();
    });
  }

  double get _lat => _location?.latitude ?? 23.1765;
  double get _lon => _location?.longitude ?? 75.7885;
  String get _place => _location?.name ?? 'Ujjain';

  void _go(int page) {
    _pageKey.currentState?.goToPage(page);
    setState(() => _page = page);
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      KeyedSubtree(key: const ValueKey('cover'), child: _cover(context)),
      KeyedSubtree(key: const ValueKey('panchang'), child: _sectionPage(context, 'पंचांग', 'तिथि • नक्षत्र • योग • करण • सूर्य समय', Icons.calendar_month, () => _openPanchang())),
      KeyedSubtree(key: const ValueKey('kundali'), child: _sectionPage(context, 'कुंडली', 'जन्म कुंडली • वर्ग • दशा • फलित', Icons.auto_awesome, () async {
        await _openRoute(const KundaliScreen());
      })),
      KeyedSubtree(key: const ValueKey('daily_rashifal'), child: _sectionPage(context, 'दैनिक राशिफल', 'जन्म-कुंडली • दशा • गोचर • शुभ अंक', Icons.wb_sunny_rounded, () async {
        await _openRoute(const DailyRashifalScreen());
      })),
      KeyedSubtree(key: const ValueKey('numerology'), child: _sectionPage(context, 'अंक ज्योतिष', 'मूलांक • भाग्यांक • नामांक • शुभ अंक', Icons.tag, () async {
        await _openRoute(const NumerologyScreen());
      })),
      KeyedSubtree(key: const ValueKey('muhurat'), child: _sectionPage(context, 'शुभ मुहूर्त', 'विवाह • गृहप्रवेश • कार्यारम्भ', Icons.access_time_filled, () async {
        final now = DateTime.now();
        final solar = SolarService.forDate(date: now, latitude: _lat, longitude: _lon);
        await _openRoute(MuhuratScreen(date: now, solar: SolarTimes(sunrise: solar.sunrise, sunset: solar.sunset, nextSunrise: solar.nextSunrise)));
      })),
      KeyedSubtree(key: const ValueKey('yatra'), child: _sectionPage(context, 'यात्रा', 'दिशाशूल • शुभ दिशा • यात्रा सलाह', Icons.alt_route, () async {
        await _openRoute(YatraScreen(date: DateTime.now(), fromLat: _lat, fromLon: _lon, fromName: _place));
      })),
      KeyedSubtree(key: const ValueKey('festivals'), child: _sectionPage(context, 'व्रत एवं त्योहार', 'एकादशी • पूर्णिमा • अमावस्या • पर्व', Icons.festival, () async {
        await _openRoute(FestivalsScreen(date: DateTime.now()));
      })),
      KeyedSubtree(key: const ValueKey('shubh'), child: _sectionPage(context, 'शुभ समय', 'चौघड़िया • राहुकाल • यमगण्ड • गुलिक', Icons.timer, () async {
        final now = DateTime.now();
        final solar = SolarService.forDate(date: now, latitude: _lat, longitude: _lon);
        await _openRoute(ChoghadiyaScreen(
          date: now,
          solar: SolarTimes(sunrise: solar.sunrise, sunset: solar.sunset, nextSunrise: solar.nextSunrise),
        ));
      })),
      KeyedSubtree(key: const ValueKey('reminder'), child: _sectionPage(context, 'रिमाइंडर', 'व्रत और शुभ समय के लिए सूचनाएँ', Icons.notifications_active, () async {
        await _openRoute(const ReminderScreen());
      })),
      KeyedSubtree(key: const ValueKey('saved_kundali'), child: _sectionPage(context, 'सेव की गई कुंडलियाँ', 'पुरानी जन्म-कुंडलियाँ देखें और फिर से खोलें', Icons.history_rounded, () async {
        await _openRoute(const SavedProfilesScreen());
      })),
      KeyedSubtree(key: const ValueKey('vratkatha'), child: _sectionPage(context, 'व्रत कथा व आरती', 'एकादशी, प्रदोष, सत्यनारायण कथा व आरती', Icons.menu_book_rounded, () async {
        await _openRoute(const VratKathaScreen());
      })),
      KeyedSubtree(key: const ValueKey('masik_panchang'), child: _sectionPage(context, 'सनातन मासिक पंचांग', 'मासिक पंचांग ग्रिड • व्रत बिल्ले • विक्रम संवत', Icons.grid_view_rounded, () async {
        await _openRoute(const SanatanMasikPanchangScreen());
      })),
      KeyedSubtree(key: const ValueKey('sadesati'), child: _sectionPage(context, 'साढ़े साती', 'शनि चरण • ढैया • गोचर • उपाय', Icons.nights_stay_rounded, () async {
        await _openRoute(const SadeSatiScreen());
      })),
      KeyedSubtree(key: const ValueKey('shloka'), child: _sectionPage(context, 'आज का श्लोक', 'गीता • नीति • स्तोत्र संग्रह', Icons.format_quote_rounded, () async {
        await _openRoute(const DailyShlokaScreen());
      })),
      KeyedSubtree(key: const ValueKey('hora'), child: _sectionPage(context, 'होरा चक्र', '24 होरा • ग्रह स्वामी • वर्तमान काल', Icons.watch_later_outlined, () async {
        await _openRoute(const HoraChakraScreen());
      })),
      KeyedSubtree(key: const ValueKey('gochar'), child: _sectionPage(context, 'दैनिक गोचर', 'ग्रह गोचर चंद्र भाव से फल', Icons.public, () async {
        await _openRoute(const GocharScreen());
      })),
      KeyedSubtree(key: const ValueKey('annual_muhurat'), child: _sectionPage(context, 'मुहूर्त सारणी', 'ब्रह्म • अभिजित • विजय • प्रदोष', Icons.table_chart_outlined, () async {
        await _openRoute(const AnnualMuhuratScreen());
      })),
      KeyedSubtree(key: const ValueKey('compass'), child: _sectionPage(context, 'वैदिक दिशा-सूचक', 'दिशाशूल • लक्ष्य दिशा • यात्रा कम्पास', Icons.explore_rounded, () async {
        await _openRoute(const DigitalCompassScreen());
      })),
      KeyedSubtree(key: const ValueKey('moon'), child: _sectionPage(context, 'चन्द्र कला', 'तिथि • पक्ष • प्रकाश प्रतिशत', Icons.nightlight_round, () async {
        await _openRoute(const MoonPhaseScreen());
      })),
      KeyedSubtree(key: const ValueKey('varga'), child: _sectionPage(context, 'वर्ग विश्लेषण', 'षोडश वर्ग • विवाह • करियर • धन', Icons.hub_outlined, () async {
        await _openRoute(const VargaAnalysisScreen());
      })),
      KeyedSubtree(key: const ValueKey('branding'), child: _sectionPage(context, 'ज्योतिषी ब्रांडिंग', 'PDF आवरण • नाम • संस्थान', Icons.badge_outlined, () async {
        await _openRoute(const AstrologerBrandingScreen());
      })),
    ];

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _brown,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: Text('शक्ति पंचांग • ${_place}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
        actions: [
          IconButton(tooltip: 'स्थान', icon: const Icon(Icons.place_outlined), onPressed: _pickLocation),
          IconButton(tooltip: 'सदस्यता', icon: const Icon(Icons.workspace_premium_outlined), onPressed: () => _openRoute(const PremiumScreen(), skipAd: true)),
          IconButton(tooltip: 'Settings', icon: const Icon(Icons.settings_outlined), onPressed: () => _openRoute(const AppSettingsScreen(), skipAd: true)),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
          Expanded(
            child: PageFlipWidget(
              key: _pageKey,
              backgroundColor: _bg,
              initialIndex: _bookStart,
              onPageFlipped: (i) {
                if (!mounted) return;
                setState(() => _page = i);
              },
              children: pages,
              lastPage: _backCover(context),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
            child: Column(
              children: [
                if (_page >= 1 && _page <= 21)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: FilledButton.icon(
                      onPressed: _openingPanchang ? null : _openCurrentChapter,
                      icon: const Icon(Icons.open_in_new),
                      label: const Text('यह अध्याय खोलें'),
                    ),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(onPressed: _page > 0 ? () => _go(_page - 1) : null, icon: const Icon(Icons.chevron_left)),
                    Text('पन्ना ${_page + 1} / ${pages.length}', style: const TextStyle(fontWeight: FontWeight.w800, color: _brown)),
                    IconButton(onPressed: _page < pages.length - 1 ? () => _go(_page + 1) : null, icon: const Icon(Icons.chevron_right)),
                  ],
                ),
              ],
            ),
          ),
          ],
        ),
      ),
    );
  }

  Widget _cover(BuildContext context) => _paperPage(
        Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Text('॥ श्री गणेशाय नमः ॥', style: TextStyle(color: _brown, fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 28),
          const Icon(Icons.menu_book_rounded, size: 88, color: _gold),
          const SizedBox(height: 18),
          const Text('शक्ति पंचांग', style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: _brown)),
          const SizedBox(height: 8),
          const Text('सम्पूर्ण वैदिक पंचांग एवं ज्योतिष ग्रंथ', textAlign: TextAlign.center, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          const SizedBox(height: 34),
          FilledButton.icon(onPressed: () => _go(1), icon: const Icon(Icons.menu_book), label: const Text('ग्रंथ खोलें')),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => _openUma('मुख्य ग्रंथ आवरण', 'पूरे SHAKTI PANCHANG के अध्यायों और UMA की सहायता के बारे में मार्गदर्शन।'),
            icon: const Icon(Icons.auto_awesome_rounded),
            label: const Text('उमा से मार्गदर्शन'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => _openRoute(const PremiumScreen(), skipAd: true),
            icon: const Icon(Icons.workspace_premium_rounded),
            label: const Text('Shakti Panchang Premium'),
          ),
          const SizedBox(height: 24),
          Text(AppConfig.poweredBy, style: const TextStyle(color: _brown, fontWeight: FontWeight.w800)),
        ]),
      );

  Widget _sectionPage(BuildContext context, String title, String subtitle, IconData icon, VoidCallback onOpen) => _paperPage(
        Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 72, color: _gold),
          const SizedBox(height: 20),
          Text(title, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: _brown)),
          const SizedBox(height: 10),
          Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, height: 1.5)),
          const SizedBox(height: 28),
          FilledButton.icon(onPressed: onOpen, icon: const Icon(Icons.open_in_new), label: const Text('यह अध्याय खोलें')),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => _openUma(title, subtitle),
            icon: const Icon(Icons.auto_awesome_rounded),
            label: const Text('उमा — इस पन्ने की जानकारी'),
          ),
          const SizedBox(height: 18),
          const Text('बाएँ/दाएँ स्वाइप करके पन्ना पलटें', style: TextStyle(color: Colors.black54, fontSize: 12)),
        ]),
      );

  Widget _backCover(BuildContext context) => _paperPage(
        Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.temple_hindu, size: 70, color: _gold),
          const SizedBox(height: 18),
          const Text('शक्ति पंचांग', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: _brown)),
          const SizedBox(height: 10),
          const Text('ज्ञान • समय • संस्कार', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 30),
          OutlinedButton.icon(
            onPressed: () => _openUma('पुस्तक का अंतिम पन्ना', 'शक्ति पंचांग के मुख्य उपयोग और अगले कदम।'),
            icon: const Icon(Icons.auto_awesome_rounded),
            label: const Text('उमा से पूछें'),
          ),
          const SizedBox(height: 18),
          Text(AppConfig.poweredBy, style: const TextStyle(color: _brown, fontWeight: FontWeight.w800)),
        ]),
      );

  String _panchangKey(DateTime date) =>
      '${date.year}-${date.month}-${date.day}|${_lat.toStringAsFixed(6)}|${_lon.toStringAsFixed(6)}';

  Future<AstronomicalPanchang> _calculatePanchangCached() {
    final now = DateTime.now();
    final key = _panchangKey(now);
    if (_panchangFuture != null && _panchangCacheKey == key) {
      return _panchangFuture!;
    }
    _panchangCacheKey = key;
    _panchangFuture = AstronomicalPanchangService().calculate(
      date: now,
      latitude: _lat,
      longitude: _lon,
    );
    return _panchangFuture!;
  }

  void _primePanchang() {
    _calculatePanchangCached().then<void>((_) {}, onError: (_, __) {
      _panchangFuture = null;
      _panchangCacheKey = null;
    });
  }

  Future<void> _openCurrentChapter() async {
    switch (_page) {
      case 1: await _openPanchang(); return;
      case 2: await _openRoute(const KundaliScreen()); return;
      case 3: await _openRoute(const DailyRashifalScreen()); return;
      case 4: await _openRoute(const NumerologyScreen()); return;
      case 5:
        final now = DateTime.now();
        final solar = SolarService.forDate(date: now, latitude: _lat, longitude: _lon);
        await _openRoute(MuhuratScreen(date: now, solar: SolarTimes(sunrise: solar.sunrise, sunset: solar.sunset, nextSunrise: solar.nextSunrise)));
        return;
      case 6: await _openRoute(YatraScreen(date: DateTime.now(), fromLat: _lat, fromLon: _lon, fromName: _place)); return;
      case 7: await _openRoute(FestivalsScreen(date: DateTime.now())); return;
      case 8:
        final now = DateTime.now();
        final solar = SolarService.forDate(date: now, latitude: _lat, longitude: _lon);
        await _openRoute(ChoghadiyaScreen(date: now, solar: SolarTimes(sunrise: solar.sunrise, sunset: solar.sunset, nextSunrise: solar.nextSunrise)));
        return;
      case 9: await _openRoute(const ReminderScreen()); return;
      case 10: await _openRoute(const SavedProfilesScreen()); return;
      case 11: await _openRoute(const VratKathaScreen()); return;
      case 12: await _openRoute(const SanatanMasikPanchangScreen()); return;
      case 13: await _openRoute(const SadeSatiScreen()); return;
      case 14: await _openRoute(const DailyShlokaScreen()); return;
      case 15: await _openRoute(const HoraChakraScreen()); return;
      case 16: await _openRoute(const GocharScreen()); return;
      case 17: await _openRoute(const AnnualMuhuratScreen()); return;
      case 18: await _openRoute(const DigitalCompassScreen()); return;
      case 19: await _openRoute(const MoonPhaseScreen()); return;
      case 20: await _openRoute(const VargaAnalysisScreen()); return;
      case 21: await _openRoute(const AstrologerBrandingScreen()); return;
    }
  }

  Future<void> _openPanchang() async {
    if (!mounted || _openingPanchang) return;
    setState(() => _openingPanchang = true);
    try {
      final now = DateTime.now();
      final data = await _calculatePanchangCached();
      if (!mounted) return;
      await _openRoute(PanchangDetailScreen(date: now, data: data, lat: _lat, lon: _lon, place: _place));
    } catch (e) {
      if (!mounted) return;
      _panchangFuture = null;
      _panchangCacheKey = null;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('पंचांग खोलने में समस्या: $e')));
    } finally {
      if (!mounted) return;
      setState(() => _openingPanchang = false);
    }
  }

  Future<void> _openRoute(Widget page, {bool skipAd = false}) async {
    if (!skipAd) {
      final ok = await AdGate.beforeOpen(context);
      if (!mounted || !ok) return;
    }
    final returnPage = _page;
    await Navigator.push<void>(context, MaterialPageRoute(builder: (_) => page));
    if (!mounted) return;
    setState(() {
      _page = returnPage;
      _bookStart = returnPage;
      _pageKey = GlobalKey<PageFlipWidgetState>();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final state = _pageKey.currentState;
      if (state != null && returnPage > 0) state.goToPage(returnPage);
    });
  }

  Future<void> _pickLocation() async {
    final result = await Navigator.push<dynamic>(context, MaterialPageRoute(builder: (_) => const LocationSearchScreen()));
    if (result is! Map || !mounted) return;
    final loc = SavedLocation(
      name: '${result['name'] ?? 'स्थान'}',
      latitude: (result['lat'] as num?)?.toDouble() ?? _lat,
      longitude: (result['lng'] as num?)?.toDouble() ?? _lon,
    );
    await LocationStore().save(loc);
    await LocationStore().setSelected(loc);
    if (!mounted) return;
    setState(() {
      _location = loc;
      _panchangFuture = null;
      _panchangCacheKey = null;
    });
    _primePanchang();
  }

  Future<void> _openUma(String title, String description) async {
    await _openRoute(UmaScreen(date: DateTime.now(), pageContext: title, pageDescription: description));
  }

  Widget _paperPage(Widget child) => Container(
        margin: const EdgeInsets.all(14),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: _paper,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _brown.withValues(alpha: .35)),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
        ),
        child: child,
      );
}
