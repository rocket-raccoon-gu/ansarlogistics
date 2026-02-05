import 'package:ansarlogistics/app_page_injectable.dart';
import 'package:ansarlogistics/components/progress_indecator.dart';
import 'package:ansarlogistics/utils/preference_utils.dart';
import 'package:flutter/material.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    // 1. Wait splash duration
    await Future.delayed(const Duration(seconds: 5));

    // 2. Read stored credentials
    final username = await PreferenceUtils.getDataFromShared('username');
    final password = await PreferenceUtils.getDataFromShared('password');
    final token = await PreferenceUtils.getDataFromShared('auth_token');

    // 3. Decide where to go
    if (!mounted) return;

    if (username != null &&
        username.isNotEmpty &&
        token != null &&
        token.isNotEmpty) {
      // Option A: if token is enough, skip login and go directly to home/orders
      context.gNavigationService.openPickerDashboardPage(context);
      // or Navigator.pushReplacementNamed(context, RoutesNames.home);
    } else {
      // Option B: No credentials → go to SelectRegion or Login
      context.gNavigationService.openLoginPage(context);
      // or RoutesNames.selectRegionRoot if region must be chosen first
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        // Same logo + progress indicator you currently have in LoginPage
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image.asset('assets/logo.png', height: ...),
            // CircularProgressIndicator(),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset("assets/ansar-logistics.png", height: 150.0),
                  const SizedBox(height: 12.0),
                  const SizedBox(width: 100, child: CustomProgressIndicator()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
