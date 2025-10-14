import 'dart:developer';

import 'package:ansarlogistics/Picker/repository_layer/more_content.dart';
import 'package:ansarlogistics/constants/methods.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:ansarlogistics/user_controller/user_controller.dart';
import 'package:ansarlogistics/utils/preference_utils.dart';
import 'package:ansarlogistics/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/staff_main_panel_cubit.dart';
import 'bloc/staff_main_panel_state.dart';
import 'package:barcode_scan2/barcode_scan2.dart';

class StaffMainPanel extends StatefulWidget {
  const StaffMainPanel({super.key});

  @override
  State<StaffMainPanel> createState() => _StaffMainPanelState();
}

class _StaffMainPanelState extends State<StaffMainPanel> {
  //
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _skuController;
  late TextEditingController _productNameController;
  late TextEditingController _uomController;
  late TextEditingController _qtyController;
  // manual entry
  final _manualFormKey = GlobalKey<FormState>();
  late TextEditingController _manualBarcodeController;
  //
  List<Map<String, dynamic>> _bulkList = [];

  Future<void> _loadBulkList() async {
    final list = await PreferenceUtils.getstoremap('staff_bulk_queue');
    setState(() {
      _bulkList =
          list
              .map<Map<String, dynamic>>(
                (e) => Map<String, dynamic>.from(e as Map),
              )
              .toList();
    });
  }

  Future<void> _saveBulkList() async {
    await PreferenceUtils.storeListmap('staff_bulk_queue', _bulkList);
  }

  Future<void> _addCurrentToBulk() async {
    if (_formKey.currentState?.validate() ?? false) {
      final sku = _skuController.text.trim();
      final name = _productNameController.text.trim();
      final uom = _uomController.text.trim();
      final qty = num.tryParse(_qtyController.text.trim()) ?? 0;
      if (sku.isEmpty || name.isEmpty || uom.isEmpty || qty <= 0) return;

      final alreadyExists = _bulkList.any(
        (e) =>
            (e['erp_sku']?.toString() ?? '') == sku &&
            (e['uom']?.toString() ?? '') == uom,
      );
      if (alreadyExists) {
        showSnackBar(
          context: context,
          snackBar: showErrorDialogue(errorMessage: 'Item already in list'),
        );
        return;
      }

      final item = {
        'erp_sku': sku,
        'erp_product_name': name,
        'uom': uom,
        'erp_qty': qty,
      };
      setState(() {
        _bulkList.add(item);
      });
      await _saveBulkList();
      _formKey.currentState?.reset();
      _skuController.clear();
      _productNameController.clear();
      _uomController.clear();
      _qtyController.text = '1';
      context.read<StaffMainPanelCubit>().loadpage();
    }
  }

  Future<void> _removeFromBulk(int index) async {
    setState(() {
      _bulkList.removeAt(index);
    });
    await _saveBulkList();
  }

