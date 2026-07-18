import 'dart:convert';
import 'dart:developer';

import 'package:ansarlogistics/cashier/feature_cashier/cashier_orders_page.dart';
import 'package:ansarlogistics/constants/methods.dart';
import 'package:ansarlogistics/constants/texts.dart';
import 'package:ansarlogistics/services/service_locator.dart';
import 'package:ansarlogistics/utils/utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:picker_driver_api/responses/cashier_order_response.dart';
import 'package:ansarlogistics/app_page_injectable.dart';
import 'package:ansarlogistics/user_controller/user_controller.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ansarlogistics/cashier/feature_cashier_order_inner/bloc/cashier_order_inner_page_cubit.dart';
import 'package:ansarlogistics/cashier/feature_cashier_order_inner/bloc/cashier_order_inner_page_state.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:ansarlogistics/utils/preference_utils.dart';
import 'package:flutter/services.dart';

class CashierOrderInnerPage extends StatefulWidget {
  const CashierOrderInnerPage({super.key, required this.arguments});

  final Map<String, dynamic> arguments;

  @override
  State<CashierOrderInnerPage> createState() => _CashierOrderInnerPageState();
}

class _CashierOrderInnerPageState extends State<CashierOrderInnerPage> {
  late Datum order;
  bool _submitting = false;
  bool _uploading = false;
  bool _isClubEnabled = false;
  String? _posBillUrl;
  XFile? _pickedImage;
  double? _uploadProgress; // 0.0 - 1.0
  final Set<int> _selectedItemIds = <int>{};
  String? paymentMethodnew;

  String? _translatedNote;
  bool _isTranslating = false;

  double _editableGrandTotal = 0.0;

  // Editable Grand Total state
  // final TextEditingController _grandTotalController = TextEditingController();
  double? _grandTotalOverride; // if null, use base computed value

  // Dispatch method selected by cashier: 'normal' | 'driver' | 'rider'
  String? dispatchMethod;

  // Sadad QA payment lookup state
  bool _sadadLoading = false;
  String? _sadadError;
  List<Map<String, dynamic>> _sadadTxns = const [];

  // Safe parsers to prevent FormatException when API returns empty or non-numeric strings
  double _toDouble(Object? s) {
    final v = s?.toString().trim() ?? '';
    if (v.isEmpty) return 0;
    return double.tryParse(v) ?? 0;
  }

  int _toInt(Object? s) => _toDouble(s).toInt();

  bool _isArabicText(String? text) {
    final value = text?.trim() ?? '';
    if (value.isEmpty) return false;
    return RegExp(r'[\u0600-\u06FF]').hasMatch(value);
  }

  String _getDisplayItemName(Item item) {
    final name = item.name?.toString().trim() ?? '';
    final productName = item.productName?.toString().trim() ?? '';

    if (name.isNotEmpty && _isArabicText(name)) {
      return productName.isNotEmpty ? productName : name;
    }

    return name.isNotEmpty ? name : productName;
  }

  bool _hasPriceChange(Item item) {
    final orderPrice = _toDouble(item.price);
    final pickerPrice = _toDouble(item.finalPrice);
    final webPrice = _toDouble(item.webprice);
    bool diffPicker =
        pickerPrice != 0 && (pickerPrice - orderPrice).abs() > 0.0001;
    bool diffWeb = webPrice != 0 && (webPrice - orderPrice).abs() > 0.0001;
    return diffPicker || diffWeb;
  }

  double _couponDiscount() {
    final couponCode = order.couponCode?.toString().trim().toUpperCase();
    if (couponCode == 'FIRST20') return 20.0;
    return _toDouble(order.discountValue ?? 0);
  }

  double _discountValue() {
    final couponCode = order.couponCode?.toString().trim().toUpperCase();
    if (couponCode == 'FIRST20') {
      return 20.0;
    } else {
      return 0.0;
    }
  }

  double _baseGrandTotal() {
    final rawTotal = _toDouble(
      order.endPickedTotal != 0
          ? _toDouble(order.endPickedTotal.toString()) +
              _toDouble(order.shippingCharge.toString())
          : order.grandTotal,
    );
    return rawTotal - _couponDiscount();
  }

  double _dueAmount() {
    final orderAmount = _toDouble(order.orderAmount);
    final endPickedTotal = _toDouble(order.endPickedTotal);
    return endPickedTotal - orderAmount;
  }

