class DishaService {
  static const Map<int, String> shool = {
    DateTime.sunday: 'पश्चिम',
    DateTime.monday: 'पूर्व',
    DateTime.tuesday: 'उत्तर',
    DateTime.wednesday: 'उत्तर',
    DateTime.thursday: 'दक्षिण',
    DateTime.friday: 'पश्चिम',
    DateTime.saturday: 'पूर्व',
  };

  static const directions = ['उत्तर', 'उत्तर-पूर्व', 'पूर्व', 'दक्षिण-पूर्व',
    'दक्षिण', 'दक्षिण-पश्चिम', 'पश्चिम', 'उत्तर-पश्चिम'];

  static String avoided(DateTime date) => shool[date.weekday]!;

  static String advice(String direction, DateTime date) {
    final bad = avoided(date);
    if (direction == bad) {
      return 'वर्जित दिशा — आज इस दिशा में यात्रा शुरू करने से बचें।';
    }
    return 'दिशाशूल के अनुसार यह दिशा आज वर्जित नहीं है।';
  }
}


String directionForBearingV9(double bearing) {
  final b = (bearing % 360 + 360) % 360;
  if (b < 22.5 || b >= 337.5) return 'उत्तर';
  if (b < 67.5) return 'उत्तर-पूर्व';
  if (b < 112.5) return 'पूर्व';
  if (b < 157.5) return 'दक्षिण-पूर्व';
  if (b < 202.5) return 'दक्षिण';
  if (b < 247.5) return 'दक्षिण-पश्चिम';
  if (b < 292.5) return 'पश्चिम';
  return 'उत्तर-पश्चिम';
}
