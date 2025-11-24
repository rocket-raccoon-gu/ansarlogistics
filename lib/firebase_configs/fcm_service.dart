// firebase_configs/fcm_service.dart
import 'dart:convert';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:http/http.dart' as http;

class FCMService {
  static Future<String> getAccessToken() async {
    try {
      // NEVER hardcode service account credentials in your app
      // Instead, get this from your backend server or use secure storage

      // For development, you can load from assets or environment variables
      // In production, this should come from your backend API
      final String serviceAccountJson = await _getServiceAccountJson();

      final serviceAccount =
          json.decode(serviceAccountJson) as Map<String, dynamic>;

      final authClient = await auth.clientViaServiceAccount(
        auth.ServiceAccountCredentials.fromJson(serviceAccount),
        ['https://www.googleapis.com/auth/firebase.messaging'],
      );

      final credentials = await auth.obtainAccessCredentialsViaServiceAccount(
        auth.ServiceAccountCredentials.fromJson(serviceAccount),
        ['https://www.googleapis.com/auth/firebase.messaging'],
        authClient,
      );

      authClient.close();
      return credentials.accessToken.data;
    } catch (e, stackTrace) {
      print('Error obtaining access token: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<String> _getServiceAccountJson() async {
    // ...

    const serviceAccount = String.fromEnvironment(
      'firebase-adminsdk-a6zp5@ah-market-5ab28.iam.gserviceaccount.com',
    );
    if (serviceAccount.isNotEmpty) {
      return serviceAccount;
    }

    throw Exception('FCM service account not configured');
  }

  static Future<bool> sendNotification({
    required String recipientFCMToken,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      final String accessToken = await getAccessToken();
      const String projectId = 'ah-market-5ab28';
      final url = Uri.parse(
        'https://fcm.googleapis.com/v1/projects/$projectId/messages:send',
      );

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      };

      final message = {
        "message": {
          "token": recipientFCMToken,
          "notification": {"title": title, "body": body},
          "android": {
            "notification": {
              "sound": "alert.mp3",
              "channel_id": "ansar_logistics_channel",
            },
          },
          "apns": {
            "payload": {
              "aps": {"sound": "alert.mp3"},
            },
          },
          "data": data ?? {},
        },
      };

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(message),
      );

      if (response.statusCode == 200) {
        print('Notification sent successfully');
        return true;
      } else {
        print(
          'Failed to send notification: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e) {
      print('Error sending notification: $e');
      return false;
    }
  }
}
