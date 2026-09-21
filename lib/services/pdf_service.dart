import 'package:flutter/material.dart';
import '../models/kundali_model.dart';
import 'bhojpatra_pdf_service.dart';

/// On-device भोजपत्र PDF (वेब ऐप जैसी पत्रिका)। पुराना PHP सर्वर नहीं।
class PdfService {
  static Future<void> generateAndSaveKundali(
    BuildContext context,
    KundaliData data,
  ) async {
    try {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('भोजपत्र पत्रिका बन रही है…')),
        );
      }
      await BhojpatraPdfService.kundali(data);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF त्रुटि: $e')),
        );
      }
    }
  }
}