  Future<void> _uploadAllBulk() async {
    if (_bulkList.isEmpty) return;
    sholoadingIndicator(context, 'Uploading bulk items...');
    await context.read<StaffMainPanelCubit>().submitBulkItems(_bulkList);
    if (Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true).maybePop();
    }
    await _saveBulkList();
    if (mounted) {
      context.read<StaffMainPanelCubit>().loadpage();
    }
  }

  @override
  void initState() {
    super.initState();
    _skuController = TextEditingController();
    _productNameController = TextEditingController();
    _uomController = TextEditingController();
    _qtyController = TextEditingController(text: '1');
    _manualBarcodeController = TextEditingController();
    _loadBulkList();
  }

  @override
  void dispose() {
    _skuController.dispose();
    _productNameController.dispose();
    _uomController.dispose();
    _qtyController.dispose();
    _manualBarcodeController.dispose();
    super.dispose();
  }

  //
  Future<void> scanBarcodeNormal(BuildContext ctx) async {
    String? barcodescanRes;

    try {
      await requestCameraPermission();

      ScanResult scanResult = await BarcodeScanner.scan();
      barcodescanRes = scanResult.rawContent;

      log(barcodescanRes);

      if (barcodescanRes == "" || barcodescanRes == "-1") {
        // ignore: use_build_context_synchronously
        showSnackBar(
          context: context,
          snackBar: showErrorDialogue(errorMessage: "No barcode captured"),
        );
        return;
      }

      try {
        sholoadingIndicator(context, 'Checking barcode...');

        BlocProvider.of<StaffMainPanelCubit>(
          context,
        ).checkBarcodeData(barcodescanRes!);
      } catch (e) {}
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
      log(e.toString());
    }
  }

  void _openManualBarcodeEntry() {
    _manualBarcodeController.clear();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Form(
            key: _manualFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Enter Barcode',
                      style: customTextStyle(
                        fontStyle: FontStyle.BodyL_Bold,
                        color: FontColor.FontPrimary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        Navigator.of(ctx).pop();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (_bulkList.isNotEmpty) ...[
                  Text(
                    'Saved barcodes (' + _bulkList.length.toString() + ')',
                    style: customTextStyle(
                      fontStyle: FontStyle.BodyL_Bold,
                      color: FontColor.FontPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 150,
                    child: ListView.builder(
                      itemCount: _bulkList.length,
                      itemBuilder: (ctx, i) {
                        final it = _bulkList[i];
                        final code =
                            (it['barcode'] ?? it['erp_sku'] ?? '').toString();
                        final qty =
                            (it['erp_qty'] ?? it['qty'] ?? '').toString();
                        return ListTile(
                          dense: true,
                          leading: const Icon(Icons.qr_code_2),
                          title: Text(code),
                          subtitle: Text('Qty: ' + qty),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                TextFormField(
                  controller: _manualBarcodeController,
                  autofocus: true,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(labelText: 'Barcode'),
                  validator:
                      (v) =>
                          (v == null || v.trim().isEmpty)
                              ? 'Barcode required'
                              : null,
                  onFieldSubmitted: (_) {},
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (_manualFormKey.currentState?.validate() ?? false) {
                      final code = _manualBarcodeController.text.trim();
                      Navigator.of(ctx).pop();
                      sholoadingIndicator(context, 'Checking barcode...');
                      context.read<StaffMainPanelCubit>().checkBarcodeData(
                        code,
                      );
                    }
                  },
                  child: const Text('Get Data'),
                ),
              ],
            ),
          ),
        );
      },
    );
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
        body: BlocConsumer<StaffMainPanelCubit, StaffMainPanelState>(
          listener: (context, state) {
            if (state is StaffMainPanelSuccessState ||
                state is StaffMainPanelErrorState ||
                state is StaffMainPanelInitialState) {
              if (Navigator.of(context, rootNavigator: true).canPop()) {
                Navigator.of(context, rootNavigator: true).maybePop();
              }
            }
            if (state is StaffMainPanelSuccessState) {
              final items = (state.data['items'] as List?) ?? [];
              final item =
                  items.isNotEmpty && items.first is Map
                      ? Map<String, dynamic>.from(items.first as Map)
                      : <String, dynamic>{};

              _skuController.text =
                  (item['erp_sku'] ?? item['product_sku'] ?? '').toString();
              _productNameController.text =
                  (item['erp_product_name'] ?? item['product_name'] ?? '')
                      .toString();
              _uomController.text =
                  (item['uom'] ?? item['unit'] ?? item['uom_name'] ?? '')
                      .toString();
              // if ((_qtyController.text).trim().isEmpty) {
              _qtyController.text = '';
              // }
            }
          },
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
                                "${UserController().userName}",
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
                            OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.black),
                              ),
                              onPressed: _openManualBarcodeEntry,
                              icon: const Icon(Icons.keyboard),
                              label: const Text('Text'),
                            ),
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
                      (state is StaffMainPanelSuccessState)
                          ? SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  TextFormField(
                                    controller: _skuController,
                                    readOnly: true,
                                    decoration: const InputDecoration(
                                      labelText: 'SKU',
                                    ),
                                    validator:
                                        (v) =>
                                            (v == null || v.trim().isEmpty)
                                                ? 'SKU required'
                                                : null,
                                  ),
                                  const SizedBox(height: 12),
                                  TextFormField(
                                    controller: _productNameController,
                                    readOnly: true,
                                    decoration: const InputDecoration(
                                      labelText: 'Product Name',
                                    ),
                                    validator:
                                        (v) =>
                                            (v == null || v.trim().isEmpty)
                                                ? 'Product name required'
                                                : null,
                                  ),
                                  const SizedBox(height: 12),
                                  TextFormField(
                                    controller: _uomController,
                                    readOnly: true,
                                    decoration: const InputDecoration(
                                      labelText: 'UOM',
                                    ),
                                    validator:
                                        (v) =>
                                            (v == null || v.trim().isEmpty)
                                                ? 'UOM required'
                                                : null,
                                  ),
                                  const SizedBox(height: 12),
                                  TextFormField(
                                    controller: _qtyController,
                                    autofocus: true,
                                    keyboardType:
                                        TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                    decoration: const InputDecoration(
                                      labelText: 'Qty',
                                    ),
                                    validator: (v) {
                                      if (v == null || v.trim().isEmpty)
                                        return 'Qty required';
                                      final num? n = num.tryParse(v);
                                      if (n == null || n <= 0)
                                        return 'Qty must be > 0';
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton(
                                          onPressed: () {
                                            _formKey.currentState?.reset();
                                            _skuController.clear();
                                            _productNameController.clear();
                                            _uomController.clear();
                                            _qtyController.text = '1';
                                            context
                                                .read<StaffMainPanelCubit>()
                                                .loadpage();
                                          },
                                          child: const Text('Cancel'),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: _addCurrentToBulk,
                                          child: const Text('Add to List'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          )
                          : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  _bulkList.isEmpty
                                      ? 'No saved barcodes'
                                      : 'Saved barcodes (' +
                                          _bulkList.length.toString() +
                                          ')',
                                  style: customTextStyle(
                                    fontStyle: FontStyle.BodyL_Bold,
                                    color: FontColor.FontPrimary,
                                  ),
                                ),
                              ),
                              if (_bulkList.isNotEmpty)
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: _bulkList.length,
                                    itemBuilder: (ctx, i) {
                                      final it = _bulkList[i];
                                      final code =
                                          (it['barcode'] ?? it['erp_sku'] ?? '')
                                              .toString();
                                      final qty =
                                          (it['erp_qty'] ?? it['qty'] ?? '')
                                              .toString();
                                      final uom = (it['uom'] ?? '').toString();
                                      return ListTile(
                                        dense: true,
                                        leading: const Icon(Icons.qr_code_2),
                                        title: Text(code),
                                        subtitle: Text(
                                          'Qty: ' +
                                              qty +
                                              (uom.isNotEmpty
                                                  ? (' • ' + uom)
                                                  : ''),
                                        ),
                                        trailing: IconButton(
                                          icon: const Icon(
                                            Icons.delete_outline,
                                          ),
                                          onPressed: () => _removeFromBulk(i),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                            ],
                          ),
                ),
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            scanBarcodeNormal(context);
          },
          child: const Icon(Icons.qr_code_2),
        ),
        bottomNavigationBar: SizedBox(
          height: 100,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_bulkList.isNotEmpty)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        setState(() {
                          _bulkList.clear();
                        });
                        await PreferenceUtils.removeDataFromShared(
                          'staff_bulk_queue',
                        );
                      },
                      icon: const Icon(Icons.delete_sweep_outlined),
                      label: const Text('Clear All'),
                    ),
                  ),
                const SizedBox(width: 12),
                if (_bulkList.isNotEmpty)
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: customColors().primary,
                      ),
                      onPressed: _uploadAllBulk,
                      icon: const Icon(
                        Icons.cloud_upload_outlined,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Upload All',
                        style: TextStyle(color: Colors.white),
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
}
