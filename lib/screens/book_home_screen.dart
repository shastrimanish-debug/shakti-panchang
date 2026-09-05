import 'package:flutter/material.dart';
import 'package:page_flip/page_flip.dart';

import '../config/app_config.dart';
import 'festivals_screen.dart';
import 'kundali_screen.dart';
import 'muhurat_screen.dart';
import 'reminder_screen.dart';
import 'shubh_samay_screen.dart';
import 'yatra_screen.dart';
import 'panchang_detail_screen.dart';
import '../services/vedic_panchang_service.dart';
import '../services/solar_service.dart';
import '../services/panchang_boundary_service.dart';
import '../services/xalen_service.dart';
import '../services/disha_service.dart';
import '../services/location_store.dart';
import '../models/panchang_models.dart';
import 'uma_screen.dart';

const _bg = Color(0xFFF4E8D1);
const _paper = Color(0xFFFFF9EE);
const _brown = Color(0xFF5C3A21);
const _gold = Color(0xFFB56A00);

/// Book-style launcher. The individual modules remain normal screens so
/// existing navigation/state is preserved; only the top-level index uses a
/// real page-turn interaction.
class BookHomeScreen extends StatefulWidget {
  const BookHomeScreen({super.key});

  @override
  State<BookHomeScreen> createState() => _BookHomeScreenState();
}

class _BookHomeScreenState extends State<BookHomeScreen> {
  GlobalKey<PageFlipWidgetState> _pageKey = GlobalKey<PageFlipWidgetState>();
  int _page = 0;
  SavedLocation? _location;
  Future<dynamic>? _panchangFuture;
  String? _panchangCacheKey;
  bool _openingPanchang = false;

