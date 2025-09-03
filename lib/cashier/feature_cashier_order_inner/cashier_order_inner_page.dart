import 'package:ansarlogistics/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:picker_driver_api/responses/cashier_order_response.dart';
import 'package:ansarlogistics/app_page_injectable.dart';
import 'package:ansarlogistics/user_controller/user_controller.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:intl/intl.dart';

class CashierOrderInnerPage extends StatefulWidget {
  const CashierOrderInnerPage({super.key, required this.arguments});

  final Map<String, dynamic> arguments;

  @override
  State<CashierOrderInnerPage> createState() => _CashierOrderInnerPageState();
}

class _CashierOrderInnerPageState extends State<CashierOrderInnerPage> {
  late final Datum order;
  bool _submitting = false;
  bool _uploading = false;
  String? _posBillUrl;
  XFile? _pickedImage;

  // Safe parsers to prevent FormatException when API returns empty or non-numeric strings
  double _toDouble(Object? s) {
    final v = s?.toString().trim() ?? '';
    if (v.isEmpty) return 0;
    return double.tryParse(v) ?? 0;
  }

  int _toInt(Object? s) => _toDouble(s).toInt();

  bool _hasPriceChange(Item item) {
    final orderPrice = _toDouble(item.price);
    final pickerPrice = _toDouble(item.finalPrice);
    final webPrice = _toDouble(item.webprice);
    bool diffPicker =
        pickerPrice != 0 && (pickerPrice - orderPrice).abs() > 0.0001;
    bool diffWeb = webPrice != 0 && (webPrice - orderPrice).abs() > 0.0001;
    return diffPicker || diffWeb;
  }

