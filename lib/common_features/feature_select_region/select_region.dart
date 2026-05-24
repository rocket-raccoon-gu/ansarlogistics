import 'dart:developer';

import 'package:ansarlogistics/Picker/repository_layer/more_content.dart';
import 'package:ansarlogistics/app_page_injectable.dart';
import 'package:ansarlogistics/components/restart_widget.dart';
import 'package:ansarlogistics/services/service_locator.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:ansarlogistics/user_controller/user_controller.dart';
import 'package:ansarlogistics/utils/preference_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class SelectRegionPage extends StatefulWidget {
  final ServiceLocator serviceLocator;
  const SelectRegionPage({super.key, required this.serviceLocator});

  @override
  State<SelectRegionPage> createState() => _SelectRegionPageState();
}

class _SelectRegionPageState extends State<SelectRegionPage> {
  bool _isLoadingQA = false;

  // ---------------------------------------------------------------------------
  // Fetch QA base URL and check_barcode_path directly from Firestore at tap time.
  // This avoids startup-timing issues and Firestore security rule problems.
  // ---------------------------------------------------------------------------
  Future<Map<String, String>> _fetchQAPathsFromFirestore() async {
    const fallbackBaseUrl = 'https://pickerdriver-api.testuatah.com';
    const fallbackBarcodePath = 'https://pickerdriver.testuatah.com/';

    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('base_path')
              .limit(10)
              .get();

      log('📦 base_path docs count: ${snapshot.docs.length}');

      if (snapshot.docs.isNotEmpty) {
        // Find the first document that has a baseurl field (for-loop avoids
        // Firestore's internal type conflict with firstWhere + orElse)
        Map<String, dynamic>? data;
        for (final doc in snapshot.docs) {
          final d = doc.data();
          if (d.containsKey('baseurl')) {
            data = d;
            break;
          }
        }
        // Fall back to first doc if none had the field
        data ??= snapshot.docs.first.data();

        final baseUrl = (data['baseurl'] as String? ?? '').trim();
        final checkBarcodePath =
            (data['check_barcode_path'] as String? ?? '').trim();

        log('✅ QA baseUrl from Firestore: $baseUrl');
        log('✅ QA check_barcode_path from Firestore: $checkBarcodePath');

        await PreferenceUtils.storeDataToShared(
          "qa_check_barcode_path",
          checkBarcodePath.isNotEmpty ? checkBarcodePath : fallbackBarcodePath,
        );

        return {
          'baseurl': baseUrl.isNotEmpty ? baseUrl : fallbackBaseUrl,
          'check_barcode_path':
              checkBarcodePath.isNotEmpty
                  ? checkBarcodePath
                  : fallbackBarcodePath,
        };
      } else {
        log('⚠️ base_path collection returned no docs – using fallback');
        return {
          'baseurl': fallbackBaseUrl,
          'check_barcode_path': fallbackBarcodePath,
        };
      }
    } catch (e, st) {
      log('❌ Firestore fetch error: $e', stackTrace: st);
      return {
        'baseurl': fallbackBaseUrl,
        'check_barcode_path': fallbackBarcodePath,
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: double.infinity,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/bg.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        GestureDetector(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(0.0),
              child: AppBar(
                elevation: 0,
                backgroundColor: customColors().backgroundPrimary,
              ),
            ),
            body: Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 70),
                      child: SizedBox(
                        height: 150,
                        width: 250,
                        child: Image.asset("assets/ansar-logistics.png"),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(top: 15.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Please Choose Your Region.",
                            style: customTextStyle(
                              fontStyle: FontStyle.HeaderXS_Bold,
                              color: FontColor.FontPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              // ── QA (Qatar) ──────────────────────────────
                              InkWell(
                                onTap:
                                    _isLoadingQA
                                        ? null
                                        : () async {
                                          setState(() => _isLoadingQA = true);

                                          // Fetch base URL and check_barcode_path live from Firestore
                                          final paths =
                                              await _fetchQAPathsFromFirestore();
                                          // final baseUrl = paths['baseurl']!;
                                          final baseUrl =
                                              'https://logh.ansargallery.qa';
                                          final checkBarcodePath =
                                              paths['check_barcode_path']!;

                                          UserController
                                                  .userController
                                                  .mainbaseUrl =
                                              'https://logh.ansargallery.qa';

                                          await PreferenceUtils.storeDataToShared(
                                            "region",
                                            'QA',
                                          );

                                          await PreferenceUtils.storeDataToShared(
                                            "mainbaseurl",
                                            baseUrl,
                                          );

                                          await PreferenceUtils.storeDataToShared(
                                            "check_barcode_path",
                                            checkBarcodePath,
                                          );

                                          if (!context.mounted) return;
                                          setState(() => _isLoadingQA = false);

                                          // Update the ServiceLocator so all HTTP calls use the new URL
                                          widget.serviceLocator.updateBaseUrl(
                                            baseUrl,
                                          );

                                          context.gNavigationService
                                              .openLoginPage(context);
                                        },
                                child:
                                    _isLoadingQA
                                        ? const SizedBox(
                                          height: 80,
                                          width: 80,
                                          child: Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                        )
                                        : Image.asset(
                                          'assets/qatar.png',
                                          height: 80,
                                        ),
                              ),
                              // ── BH (Bahrain) ─────────────────────────────
                              Padding(
                                padding: const EdgeInsets.only(top: 6.0),
                                child: InkWell(
                                  onTap: () async {
                                    UserController
                                        .userController
                                        .mainbaseUrl = String.fromEnvironment(
                                      'BASE_URL',
                                      defaultValue:
                                          "https://pickerdriver-api-bh.testuatah.com",
                                    );

                                    await PreferenceUtils.storeDataToShared(
                                      "mainbaseurl",
                                      UserController.userController.mainbaseUrl,
                                    );

                                    await PreferenceUtils.storeDataToShared(
                                      "region",
                                      'BH',
                                    );

                                    if (!context.mounted) return;
                                    widget.serviceLocator.updateBaseUrl(
                                      UserController.userController.mainbaseUrl,
                                    );

                                    context.gNavigationService.openLoginPage(
                                      context,
                                    );
                                  },
                                  child: Image.asset(
                                    'assets/bahrain.png',
                                    height: 80,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 6.0),
                            child: Column(
                              children: [
                                // ── UAE ───────────────────────────────────
                                InkWell(
                                  onTap: () async {
                                    UserController
                                        .userController
                                        .mainbaseUrl = String.fromEnvironment(
                                      'BASE_URL',
                                      defaultValue:
                                          "https://pickerdriver-api-uae.testuatah.com",
                                    );
                                    await PreferenceUtils.storeDataToShared(
                                      "mainbaseurl",
                                      UserController.userController.mainbaseUrl,
                                    );

                                    await PreferenceUtils.storeDataToShared(
                                      "region",
                                      'UAE',
                                    );
                                    if (!context.mounted) return;
                                    widget.serviceLocator.updateBaseUrl(
                                      UserController.userController.mainbaseUrl,
                                    );
                                    context.gNavigationService.openLoginPage(
                                      context,
                                    );
                                  },
                                  child: Image.asset(
                                    'assets/uae.png',
                                    height: 80,
                                  ),
                                ),
                                // ── OM (Oman) ──────────────────────────────
                                Padding(
                                  padding: const EdgeInsets.only(top: 6.0),
                                  child: InkWell(
                                    onTap: () async {
                                      UserController
                                          .userController
                                          .mainbaseUrl = String.fromEnvironment(
                                        'BASE_URL',
                                        defaultValue:
                                            "https://pickerdriver-api-om.testuatah.com",
                                      );
                                      await PreferenceUtils.storeDataToShared(
                                        "region",
                                        'OM',
                                      );

                                      await PreferenceUtils.storeDataToShared(
                                        "mainbaseurl",
                                        UserController
                                            .userController
                                            .mainbaseUrl,
                                      );

                                      if (!context.mounted) return;
                                      widget.serviceLocator.updateBaseUrl(
                                        UserController
                                            .userController
                                            .mainbaseUrl,
                                      );
                                      context.gNavigationService.openLoginPage(
                                        context,
                                      );
                                    },
                                    child: Image.asset(
                                      'assets/oman.png',
                                      height: 80,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Global loading overlay when fetching QA URL
                if (_isLoadingQA)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black26,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