  @override
  void initState() {
    super.initState();
    _primePanchang();
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
      _cover(context),
      _sectionPage(context, 'पंचांग', 'तिथि • नक्षत्र • योग • करण • सूर्य समय', Icons.calendar_month, () => _openPanchang()),
      _sectionPage(context, 'कुंडली', 'जन्म कुंडली • वर्ग • दशा • फलित', Icons.auto_awesome, () async {
        await _openRoute(const KundaliScreen());
      }),
      _sectionPage(context, 'शुभ मुहूर्त', 'विवाह • गृहप्रवेश • कार्यारम्भ', Icons.access_time_filled, () async {
        final now = DateTime.now();
        final solar = SolarService.forDate(date: now, latitude: _lat, longitude: _lon);
        await _openRoute(MuhuratScreen(date: now, solar: SolarTimes(sunrise: solar.sunrise, sunset: solar.sunset, nextSunrise: solar.nextSunrise)));
      }),
      _sectionPage(context, 'यात्रा', 'दिशाशूल • शुभ दिशा • यात्रा सलाह', Icons.alt_route, () async {
        await _openRoute(YatraScreen(date: DateTime.now(), fromLat: _lat, fromLon: _lon, fromName: _place));
      }),
      _sectionPage(context, 'व्रत एवं त्योहार', 'एकादशी • पूर्णिमा • अमावस्या • पर्व', Icons.festival, () async {
        await _openRoute(FestivalsScreen(date: DateTime.now()));
      }),
      _sectionPage(context, 'शुभ समय', 'चौघड़िया • राहुकाल • यमगण्ड • गुलिक', Icons.timer, () async {
        final now = DateTime.now();
        final p = await PanchangBoundaryService(AstronomyEngineService()).calculate(now);
        if (!context.mounted) return;
        await _openRoute(ShubhSamayScreen(date: now, panchang: p, dishaShool: DishaService.avoided(now)));
      }),
      _sectionPage(context, 'रिमाइंडर', 'व्रत और शुभ समय के लिए सूचनाएँ', Icons.notifications_active, () async {
        await _openRoute(const ReminderScreen());
      }),
    ];

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _brown,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text('शक्ति पंचांग • वैदिक ग्रंथ', style: TextStyle(fontWeight: FontWeight.w900)),
      ),
      body: Column(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    PageFlipWidget(
                      key: _pageKey,
                      backgroundColor: _bg,
                      children: pages,
                      lastPage: _backCover(context),
                    ),
                    if (_page == 1) ...[
                      Positioned(
                        top: constraints.maxHeight * 0.52,
                        left: constraints.maxWidth * 0.10,
                        right: constraints.maxWidth * 0.10,
                        height: 90,
                        child: Opacity(
                          opacity: 0.01,
                          child: Material(
                            color: Colors.transparent,
                            child: FilledButton.icon(
                              onPressed: _openingPanchang ? null : _openPanchang,
                              icon: const Icon(Icons.open_in_new),
                              label: const Text('यह अध्याय खोलें'),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: constraints.maxHeight * 0.64,
                        left: constraints.maxWidth * 0.10,
                        right: constraints.maxWidth * 0.10,
                        height: 90,
                        child: Opacity(
                          opacity: 0.01,
                          child: Material(
                            color: Colors.transparent,
                            child: OutlinedButton.icon(
                              onPressed: () => _openUma(
                                'पंचांग',
                                'तिथि • नक्षत्र • योग • करण • सूर्य समय',
                              ),
                              icon: const Icon(Icons.auto_awesome_rounded),
                              label: const Text('उमा — इस पन्ने की जानकारी'),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(onPressed: _page > 0 ? () => _go(_page - 1) : null, icon: const Icon(Icons.chevron_left)),
                Text('पन्ना ${_page + 1} / ${pages.length}', style: const TextStyle(fontWeight: FontWeight.w800, color: _brown)),
                IconButton(onPressed: _page < pages.length - 1 ? () => _go(_page + 1) : null, icon: const Icon(Icons.chevron_right)),
              ],
            ),
          ),
        ],
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

  Future<dynamic> _calculatePanchangCached() {
    final now = DateTime.now();
    final key = _panchangKey(now);
    if (_panchangFuture != null && _panchangCacheKey == key) {
      return _panchangFuture!;
    }
    _panchangCacheKey = key;
    _panchangFuture = VedicPanchangService().calculate(
      date: now,
      latitude: _lat,
      longitude: _lon,
    );
    return _panchangFuture!;
  }

  void _primePanchang() {
    // Warm only an in-memory Future. Nothing is written to disk, so there is
    // no stale persistent cache, while opening Panchang becomes immediate
    // after the astronomical calculation has completed once.
    _calculatePanchangCached().then<void>((_) {}, onError: (_, __) {
      // A failed warm-up is harmless; the next tap retries with a fresh Future.
      _panchangFuture = null;
      _panchangCacheKey = null;
    });
  }

  Future<void> _openPanchang() async {
    if (!mounted || _openingPanchang) return;
    setState(() => _openingPanchang = true);

    try {
      final now = DateTime.now();
      final data = await _calculatePanchangCached();
      if (!mounted) return;

      await Navigator.of(context).push<void>(
        MaterialPageRoute(
          builder: (_) => PanchangDetailScreen(date: now, data: data),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      _panchangFuture = null;
      _panchangCacheKey = null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('पंचांग खोलने में समस्या: $e')),
      );
    } finally {
      if (!mounted) return;
      setState(() => _openingPanchang = false);
    }
  }

  Future<void> _openRoute(Widget page) async {
    // PageFlipWidget keeps an internal animation/snapshot state. Rebuilding the
    // book with the same GlobalKey after a child route returns can leave that
    // snapshot intercepting taps. Recreate the widget after every child route
    // and restore the page the user was reading.
    final returnPage = _page;
    await Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
    if (!mounted) return;

    setState(() {
      _pageKey = GlobalKey<PageFlipWidgetState>();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final state = _pageKey.currentState;
      if (state != null && returnPage > 0) {
        state.goToPage(returnPage);
      }
    });
  }

  Future<void> _openUma(String title, String description) async {
    await _openRoute(
      UmaScreen(
        date: DateTime.now(),
        pageContext: title,
        pageDescription: description,
      ),
    );
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
