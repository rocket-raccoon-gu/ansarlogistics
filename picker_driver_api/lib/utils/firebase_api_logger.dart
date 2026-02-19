import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class FirebaseApiLogger {
  static final DatabaseReference _rootRef = FirebaseDatabase.instance.ref(
    'Api Logs',
  );

  static Future<void> logApiError({
    required String apiName, // e.g. "Login Api" or "picker/orders/status"
    required Map<String, dynamic> payload,
    required Map<String, dynamic> req,
    required int timedurationMs,
    String? token,
    String? userid,
    String? error, // error message / stack
  }) async {
    final now = DateTime.now();
    final dateStr = DateFormat('yyyy-MM-dd').format(now);

    final ref = _rootRef.child(apiName).child(dateStr).push(); // auto id

    await ref.set({
      'payload': payload,
      'req': req,
      'timeduration': timedurationMs,
      'token': token,
      'userid': userid,
      'error': error,
      'timestamp': now.toIso8601String(),
    });
  }
}
