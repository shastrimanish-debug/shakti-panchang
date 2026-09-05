import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 

const Color _bhojBg = Color(0xFFF4E8D1);
const Color _bhojCard = Color(0xFFFAF2E4);
const Color _bhojBrown = Color(0xFF5C3A21);
const Color _bhojBorder = Color(0xFF8C6239);

class DashaScreen extends StatelessWidget {
  final dynamic data; 

  const DashaScreen({super.key, required this.data});

  static const _order = ['केतु', 'शुक्र', 'सूर्य', 'चंद्र', 'मंगल', 'राहु', 'गुरु', 'शनि', 'बुध'];
  static const _years = {'केतु': 7.0, 'शुक्र': 20.0, 'सूर्य': 6.0, 'चंद्र': 10.0, 'मंगल': 7.0, 'राहु': 18.0, 'गुरु': 16.0, 'शनि': 19.0, 'बुध': 17.0};

  Map<String, String>? _currentDepths(dynamic source) {
    try {
      final now = DateTime.now();
      final antars = List.from(source.antarPeriods as Iterable);
      final praty = List.from(source.pratyantarPeriods as Iterable);
      dynamic activeAntar = antars.cast<dynamic>().firstWhere((x) => !now.isBefore(x.startDate) && now.isBefore(x.endDate), orElse: () => null);
      dynamic activePraty = praty.cast<dynamic>().firstWhere((x) => !now.isBefore(x.startDate) && now.isBefore(x.endDate), orElse: () => null);
      if (activeAntar == null || activePraty == null) return null;

      Map<String, DateTime> split(DateTime start, DateTime end, String lord) {
        final result = <String, DateTime>{};
        final total = end.difference(start).inMilliseconds;
        var cursor = start;
        final idx = _order.indexOf(lord);
        if (idx < 0 || total <= 0) return result;
        for (var i = 0; i < 9; i++) {
          final subLord = _order[(idx + i) % 9];
          final weight = _years[subLord]!;
          final duration = (total * weight / 120.0).round();
          cursor = i == 8 ? end : cursor.add(Duration(milliseconds: duration));
          result[subLord] = cursor;
        }
        return result;
      }

      final sk = split(activePraty.startDate, activePraty.endDate, activePraty.pratyantar);
      final activeSukshma = sk.entries.where((e) => now.isBefore(e.value)).map((e) => e.key).isEmpty ? null : sk.entries.where((e) => now.isBefore(e.value)).map((e) => e.key).first;
      if (activeSukshma == null) return {'pratyantar': activePraty.pratyantar};
      final skStart = sk.entries.firstWhere((e) => e.key == activeSukshma).value.subtract(Duration(milliseconds: ((activePraty.endDate.difference(activePraty.startDate).inMilliseconds * _years[activeSukshma]! / 120.0).round())));
      final skEnd = sk[activeSukshma]!;
      final pr = split(skStart, skEnd, activeSukshma);
      final activePrana = pr.entries.where((e) => now.isBefore(e.value)).map((e) => e.key).isEmpty ? null : pr.entries.where((e) => now.isBefore(e.value)).map((e) => e.key).first;
      return {'pratyantar': activePraty.pratyantar, 'sukshma': activeSukshma, if (activePrana != null) 'prana': activePrana};
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> actualDashaList = [];
    
    try {
      if (data != null && data.dashaPeriods != null) {
        actualDashaList = List.from(data.dashaPeriods);
      }
    } catch (e) {
      debugPrint('Dasha Load Error: $e');
    }

    return Scaffold(
      backgroundColor: _bhojBg,
      appBar: AppBar(
        backgroundColor: _bhojBrown,
        foregroundColor: _bhojBg,
        title: const Text(
          'विंशोत्तरी महादशा',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22, letterSpacing: 0.5),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            color: _bhojBrown.withValues(alpha: 0.1),
            child: const Text(
              'महादशा ➔ अंतरदशा ➔ प्रत्यंतर दशा',
              style: TextStyle(fontWeight: FontWeight.bold, color: _bhojBrown, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),
          if (data != null) Builder(builder: (context) {
            final depth = _currentDepths(data);
            if (depth == null) return const SizedBox.shrink();
            return Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: _bhojCard, border: Border.all(color: _bhojBorder), borderRadius: BorderRadius.circular(10)),
              child: Text('अभी: ${depth['pratyantar'] ?? '—'}${depth['sukshma'] != null ? ' / ${depth['sukshma']}' : ''}${depth['prana'] != null ? ' / ${depth['prana']}' : ''}', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w900, color: _bhojBrown)),
            );
          }),
          Expanded(
            child: actualDashaList.isEmpty
                ? const Center(
                    child: Text(
                      'महादशा का असली डेटा उपलब्ध नहीं है।\nकृपया पहले कुंडली की सटीक गणना करें।',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: _bhojBrown, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: actualDashaList.length,
                    itemBuilder: (context, index) {
                      return _BuildSafeMahadashaTile(mahadasha: actualDashaList[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _BuildSafeMahadashaTile extends StatelessWidget {
  final dynamic mahadasha;

  const _BuildSafeMahadashaTile({required this.mahadasha});

  String _formatDate(String rawDate) {
    if (rawDate.isEmpty) return '';
    try {
      DateTime dt = DateTime.parse(rawDate);
      return DateFormat('dd/MM/yyyy').format(dt); 
    } catch (e) {
      return rawDate.split(' ').first;
    }
  }

  @override
  Widget build(BuildContext context) {
    String planetName = 'अज्ञात';
    String start = '';
    String end = '';
    List<dynamic> antardashaList = [];

    final vYears = {'सूर्य': 6, 'Sun': 6, 'चंद्र': 10, 'Moon': 10, 'मंगल': 7, 'Mars': 7, 'राहु': 18, 'Rahu': 18, 'गुरु': 16, 'Jupiter': 16, 'शनि': 19, 'Saturn': 19, 'बुध': 17, 'Mercury': 17, 'केतु': 7, 'Ketu': 7, 'शुक्र': 20, 'Venus': 20};
    final pOrder = ['केतु', 'शुक्र', 'सूर्य', 'चंद्र', 'मंगल', 'राहु', 'गुरु', 'शनि', 'बुध'];

    try { planetName = mahadasha.planet?.toString() ?? 'अज्ञात'; } catch (_) {}
    try { start = _formatDate(mahadasha.startDate?.toString() ?? ''); } catch (_) {}
    try { end = _formatDate(mahadasha.endDate?.toString() ?? ''); } catch (_) {}
    
    var rawList;
    try { rawList = rawList ?? mahadasha.antarPeriods; } catch (_) {}
    try { rawList = rawList ?? mahadasha.subPeriods; } catch (_) {}
    try { rawList = rawList ?? mahadasha.antardashas; } catch (_) {}
    
    if (rawList != null) {
      try { antardashaList = List.from(rawList); } catch (_) {}
    }

    // 🌟 1. स्मार्ट अंतरदशा जनरेटर (अगर डेटा ना हो)
    if (antardashaList.isEmpty && start.isNotEmpty && planetName != 'अज्ञात') {
      try {
        String bPlanet = pOrder.firstWhere((p) => planetName.contains(p), orElse: () => '');
        if (bPlanet.isNotEmpty) {
          int totalYears = vYears[bPlanet]!;
          int startIndex = pOrder.indexOf(bPlanet);
          DateTime currentStart = DateFormat('dd/MM/yyyy').parse(start);

          for (int i = 0; i < 9; i++) {
            int pIndex = (startIndex + i) % 9;
            String adPlanet = pOrder[pIndex];
            int adYears = vYears[adPlanet]!;
            
            int days = ((totalYears * adYears * 365.2425) / 120).round();
            DateTime adEnd = currentStart.add(Duration(days: days));
            
            antardashaList.add({
              'planet': adPlanet,
              'startDate': DateFormat('dd/MM/yyyy').format(currentStart),
              'endDate': DateFormat('dd/MM/yyyy').format(adEnd),
            });
            currentStart = adEnd;
          }
        }
      } catch (e) {
         // Fallback
      }
    }

    return Card(
      color: _bhojCard,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: _bhojBorder, width: 1.2),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            'महादशा: $planetName',
            style: const TextStyle(fontWeight: FontWeight.w900, color: _bhojBrown, fontSize: 16),
          ),
          subtitle: Text(
            '$start  से  $end',
            style: const TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.w600),
          ),
          iconColor: _bhojBrown,
          collapsedIconColor: _bhojBrown,
          children: antardashaList.isEmpty
              ? [
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('अंतरदशा उपलब्ध नहीं है।', style: TextStyle(color: Colors.grey)),
                  )
                ]
              : antardashaList.map((ad) {
                  
                  String subPlanet = 'अज्ञात';
                  String subStart = '';
                  String subEnd = '';
                  List<dynamic> pratyantarList = [];

                  if (ad is Map) {
                     subPlanet = ad['planet']?.toString() ?? '';
                     subStart = ad['startDate']?.toString() ?? '';
                     subEnd = ad['endDate']?.toString() ?? '';
                     try { pratyantarList = List.from(ad['pratyantarPeriods'] ?? ad['subSubPeriods'] ?? []); } catch (_) {}
                  } else {
                     try { subPlanet = ad.planet?.toString() ?? 'अज्ञात'; } catch (_) {}
                     try { subStart = _formatDate(ad.startDate?.toString() ?? ''); } catch (_) {}
                     try { subEnd = _formatDate(ad.endDate?.toString() ?? ''); } catch (_) {}
                     try { pratyantarList = List.from(ad.pratyantarPeriods ?? ad.subSubPeriods ?? []); } catch (_) {}
                  }

                  // 🌟 2. स्मार्ट प्रत्यंतर दशा (3rd Level) जनरेटर 
                  if (pratyantarList.isEmpty && subStart.isNotEmpty && subPlanet != 'अज्ञात') {
                    try {
                      String bPlanet = pOrder.firstWhere((p) => planetName.contains(p), orElse: () => '');
                      String adBPlanet = pOrder.firstWhere((p) => subPlanet.contains(p), orElse: () => '');
                      
                      if (bPlanet.isNotEmpty && adBPlanet.isNotEmpty) {
                        int mdYears = vYears[bPlanet]!;
                        int adYears = vYears[adBPlanet]!;
                        int pdStartIndex = pOrder.indexOf(adBPlanet);
                        DateTime currentPdStart = DateFormat('dd/MM/yyyy').parse(subStart);

                        for (int j = 0; j < 9; j++) {
                          int pdIndex = (pdStartIndex + j) % 9;
                          String pdPlanet = pOrder[pdIndex];
                          int pdYears = vYears[pdPlanet]!;
                          
                          // प्रत्यंतर का सटीक गणित: (MD * AD * PD * 365.2425) / (120 * 120)
                          int pdDays = ((mdYears * adYears * pdYears * 365.2425) / 14400).round();
                          DateTime pdEnd = currentPdStart.add(Duration(days: pdDays));
                          
                          pratyantarList.add({
                            'planet': pdPlanet,
                            'startDate': DateFormat('dd/MM/yyyy').format(currentPdStart),
                            'endDate': DateFormat('dd/MM/yyyy').format(pdEnd),
                          });
                          currentPdStart = pdEnd;
                        }
                      }
                    } catch (e) {
                       // Fallback
                    }
                  }

                  // 🌟 3. अंतरदशा का नया UI (जिसके अंदर प्रत्यंतर दशा है)
                  return Container(
                    decoration: BoxDecoration(
                      color: _bhojBg.withValues(alpha: 0.5),
                      border: const Border(top: BorderSide(color: _bhojBorder, width: 0.5)),
                    ),
                    child: Theme(
                      data: ThemeData().copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        tilePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
                        leading: const Icon(Icons.subdirectory_arrow_right_rounded, color: _bhojBrown, size: 20),
                        title: Text(
                          'अंतरदशा: $subPlanet',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: _bhojBrown, fontSize: 14),
                        ),
                        subtitle: Text(
                          '$subStart  से  $subEnd',
                          style: const TextStyle(fontSize: 12, color: Colors.black87),
                        ),
                        iconColor: _bhojBrown,
                        collapsedIconColor: _bhojBrown,
                        children: pratyantarList.map((pd) {
                          
                          String pdPlanet = 'अज्ञात';
                          String pdStart = '';
                          String pdEnd = '';

                          if (pd is Map) {
                            pdPlanet = pd['planet']?.toString() ?? '';
                            pdStart = pd['startDate']?.toString() ?? '';
                            pdEnd = pd['endDate']?.toString() ?? '';
                          } else {
                            try { pdPlanet = pd.planet?.toString() ?? ''; } catch (_) {}
                            try { pdStart = _formatDate(pd.startDate?.toString() ?? ''); } catch (_) {}
                            try { pdEnd = _formatDate(pd.endDate?.toString() ?? ''); } catch (_) {}
                          }

                          return Container(
                            padding: const EdgeInsets.only(left: 64, right: 24, top: 6, bottom: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.4),
                              border: Border(top: BorderSide(color: _bhojBorder.withValues(alpha: 0.2), width: 0.5)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('• प्रत्यंतर: $pdPlanet', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _bhojBrown)),
                                Text('$pdStart - $pdEnd', style: const TextStyle(fontSize: 11, color: Colors.black87, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  );
                }).toList(),
        ),
      ),
    );
  }
}
