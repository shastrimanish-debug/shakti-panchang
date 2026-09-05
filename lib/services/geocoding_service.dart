import 'dart:convert';
import 'dart:io';

class PlaceResult {
  final String displayName;
  final double latitude;
  final double longitude;
  const PlaceResult({required this.displayName, required this.latitude, required this.longitude});
}

class GeocodingService {
  static const Map<String, List<double>> _india = {
    'vadodara':[22.3072,73.1812], 'baroda':[22.3072,73.1812],
    'ahmedabad':[23.0225,72.5714], 'mumbai':[19.0760,72.8777],
    'surat':[21.1702,72.8311], 'rajkot':[22.3039,70.8022],
    'bharuch':[21.7051,72.9959], 'anand':[22.5645,72.9289],
    'burhanpur':[21.3000,76.2300], 'ujjain':[23.1765,75.7885],
    'indore':[22.7196,75.8577], 'bhopal':[23.2599,77.4126],
    'delhi':[28.6139,77.2090], 'jaipur':[26.9124,75.7873],
    'pune':[18.5204,73.8567], 'nashik':[19.9975,73.7898],
    'nagpur':[21.1458,79.0882], 'hyderabad':[17.3850,78.4867],
    'bengaluru':[12.9716,77.5946], 'chennai':[13.0827,80.2707],
    'kolkata':[22.5726,88.3639], 'lucknow':[26.8467,80.9462],
    'varanasi':[25.3176,82.9739], 'ayodhya':[26.7986,82.1998],
    'agra':[27.1767,78.0081], 'jabalpur':[23.1815,79.9864],
    'khandwa':[21.8247,76.3509], 'narmadapuram':[22.7441,77.7360],
    'seoni':[22.0869,79.5435], 'chhindwara':[22.0574,78.9382],
    'bhilai':[21.1938,81.3509], 'raipur':[21.2514,81.6296],
    'amritsar':[31.6340,74.8723], 'chandigarh':[30.7333,76.7794],
    'patna':[25.5941,85.1376], 'ranchi':[23.3441,85.3096],
    'goa':[15.4909,73.8278], 'nepanagar':[21.4537,76.3930],
    'shahpur':[21.2376,76.2241], 'khaknar':[21.4917,76.4115],
  };

  List<PlaceResult> get commonPlaces => _india.entries.map((e) => PlaceResult(displayName: _pretty(e.key), latitude: e.value[0], longitude: e.value[1])).toList(growable: false);

  final Map<String,List<PlaceResult>> _cache = {};
  DateTime _lastRemoteRequest = DateTime.fromMillisecondsSinceEpoch(0);

  Future<List<PlaceResult>> search(String query) async {
    final q=query.trim();
    if(q.length<2) return const [];
    final key=q.toLowerCase();
    if(_cache.containsKey(key)) return _cache[key]!;

    final local=<PlaceResult>[];
    for(final e in _india.entries) {
      if(e.key.contains(key) || key.contains(e.key)) {
        local.add(PlaceResult(displayName:_pretty(e.key),latitude:e.value[0],longitude:e.value[1]));
      }
    }
    if(local.isNotEmpty) { _cache[key]=local; return local; }

    // Online fallback allows village/hamlet names that are not in the small
    // offline list. It is throttled to one request per second per app instance.
    final elapsed=DateTime.now().difference(_lastRemoteRequest);
    if(elapsed<const Duration(seconds:1)) {
      await Future<void>.delayed(const Duration(seconds:1)-elapsed);
    }
    _lastRemoteRequest=DateTime.now();
    try {
      final uri=Uri.https('nominatim.openstreetmap.org','/search',{
        'q':q,'format':'jsonv2','limit':'8','countrycodes':'in',
        'addressdetails':'1','accept-language':'en,hi',
      });
      final client=HttpClient()..userAgent='ShaktiPanchang/1.0 (location search)';
      try {
        final request=await client.getUrl(uri).timeout(const Duration(seconds:6));
        request.headers.set(HttpHeaders.acceptHeader,'application/json');
        final response=await request.close().timeout(const Duration(seconds:6));
        if(response.statusCode!=HttpStatus.ok) return const [];
        final decoded=jsonDecode(await response.transform(utf8.decoder).join());
        if(decoded is! List) return const [];
        final remote=<PlaceResult>[];
        for(final item in decoded) {
          if(item is! Map) continue;
          final lat=double.tryParse('${item['lat']??''}');
          final lon=double.tryParse('${item['lon']??''}');
          final display='${item['display_name']??''}'.trim();
          if(lat!=null && lon!=null && display.isNotEmpty) {
            remote.add(PlaceResult(displayName:display,latitude:lat,longitude:lon));
          }
        }
        _cache[key]=remote;
        return remote;
      } finally { client.close(force:true); }
    } catch (_) { return const []; }
  }

  String _pretty(String v)=>v.split(' ').map((x)=>x.isEmpty?x:'${x[0].toUpperCase()}${x.substring(1)}').join(' ');
}
