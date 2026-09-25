import 'package:flutter/material.dart';
import 'festivals_screen.dart';
import 'locations_screen.dart';
import 'reminder_screen.dart';
import 'kundali_screen.dart';
import 'uma_screen.dart';
import 'vrat_katha_screen.dart';
import 'kalnirnay_screen.dart';
import 'sade_sati_screen.dart';
import 'daily_shloka_screen.dart';
import 'hora_chakra_screen.dart';
import 'gochar_screen.dart';
import 'annual_muhurat_screen.dart';
import 'digital_compass_screen.dart';
import 'moon_phase_screen.dart';
import 'astrologer_branding_screen.dart';
import 'varga_analysis_screen.dart';

class ToolsScreen extends StatelessWidget {
  final DateTime date;
  const ToolsScreen({super.key, required this.date});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('✨ Shakti Panchang Tools')),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _tile(context, Icons.auto_awesome, 'जन्म कुंडली', 'Lahiri • लग्न • ग्रह • भाव • दशा', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const KundaliScreen()))),
        _tile(context, Icons.event_note, 'पर्व और व्रत',
          'एकादशी, पूर्णिमा, अमावस्या और प्रमुख पर्व',
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => FestivalsScreen(date: date)))),
        _tile(context, Icons.location_on, 'मेरे स्थान',
          'Vadodara, Mumbai, Burhanpur आदि सेव करें',
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LocationsScreen()))),
        _tile(context, Icons.notifications_active, 'उमा Reminder',
          'शुभ समय या यात्रा का समय याद रखें',
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReminderScreen()))),
        _tile(context, Icons.auto_awesome, 'उमा विद्वान् ज्योतिषी',
          'कुंडली, मुहूर्त, साढ़े साती, उपाय',
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => UmaScreen(date: date)))),
        _tile(context, Icons.menu_book, 'व्रत कथा व आरती',
          'सत्यनारायण, एकादशी, प्रदोष, चालीसा',
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VratKathaScreen()))),
        _tile(context, Icons.grid_view, 'कालनिर्णय पंचांग',
          'मासिक तिथि-ग्रिड व व्रत बिल्ले',
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const KalnirnayScreen()))),
        _tile(context, Icons.nights_stay, 'साढ़े साती',
          'शनि चरण, ढैया और वैदिक उपाय',
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SadeSatiScreen()))),
        _tile(context, Icons.format_quote, 'आज का श्लोक',
          'गीता, नीति और स्तोत्र संग्रह',
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DailyShlokaScreen()))),
        _tile(context, Icons.watch_later_outlined, 'होरा चक्र',
          '24 होरा और वर्तमान ग्रह काल',
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HoraChakraScreen()))),
        _tile(context, Icons.public, 'दैनिक गोचर',
          'ग्रह गोचर चंद्र भाव से',
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GocharScreen()))),
        _tile(context, Icons.table_chart_outlined, 'मुहूर्त सारणी',
          'ब्रह्म, अभिजित, विजय, प्रदोष',
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AnnualMuhuratScreen()))),
        _tile(context, Icons.explore_rounded, 'वैदिक दिशा-सूचक',
          'दिशाशूल क्षेत्र और लक्ष्य दिशा',
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DigitalCompassScreen()))),
        _tile(context, Icons.nightlight_round, 'चन्द्र कला',
          'तिथि, पक्ष और प्रकाश प्रतिशत',
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MoonPhaseScreen()))),
        _tile(context, Icons.hub_outlined, 'वर्ग विश्लेषण',
          'D1–D60 उद्देश्य, विवाह-करियर-धन',
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VargaAnalysisScreen()))),
        _tile(context, Icons.badge_outlined, 'ज्योतिषी ब्रांडिंग',
          'PDF आवरण पर नाम, नगर, संस्थान',
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AstrologerBrandingScreen()))),
      ],
    ),
  );

  Widget _tile(BuildContext context, IconData icon, String title, String sub, VoidCallback tap) =>
      Card(child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(child: Icon(icon)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
        subtitle: Text(sub),
        trailing: const Icon(Icons.chevron_right),
        onTap: tap,
      ));
}