  Widget _buildItemRow(Item item, int index) {
    final qty = _toDouble(item.qtyShipped);
    final orderPrice = _toDouble(item.price);
    final pickerPrice = _toDouble(item.finalPrice);
    final webPrice = _toDouble(item.webprice);
    final total =
        (_toDouble(item.finalPrice) != 0 ? pickerPrice : orderPrice) * qty;

    return Container(
      color:
          _hasPriceChange(item)
              ? customColors().warning.withOpacity(0.08)
              : Colors.transparent,
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 40,
            child: Center(
              child: Checkbox(
                value: _selectedItemIds.contains(item.itemId),
                onChanged: (val) {
                  setState(() {
                    if (val == true) {
                      _selectedItemIds.add(item.itemId);
                    } else {
                      _selectedItemIds.remove(item.itemId);
                    }
                  });
                },
              ),
            ),
          ),
          SizedBox(
            width: 44,
            child: Text(
              '${index + 1}',
              style: subtitleStyle(),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 8),

          InkWell(
            onTap: () {
              _openImage(item.imageurl);
            },
            child: Builder(
              builder: (_) {
                final raw = (item.imageurl ?? '').toString().trim();
                final imgUrl = raw.isEmpty ? noimageurl : resolveImageUrl(raw);
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 72,
                    height: 72,
                    child: CachedNetworkImage(
                      imageUrl: imgUrl,
                      fit: BoxFit.cover,
                      placeholder:
                          (context, url) => Center(
                            child: Image.asset(
                              'assets/Iphone_spinner.gif',
                              width: 24,
                              height: 24,
                            ),
                          ),
                      errorWidget:
                          (context, url, error) =>
                              Image.network(noimageurl, fit: BoxFit.cover),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 180,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getDisplayItemName(item),
                  style: customTextStyle(
                    fontStyle: FontStyle.BodyM_Bold,
                    color: FontColor.FontPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(item.sku, style: subtitleStyle()),
                const SizedBox(height: 4),
                Text(item.branchName ?? '', style: subtitleStyle()),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 90,
            child: Text(
              webPrice.toStringAsFixed(2),
              style: subtitleStyle(),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 70,
            child: Text(
              orderPrice.toStringAsFixed(2),
              style: subtitleStyle(),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 110,
            child: Text(
              pickerPrice.toStringAsFixed(2),
              style: subtitleStyle(),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 80,
            child: Text(
              int.parse(item.qtyOrdered.toString()).toString(),
              style: subtitleStyle(),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 80,
            child: Text(
              item.qtyShipped,
              style: subtitleStyle(),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 80,
            child: Text(
              total.toStringAsFixed(2),
              style: subtitleStyle(),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableValue(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              '$label:',
              style: subtitleStyle().copyWith(fontSize: 13),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: subtitleStyle().copyWith(fontSize: 13),
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    String title, {
    Color? backgroundColor,
    Color? borderColor,
    Color? textColor,
  }) {
    final colors = customColors();
    final baseStyle = customTextStyle(fontStyle: FontStyle.BodyL_Bold);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: backgroundColor ?? colors.backgroundPrimary,
        borderRadius: BorderRadius.circular(10),
        border: borderColor != null ? Border.all(color: borderColor) : null,
      ),
      child: Text(
        title,
        style: baseStyle.copyWith(color: textColor ?? baseStyle.color),
      ),
    );
  }

  Widget _buildTableHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 40,
            child: Center(
              child: Text(
                '',
                style: subtitleStyle().copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ),
          SizedBox(
            width: 44,
            child: Center(
              child: Text(
                '#',
                style: subtitleStyle().copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 72,
            child: Center(
              child: Text(
                'Image',
                style: subtitleStyle().copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 180,
            child: Text(
              'Product',
              style: subtitleStyle().copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          // const SizedBox(width: 12),
          // SizedBox(
          //   width: 120,
          //   child: Text(
          //     'SKU',
          //     style: subtitleStyle().copyWith(fontWeight: FontWeight.w600),
          //   ),
          // ),
          // const SizedBox(width: 12),
          // SizedBox(
          //   width: 110,
          //   child: Text(
          //     'Branch',
          //     style: subtitleStyle().copyWith(fontWeight: FontWeight.w600),
          //   ),
          // ),
          const SizedBox(width: 12),
          SizedBox(
            width: 90,
            child: Text(
              'Web.Price',
              style: subtitleStyle().copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 70,
            child: Text(
              'Price',
              style: subtitleStyle().copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 110,
            child: Text(
              'Picker Price',
              style: subtitleStyle().copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 80,
            child: Text(
              'Qty Order',
              style: subtitleStyle().copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 80,
            child: Text(
              'Qty Shipped',
              style: subtitleStyle().copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 80,
            child: Text(
              'Total',
              style: subtitleStyle().copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    order = widget.arguments['order'] as Datum;
    _loadExistingPosBillIfAny();
    _maybeFetchSadad();
    _maybeTranslateNote();

    // _grandTotalController.text = _baseGrandTotal().toStringAsFixed(2);
    _grandTotalOverride = null;

    final initialTotal =
        order.posAmount != null &&
                order.posAmount != '0.0' &&
                order.posAmount != "" &&
                order.subgroupIdentifier.startsWith("EXP")
            ? _toDouble(order.posAmount!.toString())
            : _toDouble(
              order.endPickedTotal != 0
                  ? _toDouble(order.endPickedTotal.toString()) +
                      (order.combinedOrderPlacedTotal! > 99
                          ? 0
                          : _toDouble(order.shippingCharge.toString()))
                  : order.grandTotal,
            );
    _editableGrandTotal = initialTotal - _discountValue();
  }

  @override
  void dispose() {
    // _grandTotalController.dispose();
    super.dispose();
  }

  Widget _kv(String label, String value, {TextStyle? valueStyle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(child: Text(label, style: subtitleStyle())),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: valueStyle ?? subtitleStyle(),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  // More readable labeled row with selectable value
  Widget _kvSelectable(String label, String value, {TextStyle? valueStyle}) {
    final labelStyle = customTextStyle(
      fontStyle: FontStyle.BodyM_SemiBold,
      color: FontColor.FontPrimary,
    ).copyWith(fontSize: 16, height: 1.3);
    final defaultStyle = customTextStyle(
      fontStyle: FontStyle.BodyM_Regular,
      color: FontColor.FontPrimary,
    ).copyWith(fontSize: 16, height: 1.4);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 140, child: Text(label, style: labelStyle)),
          const SizedBox(width: 8),
          Expanded(
            child: SelectableText(
              value.isEmpty ? '-' : value,
              style: valueStyle ?? defaultStyle,
            ),
          ),
        ],
      ),
    );
  }

  // Money formatter and row for Price Details
  String _fmtQar(num v) {
    try {
      // Use a simple consistent QAR format
      return 'QAR ' + (v.toDouble()).toStringAsFixed(2);
    } catch (_) {
      return 'QAR 0.00';
    }
  }

  Widget _kvMoney(
    String label,
    num value, {
    bool bold = false,
    TextStyle? labelStyle,
    TextStyle? valueStyle,
  }) {
    final defaultLabelStyle = customTextStyle(
      fontStyle: bold ? FontStyle.BodyM_Bold : FontStyle.BodyM_SemiBold,
      color: FontColor.FontPrimary,
    ).copyWith(fontSize: 16, height: 1.3);
    final defaultValueStyle = customTextStyle(
      fontStyle: bold ? FontStyle.BodyL_Bold : FontStyle.BodyM_Regular,
      color: FontColor.FontPrimary,
    ).copyWith(fontSize: bold ? 18 : 16, height: 1.4);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(label, style: labelStyle ?? defaultLabelStyle)),
          const SizedBox(width: 12),
          Text(
            _fmtQar(value),
            style: valueStyle ?? defaultValueStyle,
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }

  Widget _editableKvMoney(
    String label,
    double value, {
    required Function(double) onChanged,
    bool bold = false,
  }) {
    final labelStyle = customTextStyle(
      fontStyle: bold ? FontStyle.BodyM_Bold : FontStyle.BodyM_SemiBold,
      color: FontColor.FontPrimary,
    ).copyWith(fontSize: 16, height: 1.3);

    final valueStyle = customTextStyle(
      fontStyle: bold ? FontStyle.BodyL_Bold : FontStyle.BodyM_Regular,
      color: FontColor.FontPrimary,
    ).copyWith(fontSize: bold ? 18 : 16, height: 1.4);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(label, style: labelStyle)),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              initialValue: _fmtQar(value),
              // readOnly: !order.subgroupIdentifier.startsWith("EXP"),
              style: valueStyle,
              textAlign: TextAlign.right,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  vertical: 4,
                  horizontal: 8,
                ),
                isDense: true,
              ),
              onChanged: (value) {
                final numericValue =
                    double.tryParse(value.replaceAll(RegExp(r'[^0-9.]'), '')) ??
                    0.0;
                onChanged(numericValue);
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openUploadPosBillSheet() async {
    final colors = customColors();
    _posSheetOpen = true;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: customColors().backgroundPrimary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 12,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              Text('Upload POS Bill', style: titleStyle()),
              const SizedBox(height: 8),
              Text(
                'Attach a clear photo or file of the POS bill before marking the order ready to dispatch.',
                style: subtitleStyle(),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed:
                          _uploading
                              ? null
                              : () async {
                                final picker = ImagePicker();
                                final img = await picker.pickImage(
                                  source: ImageSource.camera,
                                  imageQuality: 80, // initial downsampling
                                  maxWidth: 1600,
                                  maxHeight: 1600,
                                );
                                if (img != null) {
                                  setState(() => _pickedImage = img);
                                  await _uploadPickedImage();
                                }
                              },
                      icon: const Icon(Icons.photo_camera_outlined),
                      label: const Text('Camera'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed:
                          _uploading
                              ? null
                              : () async {
                                final result = await FilePicker.platform
                                    .pickFiles(
                                      type: FileType.image,
                                      allowMultiple: false,
                                    );
                                if (result != null &&
                                    result.files.single.path != null) {
                                  final path = result.files.single.path!;
                                  setState(() => _pickedImage = XFile(path));
                                  await _uploadPickedImage();
                                }
                              },
                      icon: const Icon(Icons.upload_file_outlined),
                      label: const Text('Browse'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed:
                      _uploading
                          ? null
                          : () async {
                            await _addPendingBill(order.subgroupIdentifier);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Marked to upload bill later'),
                                ),
                              );
                              // Proceed to mark as Ready to Dispatch flow
                              await _confirmAndMarkReady(forceLater: true);
                            }
                          },
                  icon: const Icon(Icons.schedule),
                  label: const Text('Upload later'),
                ),
              ),
              const SizedBox(height: 12),
              if (_uploading)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    children: [
                      LinearProgressIndicator(
                        minHeight: 4,
                        value:
                            (_uploadProgress != null && _uploadProgress! > 0)
                                ? _uploadProgress!.clamp(0.0, 1.0)
                                : null, // null -> indeterminate
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _uploadProgress == null
                            ? 'Uploading...'
                            : 'Uploading ${((_uploadProgress! * 100).toStringAsFixed(0))}%',
                        style: subtitleStyle(),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Time left: ${_secondsLeft > 0 ? _secondsLeft : 0}s',
                        style: subtitleStyle(),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: _cancelCurrentUploadAndCloseDialog,
                        icon: const Icon(Icons.close),
                        label: const Text('Cancel upload'),
                      ),
                    ],
                  ),
                ),
              if (_posBillUrl != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text('Bill uploaded', style: subtitleStyle()),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    ).whenComplete(() {
      // Sheet closed
      _posSheetOpen = false;
    });
  }

  Future<void> _uploadPickedImage() async {
    if (_pickedImage == null) return;
    setState(() {
      _uploading = true;
      _uploadProgress = 0.0;
      _secondsLeft = _uploadTimeoutSeconds;
    });

    // Show a modal progress dialog so the user clearly sees uploading state
    _cancelRequested = false;
    _uploadDialogOpen = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return WillPopScope(
          onWillPop: () async => false,
          child: Dialog(
            backgroundColor: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Uploading POS bill...', style: titleStyle()),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    minHeight: 6,
                    value:
                        (_uploadProgress != null && _uploadProgress! > 0)
                            ? _uploadProgress!.clamp(0.0, 1.0)
                            : null,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _uploadProgress == null
                        ? 'Starting...'
                        : '${(_uploadProgress! * 100).toStringAsFixed(0)}%',
                    style: subtitleStyle(),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Time left: ${_secondsLeft > 0 ? _secondsLeft : 0}s',
                    style: subtitleStyle(),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: _cancelCurrentUploadAndCloseDialog,
                      icon: const Icon(Icons.close),
                      label: const Text('Cancel'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ).then((_) {
      _uploadDialogOpen = false;
    });

    try {
      // final file = await _compressImageIfNeeded(_pickedImage!);
      // if (_cancelRequested) {
      //   throw FirebaseException(plugin: 'firebase_storage', code: 'canceled');
      // }
      // final ts = DateTime.now().millisecondsSinceEpoch;
      // final ref = FirebaseStorage.instance.ref().child(
      //   'pos_bills/${order.subgroupIdentifier}/bill_${order.subgroupIdentifier}.jpg',
      // );

      // final uploadTask = ref.putFile(
      //   file,
      //   SettableMetadata(contentType: 'image/jpeg'),
      // );
      // _currentUploadTask = uploadTask;

      // // Start countdown timer; auto-cancel when time is up
      // _uploadTimer?.cancel();
      // _uploadTimer = Timer.periodic(const Duration(seconds: 1), (t) async {
      //   if (!mounted) return;
      //   setState(
      //     () =>
      //         _secondsLeft = (_secondsLeft - 1).clamp(0, _uploadTimeoutSeconds),
      //   );
      //   if (_secondsLeft <= 0) {
      //     await _currentUploadTask?.cancel();
      //     t.cancel();
      //   }
      // });

      // uploadTask.snapshotEvents.listen((snapshot) {
      //   if (snapshot.totalBytes > 0) {
      //     final p = snapshot.bytesTransferred / snapshot.totalBytes;
      //     if (mounted) {
      //       setState(() => _uploadProgress = p);
      //     }
      //   }
      // });

      // // Enforce a hard timeout on the future as well
      // final taskSnapshot = await uploadTask.timeout(
      //   Duration(seconds: _uploadTimeoutSeconds + 5),
      // );
      // final url = await taskSnapshot.ref.getDownloadURL();

      final file = await _compressImageIfNeeded(_pickedImage!);

      // Start countdown timer (visual only)
      _uploadTimer?.cancel();
      _uploadTimer = Timer.periodic(const Duration(seconds: 1), (t) async {
        if (!mounted) return;
        setState(
          () =>
              _secondsLeft = (_secondsLeft - 1).clamp(0, _uploadTimeoutSeconds),
        );
      });

      // Build multipart request to provided API
      final uri = Uri.parse(
        'https://pickerdriver.testuatah.com/v1/api/qatar/upload-pos-bill.php',
      );
      final request =
          http.MultipartRequest('POST', uri)
            ..fields['order_number'] = order.subgroupIdentifier
            ..files.add(
              await http.MultipartFile.fromPath(
                'bill',
                file.path,
                filename: 'bill_${order.subgroupIdentifier}.jpg',
              ),
            );

      final streamedResponse = await request.send().timeout(
        Duration(seconds: _uploadTimeoutSeconds + 5),
      );

      final respBody = await streamedResponse.stream.bytesToString();
      if (streamedResponse.statusCode == 200) {
        if (mounted) {
          // Try to capture a URL if the API returns one
          String uploadedUrl = 'uploaded';
          try {
            final parsed = jsonDecode(respBody);
            if (parsed is Map && parsed['url'] != null) {
              uploadedUrl = parsed['url'].toString();
            } else if (parsed is String && parsed.startsWith('http')) {
              uploadedUrl = parsed;
            }
          } catch (_) {}

          setState(() => _posBillUrl = uploadedUrl);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('POS bill uploaded successfully')),
          );
          await _removePendingBill(order.subgroupIdentifier);
        }

        if (_posSheetOpen) {
          Navigator.of(context).pop();
          _posSheetOpen = false;
        }
      } else {
        throw Exception(
          'Server responded ${streamedResponse.statusCode}: $respBody',
        );
      }
    } catch (e) {
      final msg =
          e is TimeoutException
              ? 'Upload timed out. Please try again.'
              : 'Upload failed: $e';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } finally {
      if (mounted) {
        setState(() {
          _uploading = false;
          _uploadProgress = null;
        });
      }
      _uploadTimer?.cancel();
      _uploadTimer = null;
      _currentUploadTask = null;
      // Close the modal progress dialog if still open
      if (_uploadDialogOpen) {
        _uploadDialogOpen = false;
        Navigator.of(context, rootNavigator: true).maybePop();
      }
    }
  }

  // Compress picked image if it's large; always convert to JPEG to ensure small, fast uploads
  Future<File> _compressImageIfNeeded(XFile xfile) async {
    try {
      final original = File(xfile.path);
      final originalBytes = await original.length();

      // If already reasonably small (< 300 KB), skip compression
      if (originalBytes < 300 * 1024) return original;

      final tmpDir = await getTemporaryDirectory();
      final outPath =
          '${tmpDir.path}/posbill_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final compressed = await FlutterImageCompress.compressAndGetFile(
        original.absolute.path,
        outPath,
        quality: 65,
        minWidth: 1280,
        minHeight: 1280,
        format: CompressFormat.jpeg,
      );

      if (compressed != null) {
        return File(compressed.path);
      }
      return original; // fallback
    } catch (_) {
      return File(xfile.path); // fallback on any error
    }
  }

  static const int _uploadTimeoutSeconds = 90; // configurable timeout
  int _secondsLeft = 0;
  Timer? _uploadTimer;
  UploadTask? _currentUploadTask;
  bool _uploadDialogOpen = false;
  bool _cancelRequested = false;
  bool _posSheetOpen = false;

  Future<void> _loadExistingPosBillIfAny() async {
    try {
      final orderNo = order.subgroupIdentifier;
      final uri = Uri.parse(
        'https://pickerdriver.testuatah.com/v1/api/qatar/get_bill_data.php?order_number='
        '${Uri.encodeQueryComponent(orderNo)}',
      );

      final resp = await http.get(uri).timeout(const Duration(seconds: 20));
      if (resp.statusCode != 200) return;

      final data = jsonDecode(resp.body);
      bool exists = false;
      String? url;

      if (data is Map<String, dynamic>) {
        final bill = data['bill'];
        exists =
            (data['success'] == true) &&
            (bill is Map && (bill['exists'] == true));
        if (bill is Map && bill['url'] != null) {
          url = bill['url'].toString();
        }
      }

      if (!mounted) return;
      setState(() {
        _posBillUrl = (exists && url != null && url!.isNotEmpty) ? url : null;
      });
    } catch (_) {
      // keep silent on load errors
    }
  }

  // Trigger Sadad check only when payment method matches
  Future<void> _maybeFetchSadad() async {
    try {
      final pm = (order.paymentMethod ?? '').trim().toLowerCase();
      if (pm == 'tns_hosted') {
        await _fetchSadadTransactions(
          _sanitizeWebsiteRef(order.subgroupIdentifier),
        );
      } else {
        if (mounted) {
          setState(() {
            _sadadTxns = const [];
            _sadadError = null;
            _sadadLoading = false;
          });
        }
      }
    } catch (_) {}
  }

  // Call Sadad QA APIs: login to retrieve token, then query transactions by website_ref_no
  // Call Mastercard API to check online payment status for this suborder
  Future<void> _fetchSadadTransactions(String orderId) async {
    setState(() {
      _sadadLoading = true;
      _sadadError = null;
      _sadadTxns = const [];
    });

    try {
      // Build Basic Auth header: "Basic base64(username:password)"
      // TODO: move credentials to secure storage / config in real app
      const username = 'merchant.520000339';
      const password = '36c973377a7b4b456914c1edd1fdd24c';
      final basicAuth =
          'Basic ' + base64Encode(utf8.encode('$username:$password'));

      final uri = Uri.parse(
        'https://cbq.gateway.mastercard.com/api/rest/version/100/merchant/520000339/order/$orderId',
      );

      final resp = await http.get(
        uri,
        headers: {
          'Authorization': basicAuth,
          'Content-Type': 'application/json',
        },
      );

      if (resp.statusCode != 200) {
        throw Exception('Mastercard order lookup failed (${resp.statusCode})');
      }

      final json = jsonDecode(resp.body) as Map<String, dynamic>;

      // Adapt response -> our generic _sadadTxns format
      // Adjust these keys based on the exact JSON you get back.
      final amount =
          (json['amount'] ?? json['order']['amount'] ?? '0').toString();

      final authStatus = (json['status'])?.toString() ?? '';

      final isSuccess = authStatus.toUpperCase().contains('CAPTURED');

      final List<Map<String, dynamic>> items = [
        {
          'amount': amount,
          // Keep using statusId == 3 as "Online Paid" to match existing UI
          'statusId': getstat(authStatus),
          'modeName': authStatus,
          'invoice': orderId,
        },
      ];

      if (mounted) {
        setState(() {
          _sadadTxns = items;
          _sadadLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _sadadError = 'Online payment error: $e';
          _sadadLoading = false;
        });
      }
    }
  }

  int getstat(String authstat) {
    switch (authstat) {
      case 'CAPTURED':
        return 3;
      case 'REFUNDED':
        return 2;
      case 'AUTHENTICATED':
        return 1;
      default:
        return 0;
    }
  }

  Color getstatcolor(String authstat) {
    switch (authstat) {
      case 'CAPTURED':
        return customColors().secretGarden;
      case 'REFUNDED':
        return customColors().islandAqua;
      case 'AUTHENTICATED':
        return customColors().carnationRed;
      default:
        return customColors().warning;
    }
  }

  String getaction(int id) {
    switch (id) {
      case 3:
        return "(Online Paid)";
      case 2:
        return "(Refunded)";
      case 1:
        return "(Failed)";
      default:
        return "Fialed";
    }
  }

  // Helper: Remove leading prefixes from subgroup identifier
  String _sanitizeWebsiteRef(String s) {
    // Removes one or more leading occurrences of any of: EXP-, NOL-, SUP-, WAR-, VPO-, ABY- (case-insensitive)
    final pattern = RegExp(
      r'^(?:EXP-|NOL-|SUP-|WAR-|VPO-|ABY-)+',
      caseSensitive: false,
    );
    return s.replaceFirst(pattern, '');
  }

  static const String _pendingBillKey = 'cashier_upload_later_orders';

  Future<List<Map<String, dynamic>>> _getPendingBills() async {
    try {
      final list = await PreferenceUtils.getstoremap(_pendingBillKey);
      return list.cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  Future<void> _addPendingBill(String id) async {
    final list = await _getPendingBills();
    if (!list.any((e) => (e['id'] ?? '') == id)) {
      list.add({'id': id, 'ts': DateTime.now().millisecondsSinceEpoch});
      await PreferenceUtils.storeListmap(
        _pendingBillKey,
        list.map((e) => e.cast<String, dynamic>()).toList(),
      );
    }
  }

  Future<void> _removePendingBill(String id) async {
    final list = await _getPendingBills();
    list.removeWhere((e) => (e['id'] ?? '') == id);
    await PreferenceUtils.storeListmap(
      _pendingBillKey,
      list.map((e) => e.cast<String, dynamic>()).toList(),
    );
  }

  Future<void> _openImage(String? imageUrl) async {
    final raw = (imageUrl ?? '').toString().trim();
    final url = raw.isEmpty ? noimageurl : resolveImageUrl(raw);

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return Dialog(
          insetPadding: const EdgeInsets.all(16),
          backgroundColor: Colors.black.withOpacity(0.95),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                Positioned.fill(
                  child: InteractiveViewer(
                    panEnabled: true,
                    minScale: 0.8,
                    maxScale: 4,
                    child: Center(
                      child: CachedNetworkImage(
                        imageUrl: url,
                        fit: BoxFit.contain,
                        placeholder:
                            (context, _) => Center(
                              child: Image.asset(
                                'assets/Iphone_spinner.gif',
                                width: 36,
                                height: 36,
                              ),
                            ),
                        errorWidget:
                            (context, _, __) =>
                                Image.network(noimageurl, fit: BoxFit.contain),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Header with three columns similar to the screenshot: Shipping | Payment Method | Shipping Method
  Widget _buildOrderSummaryHeader() {
    final colors = customColors();
    final addressLines = [
      'Name: ${[order.firstname, order.lastname].where((e) => (e ?? '').toString().trim().isNotEmpty).join(' ')}',
      if ((order.company ?? '').toString().trim().isNotEmpty)
        'Company: ${order.company}',
      if (order.street.toString().trim().isNotEmpty) 'Street: ${order.street}',
      if ((order.city ?? '').toString().trim().isNotEmpty)
        'City: ${order.city}',
      if ((order.region ?? '').toString().trim().isNotEmpty)
        'Area: ${order.region}',
      if ((order.postcode).toString().trim().isNotEmpty)
        'Zone: ${order.postcode}',
      if ((order.telephone).toString().trim().isNotEmpty)
        'Phone: ${order.telephone}',
    ];

    final paymentLabel =
        (() {
          final prep = getPaymentMethod(order.paymentMethod?.trim() ?? '');
          if (prep.isNotEmpty) return prep;
          return 'Cash On Delivery';
        })();

    final shippingLabel = (order.shipmentLabel).toString().trim();
    final shippingCharge = _toDouble(order.shippingCharge);

    return Card(
      color: colors.backgroundSecondary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: colors.primary),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      color: colors.backgroundPrimary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      child: Text('Shipping', style: titleStyle()),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        addressLines.join('\n'),
                        style: subtitleStyle(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: colors.primary),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      color: colors.backgroundPrimary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      child: Text('Payment Method', style: titleStyle()),
                    ),

                    // Padding(
                    //   padding: const EdgeInsets.all(8.0),
                    //   child: Text(paymentLabel, style: _subtitleStyle()),
                    // ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(paymentLabel, style: subtitleStyle()),
                          const SizedBox(height: 6),

                          if ((order.paymentMethod ?? '')
                                  .trim()
                                  .toLowerCase() ==
                              'tns_hosted') ...[
                            if (_sadadLoading)
                              Row(
                                children: const [
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text('Checking online payment...'),
                                ],
                              )
                            else if (_sadadError != null)
                              Text(
                                _sadadError!,
                                style: subtitleStyle().copyWith(
                                  color: Colors.red,
                                ),
                              )
                            else if (_sadadTxns.isEmpty)
                              Text(
                                '- No online transactions found -',
                                style: subtitleStyle(),
                              )
                            else ...[
                              for (final t in _sadadTxns) ...[
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: colors.backgroundPrimary,
                                    border: Border.all(
                                      color: colors.primary.withOpacity(0.3),
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: getstatcolor(t['modeName']),
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                        child: Text(
                                          'QAR ${t['amount']} ' +
                                              getaction(t['statusId']),
                                          style: customTextStyle(
                                            fontStyle: FontStyle.BodyS_Bold,
                                            color: FontColor.White,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        '${t['modeName'] ?? '-'}',
                                        style: subtitleStyle(),
                                      ),
                                      if ((t['invoice'] ?? '')
                                          .toString()
                                          .isNotEmpty) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          '${t['invoice']}',
                                          style: subtitleStyle(),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ] else ...[
                            Row(
                              children: [
                                Text('Change:', style: subtitleStyle()),
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colors.backgroundPrimary,
                                    border: Border.all(
                                      color: colors.primary.withOpacity(0.3),
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: DropdownButton<String>(
                                    underline: const SizedBox(),
                                    value: order.paymentMethod,
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'cashondelivery',
                                        child: Text('Cash on Delivery'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'banktransfer',
                                        child: Text('Card on Delivery'),
                                      ),
                                    ],
                                    onChanged: (val) {
                                      if (val != null) _setPaymentMethod(val);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: colors.primary),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      color: colors.backgroundPrimary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      child: Text('Shipping Method', style: titleStyle()),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            shippingLabel.isEmpty ? '-' : shippingLabel,
                            style: subtitleStyle(),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Delivery Charges: ' +
                                (shippingCharge == 0
                                    ? 'Free Shipping'
                                    : shippingCharge.toStringAsFixed(2)),
                            style: subtitleStyle(),
                          ),
                          Text(
                            '(Total Shipping Charges QAR ${shippingCharge.toStringAsFixed(2)})',
                            style: subtitleStyle(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build a table layout for items with category grouping.
  Widget _buildItemsTableSection() {
    final colors = customColors();

    final filtered =
        order.items.where((i) {
          final s = (i.itemStatus).toString().toLowerCase();
          return s != 'item_not_available' &&
              s != 'canceled' &&
              s != 'cancelled';
        }).toList();

    if (filtered.isEmpty) {
      return Card(
        margin: EdgeInsets.zero,
        color: colors.backgroundSecondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(child: Text('-', style: subtitleStyle())),
        ),
      );
    }

    final priceChangedItems = filtered.where(_hasPriceChange).toList();
    final noPriceChangeItems =
        filtered.where((item) => !_hasPriceChange(item)).toList();

    Map<String, List<Item>> _groupByCategory(List<Item> list) {
      final map = <String, List<Item>>{};
      for (final item in list) {
        final category = (item.categoryName ?? '').trim();
        final key = category.isNotEmpty ? category : 'Uncategorized';
        map.putIfAbsent(key, () => []).add(item);
      }
      return map;
    }

    final priceChangedGroups = _groupByCategory(priceChangedItems);
    final noPriceChangeGroups = _groupByCategory(noPriceChangeItems);

    Widget _tableCell(
      String text, {
      TextStyle? style,
      Alignment alignment = Alignment.centerLeft,
    }) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        alignment: alignment,
        child: Text(
          text,
          style: style ?? subtitleStyle().copyWith(fontSize: 13),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      );
    }

    TableRow _buildHeaderRow() {
      final headerStyle = subtitleStyle().copyWith(
        fontWeight: FontWeight.w700,
        fontSize: 13,
      );
      return TableRow(
        decoration: BoxDecoration(color: colors.backgroundPrimary),
        children:
            [
              _tableCell('', alignment: Alignment.center),
              _tableCell('#', alignment: Alignment.center),
              _tableCell('Product'),
              _tableCell('Branch'),
              _tableCell('Web.Price', alignment: Alignment.centerRight),
              _tableCell('Price', alignment: Alignment.centerRight),
              _tableCell('Picker Price', alignment: Alignment.centerRight),
              _tableCell('Qty Order', alignment: Alignment.centerRight),
              _tableCell('Qty Shipped', alignment: Alignment.centerRight),
              _tableCell('Total', alignment: Alignment.centerRight),
            ].map((cell) {
              return Container(
                decoration: const BoxDecoration(),
                child: DefaultTextStyle.merge(style: headerStyle, child: cell),
              );
            }).toList(),
      );
    }

    TableRow _buildItemRow(Item item, int index) {
      final orderPrice = _toDouble(item.price);
      final pickerPrice = _toDouble(item.finalPrice);
      final webPrice = _toDouble(item.webprice);
      final qtyOrder = item.qtyOrdered.isNotEmpty ? item.qtyOrdered : '0';
      final qtyShipped = item.qtyShipped.isNotEmpty ? item.qtyShipped : '0';
      final total = ((pickerPrice != 0 ? pickerPrice : orderPrice) *
              _toDouble(item.qtyShipped))
          .toStringAsFixed(2);

      return TableRow(
        decoration: BoxDecoration(
          color:
              _hasPriceChange(item)
                  ? customColors().carnationRed.withOpacity(0.08)
                  : customColors().success.withOpacity(0.06),
        ),
        children: [
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Checkbox(
              value: _selectedItemIds.contains(item.itemId),
              onChanged: (val) {
                setState(() {
                  if (val == true) {
                    _selectedItemIds.add(item.itemId);
                  } else {
                    _selectedItemIds.remove(item.itemId);
                  }
                });
              },
            ),
          ),
          _tableCell('${index + 1}', alignment: Alignment.center),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () => _openImage(item.imageurl),
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: colors.backgroundTertiary,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: CachedNetworkImage(
                      imageUrl:
                          (item.imageurl ?? '').toString().isEmpty
                              ? noimageurl
                              : resolveImageUrl(item.imageurl ?? ''),
                      fit: BoxFit.cover,
                      placeholder:
                          (context, url) => Center(
                            child: Image.asset(
                              'assets/Iphone_spinner.gif',
                              width: 24,
                              height: 24,
                            ),
                          ),
                      errorWidget:
                          (context, url, error) =>
                              Image.network(noimageurl, fit: BoxFit.cover),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _getDisplayItemName(item),
                        style: subtitleStyle().copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if ((item.sku ?? '').isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          item.sku,
                          style: subtitleStyle().copyWith(
                            fontSize: 12,
                            color: customColors().fontTertiary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          _tableCell(item.branchName ?? ''),
          _tableCell(
            webPrice.toStringAsFixed(2),
            alignment: Alignment.centerRight,
          ),
          _tableCell(
            orderPrice.toStringAsFixed(2),
            alignment: Alignment.centerRight,
          ),
          _tableCell(
            pickerPrice.toStringAsFixed(2),
            alignment: Alignment.centerRight,
          ),
          _tableCell(
            double.parse(qtyOrder.toString()).toInt().toString(),
            alignment: Alignment.centerRight,
          ),
          _tableCell(
            double.parse(qtyShipped.toString()).toInt().toString(),
            alignment: Alignment.centerRight,
          ),
          _tableCell(total, alignment: Alignment.centerRight),
        ],
      );
    }

    Widget _buildSection(String sectionTitle, Map<String, List<Item>> groups) {
      final List<Widget> widgets = [];
      // choose a heading text color: red for price-changed, green for no-change
      Color? headingTextColor;
      final lower = sectionTitle.toLowerCase();
      if (lower.contains('price')) {
        headingTextColor = colors.carnationRed;
      } else if (lower.contains('without')) {
        headingTextColor = colors.success;
      }

      widgets.add(
        _buildSectionHeader(
          sectionTitle,
          backgroundColor: colors.backgroundPrimary,
          borderColor: colors.backgroundTertiary,
          textColor: headingTextColor,
        ),
      );
      widgets.add(const SizedBox(height: 12));

      for (final entry in groups.entries) {
        final categoryName = entry.key;
        final items = entry.value;

        widgets.add(
          _buildSectionHeader(
            categoryName,
            backgroundColor: HexColor('#FCFCFC'),
            borderColor: HexColor('#D1D1D1'),
          ),
        );
        widgets.add(const SizedBox(height: 12));

        widgets.add(
          Table(
            border: TableBorder.all(color: colors.backgroundTertiary),
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            columnWidths: const {
              0: FixedColumnWidth(40),
              1: FixedColumnWidth(30),
              2: FixedColumnWidth(290),
              3: FixedColumnWidth(140),
              4: FixedColumnWidth(130),
              5: FixedColumnWidth(140),
              6: FixedColumnWidth(110),
              7: FixedColumnWidth(100),
              8: FixedColumnWidth(100),
              9: FixedColumnWidth(120),
            },
            children: [
              _buildHeaderRow(),
              ...List.generate(
                items.length,
                (index) => _buildItemRow(items[index], index),
              ),
            ],
          ),
        );

        widgets.add(const SizedBox(height: 24));
      }

      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: colors.backgroundTertiary),
          borderRadius: BorderRadius.circular(12),
          color: colors.backgroundPrimary,
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: widgets,
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Card(
          margin: EdgeInsets.zero,
          color: colors.backgroundSecondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (priceChangedGroups.isNotEmpty) ...[
                      _buildSection('Price Changed Items', priceChangedGroups),
                      const SizedBox(height: 24),
                    ],
                    if (noPriceChangeGroups.isNotEmpty) ...[
                      _buildSection(
                        'Items Without Price Change',
                        noPriceChangeGroups,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _maybeTranslateNote() async {
    final note = order.deliveryNote ?? '';
    if (note.isEmpty) return;

    // Simple check for Arabic characters in the note
    final hasArabic = RegExp(r'[\u0600-\u06FF]').hasMatch(note);
    if (!hasArabic) return;

    setState(() {
      _isTranslating = true;
    });

    final translator = OnDeviceTranslator(
      sourceLanguage: TranslateLanguage.arabic,
      targetLanguage: TranslateLanguage.english,
    );

    try {
      final translatedText = await translator.translateText(note);
      if (!mounted || order.deliveryNote != note) return;
      setState(() {
        _translatedNote = translatedText;
        _isTranslating = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isTranslating = false;
      });
    } finally {
      await translator.close();
    }
  }

  Future<void> _confirmAndMarkReady({
    bool forceLater = false,
    String status = 'ready_to_dispatch',
  }) async {
    final colors = customColors();

    // Require selection of dispatch type before proceeding
    if (dispatchMethod == null || dispatchMethod!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select dispatch type (Normal / Driver / Rider)',
          ),
        ),
      );
      return;
    }

    log(dispatchMethod.toString());
    // If POS bill missing, offer Upload Now / Upload Later
    if (_posBillUrl == null && !forceLater) {
      final choice = await showDialog<String>(
        context: context,
        builder:
            (ctx) => AlertDialog(
              title: const Text('POS Bill'),
              content: const Text(
                'No POS bill attached. Would you like to upload it now or upload later? You can still mark the order Ready to Dispatch.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop('cancel'),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop('later'),
                  child: const Text('Upload Later'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop('now'),
                  child: const Text('Upload Now'),
                ),
              ],
            ),
      );

      if (choice == 'now') {
        await _openUploadPosBillSheet();
        if (_posBillUrl == null) {
          // user cancelled upload; stop here
          return;
        }
        // continue to confirm block below with bill present
      } else if (choice == 'later') {
        await _addPendingBill(order.subgroupIdentifier);
        // proceed to mark ready with a note
      } else {
        // cancel
        return;
      }
    }

    // If forceLater is true and no POS bill, ensure it's recorded as pending
    if (forceLater && _posBillUrl == null) {
      await _addPendingBill(order.subgroupIdentifier);
    }

    // Check if this is a club order and ask for club confirmation
    final isClubOrder =
        order.combinedSubgroupIdentifiers
            .where((id) => id != order.subgroupIdentifier)
            .isNotEmpty;

    if (isClubOrder) {
      final clubChoice = await showDialog<String>(
        context: context,
        builder:
            (ctx) => AlertDialog(
              title: const Text('Club Order'),
              content: const Text(
                'This is a club order. Do you want to process it as a club order or mark as ready to dispatch?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop('cancel'),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop('club'),
                  child: const Text('Process as Club'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop('dispatch'),
                  child: const Text('Ready to Dispatch'),
                ),
              ],
            ),
      );

      if (clubChoice == 'cancel') {
        return;
      } else if (clubChoice == 'club') {
        // Process as club order - you can add club-specific logic here
        setState(() {
          _isClubEnabled = true;
        });
        // For now, proceed with normal flow but with club enabled
      }
      // If 'dispatch', continue with normal flow
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirm'),
            content: Text(
              _posBillUrl == null
                  ? 'Mark this order as Ready to Dispatch without a POS bill? You selected Upload Later.'
                  : 'Mark this order as Ready to Dispatch? POS bill will be attached.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(backgroundColor: colors.accent),
                child: const Text('Yes, Mark Ready'),
              ),
            ],
          ),
    );
    if (confirm != true) return;

    setState(() => _submitting = true);
    try {
      final name = UserController().profile.name.toString();
      final empId = UserController().profile.empId;
      final userId = UserController().profile.id.toString();
      final lat = UserController.userController.locationlatitude;
      final lng = UserController.userController.locationlongitude;

      final grandTotal = _toDouble(_grandTotalOverride ?? _baseGrandTotal());
      final due = _dueAmount();

      final token = await PreferenceUtils.getDataFromShared('usertoken');

      final resp = await context.gTradingApiGateway.updateMainOrderStatCashier(
        orderid: order.subgroupIdentifier,
        // If your backend expects a different keyword, adjust here
        orderstatus: status,
        comment:
            _posBillUrl == null
                ? '$name ($empId) marked ready to dispatch (POS bill pending)'
                : status == 'ready_to_dispatch'
                ? '$name ($empId) marked order ready to dispatch'
                : '$name ($empId) marked order $status',
        userid: userId,
        latitude: lat,
        longitude: lng,
        // grandTotal:
        //     _toDouble(
        //       order.endPickTotal != 0
        //           ? double.parse(order.endPickTotal.toString()) +
        //               (order.combinedOrderPlacedTotal! > 99
        //                   ? 0
        //                   : double.parse(order.shippingCharge.toString()))
        //           : order.grandTotal,
        //     ).toString(),
        grandTotal: _editableGrandTotal.toString(),
        dueAmount: ((due < 0 ? 0 : due).toStringAsFixed(2)),
        dispatchMethod: dispatchMethod,
        paymentMethod: paymentMethodnew ?? order.paymentMethod,
        token1: token!,
        clubvalue: _isClubEnabled ? 1 : 0,
        tripid: order.tracker_id ?? "",
      );

      if (mounted) {
        if (resp != null && resp.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Order marked Ready to Dispatch')),
          );
          // Remove from pending list only if a bill is attached (i.e., uploaded now)
          if (_posBillUrl != null) {
            await _removePendingBill(order.subgroupIdentifier);
          }
          // Go back to Cashier dashboard/orders and refresh list (constructor loads on open)
          final locator = context.read<CubitsLocator>();
          await context.gNavigationService.openCashierDashboardPage(context);
        } else {
          final Map<String, dynamic> data = jsonDecode(resp.body);
          final String message = data['message'] ?? 'Something went wrong';
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed: $message')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _submitWarOrder() async {
    // TODO: Implement WAR order action

    // Require selection of dispatch type before proceeding
    if (dispatchMethod == null || dispatchMethod!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select dispatch type (Normal / Driver / Rider)',
          ),
        ),
      );
      return;
    }

    log(dispatchMethod.toString());

    if (_posBillUrl == null) {
      final choice = await showDialog<String>(
        context: context,
        builder:
            (ctx) => AlertDialog(
              title: const Text('POS Bill'),
              content: const Text(
                'No POS bill attached. Would you like to upload it now or upload later? You can still mark the order Ready to Dispatch.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop('cancel'),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop('later'),
                  child: const Text('Upload Later'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop('now'),
                  child: const Text('Upload Now'),
                ),
              ],
            ),
      );

      if (choice == 'now') {
        await _openUploadPosBillSheet();
        if (_posBillUrl == null) {
          // user cancelled upload; stop here
          return;
        }
        // continue to confirm block below with bill present
      } else if (choice == 'later') {
        await _addPendingBill(order.subgroupIdentifier);
        // proceed to mark ready with a note
      } else {
        // cancel
        return;
      }
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirm'),
            content: Text(
              _posBillUrl == null
                  ? 'Mark this order as Ready to Dispatch without a POS bill? You selected Upload Later.'
                  : 'Mark this order as Ready to Dispatch? POS bill will be attached.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: customColors().accent,
                ),
                child: const Text('Yes, Mark Ready'),
              ),
            ],
          ),
    );
    if (confirm != true) return;

    setState(() => _submitting = true);

    try {
      final name = UserController().profile.name.toString();
      final empId = UserController().profile.empId;
      final userId = UserController.userController.profile.id.toString();
      final lat = UserController.userController.locationlatitude;
      final lng = UserController.userController.locationlongitude;

      final grandTotal = _toDouble(_grandTotalOverride ?? _baseGrandTotal());
      final due = _dueAmount();

      final token = await PreferenceUtils.getDataFromShared('usertoken');

      final resp = await context.gTradingApiGateway.updateMainOrderStatCashier(
        orderid: order.subgroupIdentifier,
        // If your backend expects a different keyword, adjust here
        orderstatus: 'submit_do',
        comment: '$name ($empId) marked order sumitted',
        userid: userId,
        latitude: lat,
        longitude: lng,
        // grandTotal:
        //     _toDouble(
        //       order.endPickTotal != 0
        //           ? double.parse(order.endPickTotal.toString()) +
        //               (order.combinedOrderPlacedTotal! > 99
        //                   ? 0
        //                   : double.parse(order.shippingCharge.toString()))
        //           : order.grandTotal,
        //     ).toString(),
        grandTotal: _editableGrandTotal.toString(),
        dueAmount: ((due < 0 ? 0 : due).toStringAsFixed(2)),
        dispatchMethod: dispatchMethod,
        paymentMethod: paymentMethodnew ?? order.paymentMethod,
        token1: token!,
        clubvalue: _isClubEnabled ? 1 : 0,
        tripid: order.tracker_id ?? "",
      );

      if (mounted) {
        if (resp != null && resp.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Order submitted to DO')),
          );
          // Remove from pending list only if a bill is attached (i.e., uploaded now)

          // Go back to Cashier dashboard/orders and refresh list (constructor loads on open)
          final locator = context.read<CubitsLocator>();
          await context.gNavigationService.openCashierDashboardPage(context);
        } else {
          final Map<String, dynamic> data = jsonDecode(resp.body);
          final String message = data['message'] ?? 'Something went wrong';
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed: $message')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = customColors();
    final String name = [
      order.firstname,
      order.lastname,
    ].where((e) => (e ?? '').toString().trim().isNotEmpty).join(' ');
    final String address = [
      order.street,
      if ((order.city ?? '').isNotEmpty) order.city!,
      if ((order.region ?? '').isNotEmpty) order.region!,
      if ((order.postcode ?? '').isNotEmpty) order.postcode!,
    ].where((e) => (e ?? '').toString().trim().isNotEmpty).join(', ');
    // Delivery date and time range formatting
    final String deliveryDateText = getdateformatted(order.deliveryFrom!);
    final String? timeRangeText =
        (() {
          final tr = (order.timerange ?? '').toString().trim();
          if (tr.isNotEmpty) return tr;
          final from = order.deliveryFrom;
          final to = order.deliveryTo;
          final tf = DateFormat('hh:mm a');
          try {
            if (to != null) {
              final fromStr = tf.format(from!);
              final toStr = tf.format(to);
              if (fromStr != toStr) return '$fromStr - $toStr';
              return fromStr;
            }
            return tf.format(from!);
          } catch (_) {
            return null;
          }
        })();

    final originalNote = (order.deliveryNote ?? '').trim();
    final displayNote =
        _translatedNote?.trim().isNotEmpty == true
            ? _translatedNote!.trim()
            : originalNote;

    final couponCode = order.couponCode?.toString().trim();
    final hasCoupon = couponCode?.isNotEmpty == true;

    return BlocConsumer<CashierOrderInnerPageCubit, CashierOrderInnerPageState>(
      listener: (context, state) {
        if (state is CashierOrderInnerPageStateLoaded) {
          setState(() {
            order = state.response;
            _posBillUrl = null;
            // _grandTotalController.text =
            //     (order.endPickTotal != 0
            //             ? double.parse(order.endPickTotal.toString()) +
            //                 (order.combinedOrderPlacedTotal! > 99
            //                     ? 0
            //                     : double.parse(order.shippingCharge.toString()))
            //             : double.parse(order.grandTotal))
            //         .toString();
            _grandTotalOverride = null;

            _translatedNote = null;
          });

          _maybeFetchSadad();
          _loadExistingPosBillIfAny();
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            elevation: 0,
            backgroundColor: colors.backgroundPrimary,
            title: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('#${order.subgroupIdentifier}', style: titleStyle()),

                  if (order.combinedSubgroupIdentifiers
                      .where((id) => id != order.subgroupIdentifier)
                      .isNotEmpty) ...[
                    const SizedBox(width: 12),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children:
                          order.combinedSubgroupIdentifiers
                              .where((id) => id != order.subgroupIdentifier)
                              .map(
                                (id) => InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: () {
                                    setState(() => _posBillUrl = null);
                                    context
                                        .read<CashierOrderInnerPageCubit>()
                                        .loadBySubgroupId(id);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colors.backgroundSecondary,
                                      border: Border.all(color: colors.primary),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      '#$id',
                                      style: customTextStyle(
                                        fontStyle: FontStyle.BodyS_Bold,
                                        color: FontColor.FontPrimary,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                    ),

                    if (order.combinedSubgroupIdentifiers
                            .where((id) => id != order.subgroupIdentifier)
                            .isNotEmpty &&
                        order.driverType == "shipbee")
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(width: 8),
                            Text(
                              'Club Both Orders',
                              style: customTextStyle(
                                fontStyle: FontStyle.BodyL_Bold,
                                color: FontColor.FontPrimary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Switch(
                              value: _isClubEnabled,
                              onChanged: (value) {
                                setState(() {
                                  _isClubEnabled = value;
                                });
                              },
                              activeColor: customColors().primary,
                            ),
                          ],
                        ),
                      ),

                    // order.driverType != null &&
                    //         (order.driverType == 'rider' ||
                    //             order.driverType == 'rafeeq')
                    //     ? Padding(
                    //       padding: const EdgeInsets.only(left: 8.0),
                    //       child: Container(
                    //         padding: const EdgeInsets.symmetric(
                    //           horizontal: 8,
                    //           vertical: 4,
                    //         ),
                    //         decoration: BoxDecoration(
                    //           color: Colors.purple,
                    //           borderRadius: BorderRadius.circular(4),
                    //         ),
                    //         child: Row(
                    //           children: [
                    //             Image.asset(
                    //               'assets/rafeeq_logo.png',
                    //               width: 24,
                    //               height: 24,
                    //             ),
                    //             const SizedBox(width: 8),
                    //             Text(
                    //               getDriverType(order.driverType!),
                    //               style: customTextStyle(
                    //                 fontStyle: FontStyle.BodyL_SemiBold,
                    //                 color: FontColor.White,
                    //               ),
                    //             ),
                    //           ],
                    //         ),
                    //       ),
                    //     )
                    //     : const SizedBox.shrink(),
                  ],

                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: getDriverTypeWidget(
                      order.driverType!,
                      getDriverType(order.driverType!),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              if (order.orderStatus == 'end_picking' ||
                  order.orderStatus == "assigned_cashier" ||
                  order.orderStatus == "start_punching")
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: dispatchSelector(
                    value: dispatchMethod,
                    postcode: order.postcode,
                    subgroupId: order.subgroupIdentifier,
                    paymentMethod: order.paymentMethod!,
                    onChanged:
                        (value) => setState(() => dispatchMethod = value),
                    type: order.driverType ?? '',
                  ),
                ),
            ],
          ),
          body: BlocBuilder<
            CashierOrderInnerPageCubit,
            CashierOrderInnerPageState
          >(
            builder: (context, state) {
              if (state is CashierOrderInnerPageStateLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is CashierOrderInnerPageStateError) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(state.message, style: subtitleStyle()),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed:
                            () => context
                                .read<CashierOrderInnerPageCubit>()
                                .loadBySubgroupId(order.subgroupIdentifier),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              } else if (state is CashierOrderInnerPageStateLoaded) {
                return LayoutBuilder(
                  builder: (ctx, constraints) {
                    final isTablet = constraints.maxWidth >= 900;
                    // Let the inner page use full available width on larger screens
                    final maxWidth = isTablet ? constraints.maxWidth : 640.0;
                    return Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: maxWidth),
                        child: SizedBox(
                          width: double.infinity,
                          child: SingleChildScrollView(
                            padding: EdgeInsets.only(
                              left: isTablet ? 8 : 16,
                              right: isTablet ? 8 : 16,
                              top: 16,
                              bottom: 16,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Order Barcode
                                Card(
                                  color: colors.backgroundSecondary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Constrain barcode area on tablets to avoid full-width
                                        ConstrainedBox(
                                          constraints: BoxConstraints(
                                            maxWidth:
                                                isTablet
                                                    ? 420
                                                    : MediaQuery.of(
                                                          context,
                                                        ).size.width *
                                                        0.8,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                width: double.infinity,
                                                child: AspectRatio(
                                                  aspectRatio: 3,
                                                  child: BarcodeWidget(
                                                    barcode: Barcode.code128(),
                                                    data:
                                                        order
                                                            .subgroupIdentifier,
                                                    color: colors.fontPrimary,
                                                    drawText: false,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                order.subgroupIdentifier,
                                                style: customTextStyle(
                                                  fontStyle:
                                                      FontStyle.BodyM_Bold,
                                                  color: FontColor.FontPrimary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Spacer(),
                                        // Status chip aligned to the right
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 8,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: getStatusColor(
                                                  order.orderStatus.toString(),
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                              ),
                                              child: Text(
                                                getStatus(
                                                  order.orderStatus.toString(),
                                                ),
                                                style: customTextStyle(
                                                  fontStyle:
                                                      FontStyle.BodyM_Bold,
                                                  color: FontColor.White,
                                                ),
                                              ),
                                            ),
                                            if (order.statusHistory != null &&
                                                DateUtils.isSameDay(
                                                  order
                                                      .statusHistory!
                                                      .createdAt,
                                                  DateTime.now(),
                                                )) ...[
                                              const SizedBox(height: 6),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 6,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color:
                                                      customColors().islandAqua,
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  'Ready to Dispatch',
                                                  style: customTextStyle(
                                                    fontStyle:
                                                        FontStyle.BodyS_Bold,
                                                    color: FontColor.White,
                                                  ),
                                                ),
                                              ),
                                            ],
                                            if (order.isWhatsappOrder == 1) ...[
                                              const SizedBox(height: 6),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 6,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color:
                                                      customColors()
                                                          .secretGarden,
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    const Icon(
                                                      Icons.chat_bubble_outline,
                                                      size: 16,
                                                      color: Colors.white,
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      'WhatsApp Order',
                                                      style: customTextStyle(
                                                        fontStyle:
                                                            FontStyle
                                                                .BodyS_Bold,
                                                        color: FontColor.White,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                            if (order.customer_id == 164509 &&
                                                order.postcode == "50")
                                              const SizedBox(width: 8),
                                            if (order.customer_id == 164509 &&
                                                order.postcode == "50")
                                              Padding(
                                                padding: const EdgeInsets.all(
                                                  8.0,
                                                ),
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                    vertical: 5.0,
                                                    horizontal: 8.0,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                      color:
                                                          customColors().accent,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.all(
                                                          Radius.circular(5.0),
                                                        ),
                                                  ),
                                                  child: Text(
                                                    "Thumama Charity Order",
                                                    style: customTextStyle(
                                                      fontStyle:
                                                          FontStyle.BodyL_Bold,
                                                      color: FontColor.Purple,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                order.cashierName != null &&
                                        order.orderStatus == "start_punching"
                                    ? Padding(
                                      padding: const EdgeInsets.only(
                                        left: 12.0,
                                      ),
                                      child: Text(
                                        "Cashier: ${order.cashierName} started to Punch this order",
                                        style: customTextStyle(
                                          fontStyle: FontStyle.BodyM_Bold,
                                          color: FontColor.CarnationRed,
                                        ),
                                      ),
                                    )
                                    : SizedBox(),

                                // Customer Information
                                Padding(
                                  padding: const EdgeInsets.only(left: 12.0),
                                  child: sectionTitle('Customer'),
                                ),
                                const SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.only(left: 12.0),

                                  child: Card(
                                    color: colors.backgroundSecondary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _kvSelectable('Name', name),
                                          _kvSelectable('Address', address),
                                          _kvSelectable(
                                            'Phone',
                                            (order.telephone).toString(),
                                          ),
                                          _kvSelectable(
                                            'Delivery Date',
                                            deliveryDateText,
                                          ),
                                          if ((timeRangeText ?? '').isNotEmpty)
                                            _kvSelectable(
                                              'Delivery Window',
                                              timeRangeText!,
                                            ),
                                          if ((order.deliveryNote ?? '')
                                              .trim()
                                              .isNotEmpty)
                                            _kvSelectable(
                                              'Delivery Note',
                                              displayNote,
                                              valueStyle: const TextStyle(
                                                color: Colors.red,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),

                                          if ((order.pickername ?? '')
                                              .toString()
                                              .trim()
                                              .isNotEmpty)
                                            _kvSelectable(
                                              'Picked By',
                                              order.pickername!.trim(),
                                            ),
                                          if ((order.drivername ?? '')
                                              .toString()
                                              .trim()
                                              .isNotEmpty)
                                            _kvSelectable(
                                              'Driver Name',
                                              order.drivername!.trim(),
                                            ),
                                          const SizedBox(height: 12),
                                          Container(
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              color: colors.backgroundPrimary,
                                              border: Border.all(
                                                color: colors.primary,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            padding: const EdgeInsets.all(8),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  _posBillUrl == null
                                                      ? Icons
                                                          .receipt_long_outlined
                                                      : Icons.receipt_long,
                                                  color:
                                                      _posBillUrl == null
                                                          ? colors.fontSecondary
                                                          : Colors.green,
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    _posBillUrl == null
                                                        ? 'POS bill not uploaded'
                                                        : 'POS bill attached',
                                                    style: subtitleStyle(),
                                                  ),
                                                ),
                                                if (_posBillUrl != null) ...[
                                                  const SizedBox(width: 8),
                                                  GestureDetector(
                                                    onTap:
                                                        () => _openImage(
                                                          _posBillUrl,
                                                        ),
                                                    child: SizedBox(
                                                      width: 80,
                                                      height: 80,
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              6,
                                                            ),
                                                        child: CachedNetworkImage(
                                                          imageUrl:
                                                              _posBillUrl!,
                                                          fit: BoxFit.cover,
                                                          placeholder:
                                                              (
                                                                context,
                                                                _,
                                                              ) => const Center(
                                                                child: SizedBox(
                                                                  width: 16,
                                                                  height: 16,
                                                                  child: CircularProgressIndicator(
                                                                    strokeWidth:
                                                                        2,
                                                                  ),
                                                                ),
                                                              ),
                                                          errorWidget:
                                                              (
                                                                context,
                                                                _,
                                                                __,
                                                              ) => Image.network(
                                                                noimageurl,
                                                                fit:
                                                                    BoxFit
                                                                        .cover,
                                                              ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                                TextButton(
                                                  onPressed:
                                                      _uploading
                                                          ? null
                                                          : _openUploadPosBillSheet,
                                                  child: Text(
                                                    _posBillUrl == null
                                                        ? 'Upload'
                                                        : 'Replace',
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Order summary header blocks (Shipping | Payment Method | Shipping Method)
                                _buildOrderSummaryHeader(),

                                const SizedBox(height: 16),

                                // Items (table format)
                                Padding(
                                  padding: const EdgeInsets.only(left: 12.0),
                                  child: sectionTitle('Items'),
                                ),
                                const SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.only(left: 14.0),
                                  child: _buildItemsTableSection(),
                                ),

                                const SizedBox(height: 16),

                                // Price Details
                                Padding(
                                  padding: const EdgeInsets.only(left: 12.0),
                                  child: sectionTitle('Price Details'),
                                ),
                                const SizedBox(height: 8),
                                Card(
                                  color: customColors().secretGarden.withValues(
                                    alpha: 0.50,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _kvMoney(
                                          'Order Amount',
                                          _toDouble(order.orderAmount),
                                        ),
                                        _kvMoney(
                                          'End Pick Total',
                                          _toDouble(order.endPickedTotal),
                                        ),
                                        _kvMoney(
                                          'Shipping Charge',
                                          _toDouble(
                                            order.combinedOrderPlacedTotal! > 99
                                                ? 0
                                                : 10.00,
                                          ),
                                        ),
                                        _kvMoney(
                                          hasCoupon
                                              ? 'Discount Code (${couponCode!.toUpperCase()})'
                                              : 'Discount',
                                          _toDouble(
                                            couponCode == "first20" ? 20 : 0,
                                          ),
                                          labelStyle:
                                              hasCoupon
                                                  ? customTextStyle(
                                                    fontStyle:
                                                        FontStyle
                                                            .BodyM_SemiBold,
                                                    color:
                                                        FontColor.FontPrimary,
                                                  ).copyWith(
                                                    fontSize: 20,
                                                    height: 1.3,
                                                    color: Colors.red,
                                                  )
                                                  : null,
                                          valueStyle:
                                              hasCoupon
                                                  ? customTextStyle(
                                                    fontStyle:
                                                        FontStyle.BodyL_Bold,
                                                    color:
                                                        FontColor.FontPrimary,
                                                  ).copyWith(
                                                    fontSize: 20,
                                                    height: 1.4,
                                                    color: Colors.red,
                                                  )
                                                  : null,
                                        ),

                                        Builder(
                                          builder: (_) {
                                            double grandTotal = 0;

                                            if (order.posAmount != null &&
                                                order.posAmount != '0.0' &&
                                                order.posAmount != "" &&
                                                order.subgroupIdentifier
                                                    .startsWith("EXP")) {
                                              grandTotal = _toDouble(
                                                order.posAmount!,
                                              );
                                            } else {
                                              grandTotal = _toDouble(
                                                order.endPickedTotal != 0
                                                    ? _toDouble(
                                                      order.endPickedTotal
                                                          .toString(),
                                                    )
                                                    : order.grandTotal,
                                              );
                                            }
                                            grandTotal -= _discountValue();

                                            final due = _dueAmount();

                                            final labelStyle = customTextStyle(
                                              fontStyle:
                                                  FontStyle.BodyM_SemiBold,
                                              color: FontColor.FontPrimary,
                                            ).copyWith(
                                              fontSize: 16,
                                              height: 1.3,
                                            );

                                            final valueStyle = customTextStyle(
                                              fontStyle: FontStyle.BodyL_Bold,
                                              color: FontColor.FontPrimary,
                                            ).copyWith(
                                              fontSize: 18,
                                              height: 1.4,
                                              // Red if negative, default otherwise
                                              color:
                                                  due < 0 ? Colors.red : null,
                                            );

                                            if (order.paymentMethod ==
                                                'tns_hosted') {
                                              return Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 6,
                                                    ),
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        'Due Amount',
                                                        style: labelStyle,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Text(
                                                      _fmtQar(due),
                                                      style: valueStyle,
                                                      textAlign:
                                                          TextAlign.right,
                                                    ),
                                                  ],
                                                ),
                                              );
                                            } else {
                                              return SizedBox();
                                            }
                                          },
                                        ),

                                        _kvMoney(
                                          'Online Paid Amount',
                                          _toDouble(order.onlinePaidAmount),
                                        ),

                                        // _kvMoney(
                                        //   'POS Amount',
                                        //   _toDouble(order.posAmount ?? 0),
                                        // ),
                                        const Padding(
                                          padding: EdgeInsets.symmetric(
                                            vertical: 8.0,
                                          ),
                                          child: Divider(height: 1),
                                        ),

                                        // _kvMoney(
                                        //   'Grand Total',
                                        //   _toDouble(
                                        //     order.endPickTotal != 0
                                        //         ? double.parse(
                                        //               order.endPickTotal
                                        //                   .toString(),
                                        //             ) +
                                        //             (order.combinedOrderPlacedTotal! >
                                        //                     99
                                        //                 ? 0
                                        //                 : double.parse(
                                        //                   order.shippingCharge
                                        //                       .toString(),
                                        //                 ))
                                        //         : order.grandTotal,
                                        //   ),
                                        //   bold: true,
                                        // ),
                                        order.subgroupIdentifier
                                                .trim()
                                                .startsWith('WAR')
                                            ? _editableKvMoney(
                                              'Grand Total',
                                              _toDouble(
                                                order.couponCode == 'FIRST20'
                                                    ? double.parse(
                                                          order.orderAmount,
                                                        ) -
                                                        20
                                                    : order.orderAmount,
                                              ),
                                              onChanged: (newValue) {
                                                setState(() {
                                                  _editableGrandTotal =
                                                      newValue;
                                                });
                                                // If you need to update the order's grand total:
                                                // widget.order.grandTotal = newValue;
                                              },
                                              bold: true,
                                            )
                                            : _editableKvMoney(
                                              'Grand Total',
                                              _editableGrandTotal,
                                              onChanged: (newValue) {
                                                setState(() {
                                                  _editableGrandTotal =
                                                      newValue;
                                                });
                                                // If you need to update the order's grand total:
                                                // widget.order.grandTotal = newValue;
                                              },
                                              bold: true,
                                            ),

                                        // Editable Grand Total
                                        // Padding(
                                        //   padding: const EdgeInsets.symmetric(
                                        //     vertical: 6,
                                        //   ),
                                        //   child: Row(
                                        //     children: [
                                        //       Expanded(
                                        //         child: Text(
                                        //           'Grand Total',
                                        //           style: customTextStyle(
                                        //             fontStyle:
                                        //                 FontStyle.BodyM_Bold,
                                        //             color:
                                        //                 FontColor.FontPrimary,
                                        //           ).copyWith(
                                        //             fontSize: 16,
                                        //             height: 1.3,
                                        //           ),
                                        //         ),
                                        //       ),
                                        //       const SizedBox(width: 12),
                                        //       SizedBox(
                                        //         width: 180,
                                        //         child: TextField(
                                        //           controller:
                                        //               _grandTotalController,
                                        //           textAlign: TextAlign.right,
                                        //           keyboardType:
                                        //               const TextInputType.numberWithOptions(
                                        //                 decimal: true,
                                        //               ),
                                        //           inputFormatters: [
                                        //             FilteringTextInputFormatter.allow(
                                        //               RegExp(r'[0-9\\.]'),
                                        //             ),
                                        //           ],
                                        //           style: customTextStyle(
                                        //             fontStyle:
                                        //                 FontStyle.BodyL_Bold,
                                        //             color:
                                        //                 FontColor.FontPrimary,
                                        //           ).copyWith(
                                        //             fontSize: 18,
                                        //             height: 1.4,
                                        //           ),
                                        //           decoration:
                                        //               const InputDecoration(
                                        //                 isDense: true,
                                        //                 prefixText: 'QAR ',
                                        //                 border:
                                        //                     OutlineInputBorder(),
                                        //                 contentPadding:
                                        //                     EdgeInsets.symmetric(
                                        //                       horizontal: 8,
                                        //                       vertical: 8,
                                        //                     ),
                                        //               ),
                                        //           onChanged: (val) {
                                        //             setState(() {
                                        //               _grandTotalOverride =
                                        //                   _toDouble(val);
                                        //             });
                                        //           },
                                        //         ),
                                        //       ),
                                        //     ],
                                        //   ),
                                        // ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
          bottomNavigationBar: SafeArea(
            top: false,
            child:
                order.subgroupIdentifier.startsWith('WAR') &&
                        order.orderStatus != "assigned_cashier"
                    ? Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: SizedBox(
                        height: 48,
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colors.peachBackgrond,
                          ),
                          onPressed: () {
                            // TODO: Implement WAR order action

                            if (_posBillUrl == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Please upload POS bill before proceeding',
                                  ),
                                ),
                              );
                              // _openUploadPosBillSheet();
                              // return;
                            } else {
                              _submitWarOrder();
                            }
                          },
                          icon: const Icon(Icons.check),
                          label: const Text('Submit To DO'),
                        ),
                      ),
                    )
                    : Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child:
                          (order.orderStatus.toString() == 'assigned_cashier' ||
                                      order.orderStatus.toString() ==
                                          'start_punching') &&
                                  (!order.subgroupIdentifier.startsWith('WAR'))
                              ? SizedBox(
                                height: 48,
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: colors.islandAqua,
                                  ),
                                  onPressed:
                                      _submitting
                                          ? null
                                          : () {
                                            if (_posBillUrl == null) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Please upload POS bill before proceeding',
                                                  ),
                                                ),
                                              );
                                              // _openUploadPosBillSheet();
                                              // return;
                                            } else {
                                              _confirmAndMarkReady();
                                            }
                                          },
                                  icon:
                                      _submitting
                                          ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                          : const Icon(
                                            Icons.check_circle_outline,
                                            color: Colors.white,
                                          ),
                                  label: const Text(
                                    'Mark Ready to Dispatch',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              )
                              : const SizedBox.shrink(),
                    ),
          ),
        );
      },
    );
  }

  // Cancels any ongoing upload and closes any open dialogs/sheets safely
  void _cancelCurrentUploadAndCloseDialog() async {
    _cancelRequested = true;

    try {
      await _currentUploadTask?.cancel();
    } catch (_) {}

    _uploadTimer?.cancel();
    _uploadTimer = null;

    if (mounted) {
      setState(() {
        _uploading = false;
        _uploadProgress = null;
        _secondsLeft = 0;
      });
    }

    // Close the upload progress dialog if it is open
    if (_uploadDialogOpen) {
      _uploadDialogOpen = false;
      Navigator.of(context, rootNavigator: true).maybePop();
    }

    // Also attempt to close the bottom sheet (if currently open)
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).maybePop();
    }
  }

  // Helper: get current dropdown value based on order.paymentMethod
  String _currentPaymentValue() {
    final pm = (order.paymentMethod ?? '').trim().toLowerCase();
    if (pm == 'cardondelivery') return 'cardondelivery';
    return 'cashondelivery';
  }

  // Update local state for payment method and refresh Sadad section visibility
  void _setPaymentMethod(String method) {
    final prev = (order.paymentMethod ?? '').trim().toLowerCase();
    if (prev == 'tns_hosted') return; // Do not allow changing from online
    if (prev == method) return;
    setState(() {
      order.paymentMethod = method;
      paymentMethodnew = method;
    });
    _maybeFetchSadad();
  }
}
