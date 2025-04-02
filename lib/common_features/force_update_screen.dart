// force_update_screen.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ForceUpdateScreen extends StatelessWidget {
  const ForceUpdateScreen({super.key});

  void _openPlayStore() async {
    const url =
        'https://play.google.com/store/apps/details?id=com.ansar.ansarlogistics&hl=en';
    try {
      await launchUrl(Uri.parse(url));
    } catch (e) {
      await launchUrl(
        Uri.parse(
          'https://play.google.com/store/apps/details?id=com.ansar.logistics',
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Update Required',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Please update to the latest version to continue using Ansar Logistics',
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _openPlayStore,
              child: const Text('UPDATE NOW'),
            ),
          ],
        ),
      ),
    );
  }
}