  Widget _buildItemRow(Item item) {
    final colors = customColors();
    final qty = _toDouble(item.qtyShipped);
    final orderPrice = _toDouble(item.price);
    final pickerPrice = _toDouble(item.finalPrice);
    final webPrice = _toDouble(item.webprice);
    final unitPrice = pickerPrice != 0 ? pickerPrice : orderPrice;
    final total = unitPrice * qty;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: customTextStyle(
                    fontStyle: FontStyle.BodyM_Bold,
                    color: FontColor.FontPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text('SKU: ${item.sku}', style: _subtitleStyle()),
                const SizedBox(height: 2),
                Text(
                  'Status: ${getItemStatus(item.itemStatus)}',
                  style: _subtitleStyle(),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('Qty: ${_toInt(item.qtyShipped)}', style: _subtitleStyle()),
              const SizedBox(height: 2),
              Text(
                'Order Price: ${orderPrice.toStringAsFixed(2)}',
                style: _subtitleStyle(),
              ),
              const SizedBox(height: 2),
              Text(
                'Picker Price: ${pickerPrice.toStringAsFixed(2)}',
                style: _subtitleStyle(),
              ),
              const SizedBox(height: 2),
              Text(
                'Current Price: ${webPrice.toStringAsFixed(2)}',
                style: _subtitleStyle(),
              ),
              const SizedBox(height: 2),
              Text(
                'Total: ${total.toStringAsFixed(2)}',
                style: _subtitleStyle(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    order = widget.arguments['order'] as Datum;
  }

  TextStyle _titleStyle() => customTextStyle(
    fontStyle: FontStyle.BodyL_Bold,
    color: FontColor.FontPrimary,
  );

  TextStyle _subtitleStyle() => customTextStyle(
    fontStyle: FontStyle.BodyS_Regular,
    color: FontColor.FontSecondary,
  );

  TextStyle _amountBold() => customTextStyle(
    fontStyle: FontStyle.BodyL_Bold,
    color: FontColor.FontPrimary,
  );

  Widget _sectionTitle(String text) {
    return Text(text, style: _titleStyle());
  }

  Widget _kv(String label, String value, {TextStyle? valueStyle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(child: Text(label, style: _subtitleStyle())),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: valueStyle ?? _subtitleStyle(),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openUploadPosBillSheet() async {
    final colors = customColors();
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
              Text('Upload POS Bill', style: _titleStyle()),
              const SizedBox(height: 8),
              Text(
                'Attach a clear photo or file of the POS bill before marking the order ready to dispatch.',
                style: _subtitleStyle(),
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
                                  imageQuality: 85,
                                );
                                if (img != null) {
                                  setState(() => _pickedImage = img);
                                  await _uploadPickedImage();
                                  if (mounted) Navigator.pop(context);
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
                                  if (mounted) Navigator.pop(context);
                                }
                              },
                      icon: const Icon(Icons.upload_file_outlined),
                      label: const Text('Browse'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_uploading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: LinearProgressIndicator(minHeight: 3),
                ),
              if (_posBillUrl != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text('Bill uploaded', style: _subtitleStyle()),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _uploadPickedImage() async {
    if (_pickedImage == null) return;
    try {
      setState(() => _uploading = true);
      final file = File(_pickedImage!.path);
      final ts = DateTime.now().millisecondsSinceEpoch;
      final ref = FirebaseStorage.instance.ref().child(
        'pos_bills/${order.subgroupIdentifier}/bill_$ts.jpg',
      );
      final task = await ref.putFile(
        file,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      final url = await task.ref.getDownloadURL();
      setState(() => _posBillUrl = url);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('POS bill uploaded successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _confirmAndMarkReady() async {
    final colors = customColors();
    // Require POS bill first
    if (_posBillUrl == null) {
      await _openUploadPosBillSheet();
      if (_posBillUrl == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please upload POS bill before proceeding'),
          ),
        );
        return;
      }
    }
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirm'),
            content: const Text(
              'Mark this order as Ready to Dispatch? POS bill will be attached.',
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

      final resp = await context.gTradingApiGateway.updateMainOrderStat(
        orderid: order.subgroupIdentifier,
        // If your backend expects a different keyword, adjust here
        orderstatus: 'ready_to_dispatch',
        comment:
            '$name ($empId) marked order ready to dispatch | POS Bill: ${_posBillUrl ?? ''}',
        userid: userId,
        latitude: lat,
        longitude: lng,
      );

      if (mounted) {
        if (resp != null && resp.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Order marked Ready to Dispatch')),
          );
          Navigator.of(context).pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed: ${resp?.statusCode ?? ''}')),
          );
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
    final String deliveryDateText = getdateformatted(order.deliveryFrom);
    final String? timeRangeText =
        (() {
          final tr = (order.timerange ?? '').toString().trim();
          if (tr.isNotEmpty) return tr;
          final from = order.deliveryFrom;
          final to = order.deliveryTo;
          final tf = DateFormat('hh:mm a');
          try {
            if (to != null) {
              final fromStr = tf.format(from);
              final toStr = tf.format(to);
              if (fromStr != toStr) return '$fromStr - $toStr';
              return fromStr;
            }
            return tf.format(from);
          } catch (_) {
            return null;
          }
        })();

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: colors.backgroundPrimary,
        title: Text('#${order.subgroupIdentifier}', style: _titleStyle()),
      ),
      backgroundColor: colors.backgroundPrimary,
      body: LayoutBuilder(
        builder: (ctx, constraints) {
          final isTablet = constraints.maxWidth >= 900;
          final maxWidth = isTablet ? 1100.0 : 640.0;
          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            BarcodeWidget(
                              barcode: Barcode.code128(),
                              data: order.subgroupIdentifier,
                              width: double.infinity,
                              height: 72,
                              color: colors.fontPrimary,
                              drawText: false,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              order.subgroupIdentifier,
                              style: customTextStyle(
                                fontStyle: FontStyle.BodyM_Bold,
                                color: FontColor.FontPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Customer Information
                    _sectionTitle('Customer'),
                    const SizedBox(height: 8),
                    Card(
                      color: colors.backgroundSecondary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.person, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    name.isEmpty ? '-' : name,
                                    style: customTextStyle(
                                      fontStyle: FontStyle.BodyM_SemiBold,
                                      color: FontColor.FontPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.location_on_outlined,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    address.isEmpty ? '-' : address,
                                    style: _subtitleStyle(),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.call_outlined, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    (order.telephone).toString(),
                                    style: _subtitleStyle(),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Delivery date
                            Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today_outlined,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Delivery: ' + deliveryDateText,
                                    style: _subtitleStyle(),
                                  ),
                                ),
                              ],
                            ),
                            if ((timeRangeText ?? '').isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.schedule, size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Time: ' + timeRangeText!,
                                      style: _subtitleStyle(),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            const SizedBox(height: 8),
                            if ((order.deliveryNote ?? '')
                                .toString()
                                .trim()
                                .isNotEmpty)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.sticky_note_2_outlined,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      order.deliveryNote!.trim(),
                                      style: _subtitleStyle(),
                                    ),
                                  ),
                                ],
                              ),
                            if ((order.pickername ?? '')
                                .toString()
                                .trim()
                                .isNotEmpty)
                              Row(
                                children: [
                                  const Icon(Icons.badge_outlined, size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Picked by: ${order.pickername!.trim()}',
                                      style: _subtitleStyle(),
                                    ),
                                  ),
                                ],
                              ),
                            if ((order.pickername ?? '')
                                .toString()
                                .trim()
                                .isNotEmpty)
                              const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: colors.backgroundPrimary,
                                border: Border.all(color: colors.primary),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.all(8),
                              child: Row(
                                children: [
                                  Icon(
                                    _posBillUrl == null
                                        ? Icons.receipt_long_outlined
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
                                      style: _subtitleStyle(),
                                    ),
                                  ),
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

                    const SizedBox(height: 16),

                    // Items Listing
                    _sectionTitle('Items'),
                    const SizedBox(height: 8),
                    Card(
                      color: colors.backgroundSecondary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Builder(
                          builder: (_) {
                            final withChanges =
                                order.items.where(_hasPriceChange).toList();
                            final withoutChanges =
                                order.items
                                    .where((i) => !_hasPriceChange(i))
                                    .toList();

                            List<Widget> children = [];

                            if (withChanges.isNotEmpty) {
                              children.add(
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                    horizontal: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Items Have Price Changes',
                                    style: customTextStyle(
                                      fontStyle: FontStyle.BodyM_Bold,
                                      color: FontColor.FontPrimary,
                                    ),
                                  ),
                                ),
                              );
                              children.add(const SizedBox(height: 8));
                              for (int i = 0; i < withChanges.length; i++) {
                                children.add(_buildItemRow(withChanges[i]));
                                if (i != withChanges.length - 1) {
                                  children.add(
                                    Divider(height: 1, color: colors.primary),
                                  );
                                }
                              }
                              if (withoutChanges.isNotEmpty) {
                                children.add(const SizedBox(height: 12));
                              }
                            }

                            if (withoutChanges.isNotEmpty) {
                              children.add(
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                    horizontal: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Items Without Price Changes',
                                    style: customTextStyle(
                                      fontStyle: FontStyle.BodyM_Bold,
                                      color: FontColor.FontPrimary,
                                    ),
                                  ),
                                ),
                              );
                              children.add(const SizedBox(height: 8));
                              for (int i = 0; i < withoutChanges.length; i++) {
                                children.add(_buildItemRow(withoutChanges[i]));
                                if (i != withoutChanges.length - 1) {
                                  children.add(
                                    Divider(height: 1, color: colors.primary),
                                  );
                                }
                              }
                            }

                            if (children.isEmpty) {
                              children.add(
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text('-', style: _subtitleStyle()),
                                  ),
                                ),
                              );
                            }

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: children,
                            );
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Price Details
                    _sectionTitle('Price Details'),
                    const SizedBox(height: 8),
                    Card(
                      color: colors.backgroundSecondary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: [
                            _kv('Order Amount', order.orderAmount.toString()),
                            _kv(
                              'Shipping Charge',
                              (order.shippingCharge).toString(),
                            ),
                            _kv(
                              'Discount',
                              (order.discountValue ?? '').toString(),
                            ),
                            _kv(
                              'POS Amount',
                              (order.posAmount ?? '').toString(),
                            ),
                            const Divider(),
                            _kv(
                              'Grand Total',
                              _toDouble(order.grandTotal).toStringAsFixed(2),
                              valueStyle: _amountBold(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: SizedBox(
            height: 48,
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _submitting ? null : _confirmAndMarkReady,
              icon:
                  _submitting
                      ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Icon(Icons.check_circle_outline),
              label: const Text('Mark Ready to Dispatch'),
            ),
          ),
        ),
      ),
    );
  }
}
