import 'dart:convert';
import 'dart:developer';

import 'package:ansarlogistics/Picker/repository_layer/more_content.dart';
import 'package:ansarlogistics/Picker/repository_layer/scandit_barcode_scanner_page.dart';
import 'package:ansarlogistics/Sales_staff/features/bloc/sales_staff_dashboard_cubit.dart';
import 'package:ansarlogistics/Sales_staff/features/bloc/sales_staff_dashboard_state.dart';
import 'package:ansarlogistics/app_page_injectable.dart';
import 'package:ansarlogistics/constants/methods.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:ansarlogistics/utils/preference_utils.dart';
import 'package:ansarlogistics/utils/utils.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SalesStaffDashboard extends StatefulWidget {
  const SalesStaffDashboard({super.key});

  @override
  State<SalesStaffDashboard> createState() => _SalesStaffDashboardState();
}

class _SalesStaffDashboardState extends State<SalesStaffDashboard>
    with WidgetsBindingObserver {
  String _scanBarcode = 'Unknown';
  late CameraController _cameraController;

  Future<void> scanBarcodeNormal(BuildContext ctx) async {
    String? barcodescanRes;

    try {
      await requestCameraPermission();

      final result = await Navigator.of(context).push<String>(
        MaterialPageRoute(builder: (_) => const ScanditBarcodeScannerPage()),
      );

      log(result.toString());

      barcodescanRes = result;

      log(barcodescanRes!);
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.cameraAccessDenied) {
        setState(() {
          barcodescanRes = 'Camera permission was denied';
        });
      } else {
        setState(() {
          barcodescanRes = 'Unknown error: $e';
        });
      }
    } on FormatException {
      setState(() {
        barcodescanRes = 'Nothing captured.';
      });
    } catch (e) {
      setState(() {
        barcodescanRes = 'Unknown error: $e';
      });
    }

    if (barcodescanRes == "" || barcodescanRes == "-1") {
      // ignore: use_build_context_synchronously
      showSnackBar(
        context: context,
        snackBar: showErrorDialogue(
          errorMessage: "Item Not Scanned Properly Retry...!",
        ),
      );
      return;
    }

    try {
      sholoadingIndicator(context);

      BlocProvider.of<SalesStaffDashboardCubit>(
        context,
      ).checkBarcodeData(barcodescanRes!);
    } catch (e) {
      // ignore: use_build_context_synchronously
      showSnackBar(
        context: context,
        snackBar: showErrorDialogue(
          errorMessage: "Item Not Scanned Properly Retry...!",
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double mheight = MediaQuery.of(context).size.height * 1.222;
    Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0.0),
        child: AppBar(elevation: 0, backgroundColor: HexColor('#b9d737')),
      ),
      body: BlocBuilder<SalesStaffDashboardCubit, SalesStaffDashboardState>(
        builder: (context, state) {
          return Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(color: HexColor('#b9d737')),
                child: Padding(
                  padding: EdgeInsets.only(top: mheight * .012),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              Scaffold.of(context).openDrawer();
                            },
                            icon: Icon(Icons.menu),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 6.0),
                            child: Text(
                              "Sales DashBoard",
                              style: customTextStyle(
                                fontStyle: FontStyle.BodyL_Bold,
                                color: FontColor.FontSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Text(AppLocalizations.of(context).helloWorld),
                      Row(
                        children: [
                          // Clock(),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7.0,
                            ),
                            child: InkWell(
                              onTap: () async {
                                await PreferenceUtils.removeDataFromShared(
                                  "userCode",
                                );
                                await PreferenceUtils.removeDataFromShared(
                                  "profiledetails",
                                );
                                await PreferenceUtils.clear();
                                // ignore: use_build_context_synchronously
                                await logout(context);
                              },
                              child: Image.asset(
                                'assets/logout.png',
                                height: 25,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () {
                        scanBarcodeNormal(context);
                      },
                      child: Column(
                        children: [
                          Image.asset('assets/barcode_scan.png', height: 120.0),
                          Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: Text(
                              "Tap To Scan Barcodes...",
                              style: customTextStyle(
                                fontStyle: FontStyle.BodyM_Bold,
                                color: FontColor.FontTertiary,
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
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        backgroundColor: customColors().backgroundTertiary,
        elevation: 10.0,
        onPressed: () {
          scanBarcodeNormal(context);
        },
        child: Image.asset('assets/barcode_scan.png', height: 25.0),
      ),
      bottomNavigationBar: Container(
        height: screenSize.height * 0.025,
        padding: const EdgeInsets.symmetric(vertical: 10.0),
      ),
    );
  }
}
