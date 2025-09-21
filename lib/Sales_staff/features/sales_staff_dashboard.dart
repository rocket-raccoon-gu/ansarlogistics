import 'dart:developer';

import 'package:ansarlogistics/Picker/repository_layer/more_content.dart';
import 'package:ansarlogistics/Sales_staff/features/bloc/sales_staff_dashboard_cubit.dart';
import 'package:ansarlogistics/Sales_staff/features/bloc/sales_staff_dashboard_state.dart';
import 'package:ansarlogistics/constants/methods.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:ansarlogistics/utils/preference_utils.dart';
import 'package:ansarlogistics/utils/utils.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';

class SalesStaffDashboard extends StatefulWidget {
  const SalesStaffDashboard({super.key});

  @override
  State<SalesStaffDashboard> createState() => _SalesStaffDashboardState();
}

class _SalesStaffDashboardState extends State<SalesStaffDashboard>
    with WidgetsBindingObserver {
  String _scanBarcode = 'Unknown';
  late CameraController _cameraController;

  // Add these new variables
  bool _showManualForm = false;
  bool _showBarcodeForm = false;
  final _formKey = GlobalKey<FormState>();
  final _barcodeFormKey = GlobalKey<FormState>();
  final _productNameController = TextEditingController();
  final _staffIdController = TextEditingController();
  final _branchCodeController = TextEditingController();
  final _productDiscountController = TextEditingController();
  final _barcodeController = TextEditingController();

  // Branch dropdown state
  final Map<String, String> _branches = const {
    'Q002': 'Doha city',
    'Q003': 'Ansari city',
    'Q004': 'City center',
    'Q005': 'Mansura',
    'Q008': 'Rayyan',
    'Q009': 'Alkhore',
    'Q011': 'Barwa furniture & Home decor',
    'Q013': 'Barwa super market and department store',
    'Q015': 'Rawdha',
    'Q016': 'new world',
    'Q017': 'A&H fashion',
    'Q018': 'A&H carpet',
    'Q021': 'A&H Market online',
  };
  String? _selectedBranchCode;

  Future<void> scanBarcodeNormal(BuildContext ctx) async {
    String? barcodescanRes;

    try {
      await requestCameraPermission();

      ScanResult scanResult = await BarcodeScanner.scan();
      barcodescanRes = scanResult.rawContent;

      log(barcodescanRes);
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

      // Proceed to check barcode; UI updates happen via Bloc state.
      BlocProvider.of<SalesStaffDashboardCubit>(
        context,
      ).checkBarcodeData(barcodescanRes!);
      // Keep discount as is unless backend fills it through state elsewhere
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
  void initState() {
    // TODO: implement initState
    super.initState();
    // Initialize discount as not available
    _productDiscountController.text = 'Not available';
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _staffIdController.dispose();
    _branchCodeController.dispose();
    _productDiscountController.dispose();
    _barcodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double mheight = MediaQuery.of(context).size.height * 1.222;
    Size screenSize = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(0.0),
          child: AppBar(elevation: 0, backgroundColor: HexColor('#b9d737')),
        ),
        body: BlocBuilder<SalesStaffDashboardCubit, SalesStaffDashboardState>(
          builder: (context, state) {
            // React to scan results to auto-fill fields
            if (state is SalesStaffBarcodeCheckSuccess) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_productNameController.text.trim() != state.erpSku) {
                  _productNameController.text = state.erpSku;
                }
                final disc = state.discountPerc;
                _productDiscountController.text =
                    (disc == null || disc.trim().isEmpty)
                        ? 'Not available'
                        : disc;
              });
            } else if (state is SalesStaffBarcodeCheckNotFound) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_productNameController.text.trim() != state.scannedSku) {
                  _productNameController.text = state.scannedSku;
                }
                _productDiscountController.text = 'Not available';
              });
            }
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
                  child:
                      _showManualForm
                          ? _buildProductEntryForm()
                          : _showBarcodeForm
                          ? _buildBarcodeEntryForm()
                          : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              InkWell(
                                onTap: () {
                                  // Kept existing scan UI for now (no action)
                                },
                                child: GestureDetector(
                                  onTap: () {
                                    scanBarcodeNormal(context);
                                  },
                                  child: Column(
                                    children: [
                                      Image.asset(
                                        'assets/barcode_scan.png',
                                        height: 120.0,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 20.0,
                                        ),
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
                              ),
                            ],
                          ),
                ),
              ],
            );
          },
        ),
        // floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        // floatingActionButton: FloatingActionButton(
        //   backgroundColor: customColors().backgroundTertiary,
        //   elevation: 10.0,
        //   onPressed: () {
        //     scanBarcodeNormal(context);
        //   },
        //   child: Image.asset('assets/barcode_scan.png', height: 25.0),
        // ),
        bottomNavigationBar: Container(
          // height: screenSize.height * 0.025,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 16.0,
              horizontal: 16.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Add Product Button
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _productNameController.clear();
                      _productDiscountController.clear();
                      _showManualForm = !_showManualForm;
                      _showBarcodeForm = false;
                    });
                    BlocProvider.of<SalesStaffDashboardCubit>(
                      context,
                    ).updateData();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: HexColor('#b9d737'),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 4,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, size: 20),
                      SizedBox(width: 8),
                      Text('Add'),
                    ],
                  ),
                ),

                //Scan Barcode
                //
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _showBarcodeForm = true;
                      _showManualForm = false;
                    });
                    BlocProvider.of<SalesStaffDashboardCubit>(
                      context,
                    ).updateData();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: HexColor('#b9d737'),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 12.0,
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.text_fields, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Text Barcode',
                            style: customTextStyle(
                              fontStyle: FontStyle.BodyM_Bold,
                              color: FontColor.FontPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductEntryForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // SKU Field with scanner
              TextFormField(
                controller: _productNameController,
                decoration: InputDecoration(
                  labelText: 'SKU',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.qr_code),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.document_scanner),
                    onPressed: () => scanBarcodeNormal(context),
                    tooltip: 'Scan Barcode',
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter SKU';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Staff ID Field
              TextFormField(
                controller: _staffIdController,
                decoration: const InputDecoration(
                  labelText: 'Staff ID',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.badge),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter Staff ID';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Discount Percentage Field (read-only, auto-filled)
              TextFormField(
                controller: _productDiscountController,
                // readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Discount %',
                  border: OutlineInputBorder(),
                  suffixText: '%',
                  prefixIcon: Icon(Icons.percent),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Discount is required';
                  }
                  if (value.toLowerCase() == 'not available') {
                    // Acceptable as per requirements
                    return null;
                  }
                  final discount = double.tryParse(value);
                  if (discount == null) {
                    return 'Invalid discount value';
                  }
                  if (discount < 0 || discount > 100) {
                    return 'Discount must be between 0-100%';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Branch Code Dropdown (required)
              DropdownButtonFormField<String>(
                isExpanded: true,
                value: _selectedBranchCode,
                items:
                    _branches.entries
                        .map(
                          (entry) => DropdownMenuItem<String>(
                            value: entry.key,
                            child: Text(
                              '${entry.value} (${entry.key})',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              softWrap: false,
                            ),
                          ),
                        )
                        .toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedBranchCode = val;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Branch',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.apartment),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please select a Branch';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          final body = {
                            "erp_sku": _productNameController.text.trim(),
                            "discount_perc":
                                _productDiscountController.text.trim(),
                            "staff_id": _staffIdController.text.trim(),
                            "branch_code": _selectedBranchCode ?? '',
                          };

                          await BlocProvider.of<SalesStaffDashboardCubit>(
                            context,
                          ).addProductToBarcodeDB(body: body);

                          _formKey.currentState!.reset();
                          setState(() {
                            _productNameController.clear();
                            _staffIdController.clear();
                            _productDiscountController.text = 'Not available';
                            _selectedBranchCode = null;
                            _showManualForm = false;
                          });
                          BlocProvider.of<SalesStaffDashboardCubit>(
                            context,
                          ).updateData();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Submit'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  TextButton(
                    onPressed: () {
                      _formKey.currentState!.reset();
                      setState(() {
                        _productNameController.clear();
                        _staffIdController.clear();
                        _productDiscountController.text = 'Not available';
                        _selectedBranchCode = null;
                        _showManualForm = false;
                      });
                      BlocProvider.of<SalesStaffDashboardCubit>(
                        context,
                      ).updateData();
                    },
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBarcodeEntryForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _barcodeFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Enter SKU',
              style: customTextStyle(
                fontStyle: FontStyle.BodyL_Bold,
                color: FontColor.FontPrimary,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _barcodeController,
              decoration: const InputDecoration(
                labelText: 'SKU / Barcode',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.qr_code),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a SKU';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_barcodeFormKey.currentState!.validate()) {
                        // show loading and call checkBarcodeData
                        sholoadingIndicator(context);
                        await BlocProvider.of<SalesStaffDashboardCubit>(
                          context,
                        ).checkBarcodeData(_barcodeController.text.trim());
                        // Clear and hide form after call
                        _barcodeFormKey.currentState!.reset();
                        setState(() {
                          _barcodeController.clear();
                          _showBarcodeForm = false;
                        });
                        BlocProvider.of<SalesStaffDashboardCubit>(
                          context,
                        ).updateData();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: HexColor('#b9d737'),
                    ),
                    child: const Text('Submit'),
                  ),
                ),
                const SizedBox(width: 10),
                TextButton(
                  onPressed: () {
                    _barcodeFormKey.currentState!.reset();
                    setState(() {
                      _barcodeController.clear();
                      _showBarcodeForm = false;
                    });
                    BlocProvider.of<SalesStaffDashboardCubit>(
                      context,
                    ).updateData();
                  },
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
