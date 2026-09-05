import '../models/panchang_boundaries.dart';
import 'boundary_solver.dart';
import 'xalen_service.dart';

class PanchangBoundaryService {
  final AstronomyEngineService engine;
  const PanchangBoundaryService(this.engine);

  Future<DailyPanchangBoundaries> calculate(DateTime localDate) async {
    final base = DateTime(localDate.year, localDate.month, localDate.day);
    final probe = base.add(const Duration(hours: 12));
    final x = engine.calculate(probe);
    final tithiPhase = _norm(x.moonSiderealDeg - x.sunSiderealDeg);
    final nakPhase = _norm(x.moonSiderealDeg);
    final yogaPhase = _norm(x.moonSiderealDeg + x.sunSiderealDeg);
    final tithiIndex = (tithiPhase / 12).floor();
    final nakIndex = (nakPhase / (360 / 27)).floor();
    final yogaIndex = (yogaPhase / (360 / 27)).floor();
    final karanaIndex = (tithiPhase / 6).floor();

    Future<double> phase(DateTime t, int kind) async {
      final r = engine.calculate(t);
      return switch (kind) {
        0 => _norm(r.moonSiderealDeg - r.sunSiderealDeg),
        1 => _norm(r.moonSiderealDeg),
        _ => _norm(r.moonSiderealDeg + r.sunSiderealDeg),
      };
    }
    final dayEnd = base.add(const Duration(days: 1));
    final tithiStart = await _find(base, probe, phase, tithiIndex * 12, 0);
    final tithiEnd = await _find(probe, dayEnd, phase, (tithiIndex + 1) * 12, 0);
    final nakStart = await _find(base, probe, phase, nakIndex * (360 / 27), 1);
    final nakEnd = await _find(probe, dayEnd, phase, (nakIndex + 1) * (360 / 27), 1);
    final yogaStart = await _find(base, probe, phase, yogaIndex * (360 / 27), 2);
    final yogaEnd = await _find(probe, dayEnd, phase, (yogaIndex + 1) * (360 / 27), 2);
    final karanaStart = await _find(base, probe, phase, karanaIndex * 6, 0);

    return DailyPanchangBoundaries(
      tithi: PanchangBoundary(type: PanchangBoundaryType.tithi,
        currentName: _tithiName(tithiIndex), nextName: _tithiName((tithiIndex + 1) % 30),
        start: tithiStart, end: tithiEnd,
        progress: ((tithiPhase % 12) / 12).clamp(0.0, 1.0)),
      nakshatra: PanchangBoundary(type: PanchangBoundaryType.nakshatra,
        currentName: _nakshatraName(nakIndex), nextName: _nakshatraName((nakIndex + 1) % 27),
        start: nakStart, end: nakEnd,
        progress: ((nakPhase % (360 / 27)) / (360 / 27)).clamp(0.0, 1.0)),
      yoga: PanchangBoundary(type: PanchangBoundaryType.yoga,
        currentName: _yogaName(yogaIndex), nextName: _yogaName((yogaIndex + 1) % 27),
        start: yogaStart, end: yogaEnd,
        progress: ((yogaPhase % (360 / 27)) / (360 / 27)).clamp(0.0, 1.0)),
      karana: PanchangBoundary(type: PanchangBoundaryType.karana,
        currentName: _karanaName(karanaIndex), nextName: _karanaName((karanaIndex + 1) % 60),
        start: karanaStart, end: karanaStart.add(const Duration(hours: 6)),
        progress: ((tithiPhase % 6) / 6).clamp(0.0, 1.0)),
    );
  }

  Future<DateTime> _find(DateTime left, DateTime right,
      Future<double> Function(DateTime, int) phase, double target, int kind) =>
      BoundarySolver.findCrossingAsync(left: left, right: right, target: target,
        phase: (t) => phase(t, kind));

  double _norm(double x) => ((x % 360) + 360) % 360;
  String _tithiName(int i) => const ['शुक्ल प्रतिपदा','शुक्ल द्वितीया','शुक्ल तृतीया','शुक्ल चतुर्थी','शुक्ल पंचमी','शुक्ल षष्ठी','शुक्ल सप्तमी','शुक्ल अष्टमी','शुक्ल नवमी','शुक्ल दशमी','शुक्ल एकादशी','शुक्ल द्वादशी','शुक्ल त्रयोदशी','शुक्ल चतुर्दशी','पूर्णिमा','कृष्ण प्रतिपदा','कृष्ण द्वितीया','कृष्ण तृतीया','कृष्ण चतुर्थी','कृष्ण पंचमी','कृष्ण षष्ठी','कृष्ण सप्तमी','कृष्ण अष्टमी','कृष्ण नवमी','कृष्ण दशमी','कृष्ण एकादशी','कृष्ण द्वादशी','कृष्ण त्रयोदशी','कृष्ण चतुर्दशी','अमावस्या'][i % 30];
  String _nakshatraName(int i) => const ['अश्विनी','भरणी','कृत्तिका','रोहिणी','मृगशीर्ष','आर्द्रा','पुनर्वसु','पुष्य','आश्लेषा','मघा','पूर्वा फाल्गुनी','उत्तरा फाल्गुनी','हस्त','चित्रा','स्वाती','विशाखा','अनुराधा','ज्येष्ठा','मूल','पूर्वाषाढ़ा','उत्तराषाढ़ा','श्रवण','धनिष्ठा','शतभिषा','पूर्वाभाद्रपद','उत्तराभाद्रपद','रेवती'][i % 27];
  String _yogaName(int i) => const ['विष्कम्भ','प्रीति','आयुष्मान','सौभाग्य','शोभन','अतिगण्ड','सुकर्मा','धृति','शूल','गण्ड','वृद्धि','ध्रुव','व्याघात','हर्षण','वज्र','सिद्धि','व्यतीपात','वरीयान','परिघ','शिव','सिद्ध','साध्य','शुभ','शुक्ल','ब्रह्म','इन्द्र','वैधृति'][i % 27];
  String _karanaName(int i) {
    const moving = ['बव','बालव','कौलव','तैतिल','गर','वणिज','विष्टि'];
    if (i == 0) return 'किंस्तुघ्न';
    if (i >= 57) return const ['शकुनि','चतुष्पद','नाग'][i - 57];
    return moving[(i - 1) % 7];
  }
}
