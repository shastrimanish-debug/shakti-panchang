import 'dart:convert';
import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/astrologer_branding.dart';
import '../models/kundali_model.dart';
import 'advanced_kundali_service.dart';
import 'astrologer_branding_store.dart';
import 'kundali_analysis_service.dart';
import 'pdf_devanagari_fonts.dart';

/// Webapp `exhaustiveKundaliPdf.ts` (59-page mahapatrika) का ऑन-डिवाइस संस्करण।
class ExhaustiveKundaliPdfService {
  static const _bg = PdfColor.fromInt(0xFFFBF3E0);
  static const _brown = PdfColor.fromInt(0xFF5C3A21);
  static const _gold = PdfColor.fromInt(0xFFC58F27);
  static const _red = PdfColor.fromInt(0xFF8B1E1E);

  static const _housePhal = [
    'प्रथम भाव — तनु, स्वभाव, आकृति, स्वास्थ्य का मूल और जीवन की दिशा। लग्न बल व्यक्तित्व तय करता है।',
    'द्वितीय भाव — धन संग्रह, वाणी, परिवार, आࠓख और भोजन। वाणी की शुचिता यहाࠓ से देखी जाती है।',
  ];
}
