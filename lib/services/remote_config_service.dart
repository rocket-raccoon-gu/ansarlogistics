import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Fetches remote configuration values from Firestore on-demand.
///
/// Collections:
///   • check_barcode_path → base URL used by checkBarcodeDB (fetched just-in-time at scan time)
class RemoteConfigService {
  static const String _kFallbackBarcodeUrl =
      'https://driver.ansargallery.qa/driver';

  /// Fetches the barcode API base URL from Firestore `check_barcode_path`
  /// collection. Call this just before a barcode scan API call.
  /// Returns a fallback URL if Firestore is unreachable.
  static Future<String> fetchCheckBarcodeUrl() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('check_barcode_path')
          .limit(10)
          .get();

      log('📦 check_barcode_path docs count: ${snapshot.docs.length}');

      if (snapshot.docs.isNotEmpty) {
        Map<String, dynamic>? data;
        for (final doc in snapshot.docs) {
          final d = doc.data();
          if (d.containsKey('baseurl')) {
            data = d;
            break;
          }
        }
        data ??= snapshot.docs.first.data();

        final url = (data['baseurl'] as String? ?? '').trim();
        log('✅ checkBarcodeDB baseUrl from Firestore: $url');
        return url.isNotEmpty ? url : _kFallbackBarcodeUrl;
      } else {
        log('⚠️ check_barcode_path has no docs – using fallback');
        return _kFallbackBarcodeUrl;
      }
    } catch (e, st) {
      log('❌ check_barcode_path fetch failed: $e', stackTrace: st);
      return _kFallbackBarcodeUrl;
    }
  }
}
