import 'dart:convert';
import 'dart:developer';

import 'package:ansarlogistics/cashier/feature_cashier/cashier_orders_page.dart';
import 'package:ansarlogistics/components/custom_app_components/image_widgets/list_image_widget.dart';
import 'package:ansarlogistics/constants/methods.dart';
import 'package:ansarlogistics/constants/texts.dart';
import 'package:ansarlogistics/services/service_locator.dart';
import 'package:ansarlogistics/utils/utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ansarlogistics/cashier/feature_cashier_order_inner/bloc/cashier_order_inner_page_cubit.dart';
import 'package:ansarlogistics/cashier/feature_cashier_order_inner/bloc/cashier_order_inner_page_state.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:ansarlogistics/utils/preference_utils.dart';

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
  String? _posBillUrl;
  XFile? _pickedImage;
  double? _uploadProgress; // 0.0 - 1.0
  final Set<int> _selectedItemIds = <int>{};

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
          // Item selection checkbox
          Padding(
            padding: const EdgeInsets.only(right: 8.0, top: 2.0),
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
          GestureDetector(
            onTap: () {
              _openImage(item.imageurl);
            },
            child: Builder(
              builder: (_) {
                final raw = (item.imageurl ?? '').toString().trim();
                final imgUrl = raw.isEmpty ? noimageurl : resolveImageUrl(raw);
                return SizedBox(
                  width: 120,
                  height: 120,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
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
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // if (item.imageurl != null)
                  // Product image (fixed size + robust URL + fallback)
                  Text(
                    item.name,
                    style: customTextStyle(
                      fontStyle: FontStyle.BodyL_Bold,
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
    _loadExistingPosBillIfAny();
    _maybeFetchSadad();
  }

  TextStyle _titleStyle() => customTextStyle(
    fontStyle: FontStyle.BodyL_Bold,
    color: FontColor.FontPrimary,
  );

  TextStyle _subtitleStyle() => customTextStyle(
    fontStyle: FontStyle.BodyM_Bold,
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

  // More readable labeled row with selectable value
  Widget _kvSelectable(String label, String value) {
    final labelStyle = customTextStyle(
      fontStyle: FontStyle.BodyM_SemiBold,
      color: FontColor.FontPrimary,
    ).copyWith(fontSize: 16, height: 1.3);
    final valueStyle = customTextStyle(
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
              style: valueStyle,
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

  Widget _kvMoney(String label, num value, {bool bold = false}) {
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
          Text(_fmtQar(value), style: valueStyle, textAlign: TextAlign.right),
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
                        style: _subtitleStyle(),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Time left: ${_secondsLeft > 0 ? _secondsLeft : 0}s',
                        style: _subtitleStyle(),
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
                        child: Text('Bill uploaded', style: _subtitleStyle()),
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
                  Text('Uploading POS bill...', style: _titleStyle()),
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
                    style: _subtitleStyle(),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Time left: ${_secondsLeft > 0 ? _secondsLeft : 0}s',
                    style: _subtitleStyle(),
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
      final file = await _compressImageIfNeeded(_pickedImage!);
      if (_cancelRequested) {
        throw FirebaseException(plugin: 'firebase_storage', code: 'canceled');
      }
      final ts = DateTime.now().millisecondsSinceEpoch;
      final ref = FirebaseStorage.instance.ref().child(
        'pos_bills/${order.subgroupIdentifier}/bill_${order.subgroupIdentifier}.jpg',
      );

      final uploadTask = ref.putFile(
        file,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      _currentUploadTask = uploadTask;

      // Start countdown timer; auto-cancel when time is up
      _uploadTimer?.cancel();
      _uploadTimer = Timer.periodic(const Duration(seconds: 1), (t) async {
        if (!mounted) return;
        setState(
          () =>
              _secondsLeft = (_secondsLeft - 1).clamp(0, _uploadTimeoutSeconds),
        );
        if (_secondsLeft <= 0) {
          await _currentUploadTask?.cancel();
          t.cancel();
        }
      });

      uploadTask.snapshotEvents.listen((snapshot) {
        if (snapshot.totalBytes > 0) {
          final p = snapshot.bytesTransferred / snapshot.totalBytes;
          if (mounted) {
            setState(() => _uploadProgress = p);
          }
        }
      });

      // Enforce a hard timeout on the future as well
      final taskSnapshot = await uploadTask.timeout(
        Duration(seconds: _uploadTimeoutSeconds + 5),
      );
      final url = await taskSnapshot.ref.getDownloadURL();

      if (mounted) {
        setState(() => _posBillUrl = url);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('POS bill uploaded successfully')),
        );
        // Clear pending flag once bill is actually uploaded
        await _removePendingBill(order.subgroupIdentifier);
      }

      // Auto-close the bottom sheet if it's still open
      if (_posSheetOpen) {
        Navigator.of(context).pop();
        _posSheetOpen = false;
      }
    } catch (e) {
      final msg =
          e is TimeoutException
              ? 'Upload timed out. Please try again.'
              : (e is FirebaseException && e.code == 'canceled')
              ? 'Upload canceled.'
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
      final dirRef = FirebaseStorage.instance.ref().child(
        'pos_bills/${order.subgroupIdentifier}',
      );
      final listResult = await dirRef.listAll();
      if (listResult.items.isEmpty) return;

      // Prefer files named like bill_<timestamp>.jpg; pick the latest by name
      final candidates =
          listResult.items
              .where(
                (r) =>
                    r.name.toLowerCase().endsWith('.jpg') ||
                    r.name.toLowerCase().endsWith('.png'),
              )
              .toList();
      if (candidates.isEmpty) return;

      candidates.sort((a, b) => a.name.compareTo(b.name));
      final latest = candidates.last;
      final url = await latest.getDownloadURL();
      if (mounted) {
        setState(() {
          _posBillUrl = url;
        });
      }
    } catch (e) {
      // Silently ignore if folder doesn't exist or permission denied
    }
  }

  // Trigger Sadad check only when payment method matches
  Future<void> _maybeFetchSadad() async {
    try {
      final pm = (order.paymentMethod ?? '').trim().toLowerCase();
      if (pm == 'sadadqa') {
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
  Future<void> _fetchSadadTransactions(String websiteRefNo) async {
    setState(() {
      _sadadLoading = true;
      _sadadError = null;
      _sadadTxns = const [];
    });

    try {
      // 1) Login to get access token
      final loginResp = await http.post(
        Uri.parse('https://api-s.sadad.qa/api/userbusinesses/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'sadadId': 1423378,
          'secretKey': '5tviXaSRNyCvr4h5',
          'domain': 'www.ansargallery.com',
        }),
      );
      if (loginResp.statusCode != 200) {
        throw Exception('Sadad login failed (${loginResp.statusCode})');
      }
      final loginJson = jsonDecode(loginResp.body) as Map<String, dynamic>;
      final token = (loginJson['accessToken'] ?? '').toString();
      if (token.isEmpty) {
        throw Exception('Sadad access token missing');
      }

      // 2) Fetch transactions filtered by website_ref_no
      final listUri = Uri.parse(
        'https://api-s.sadad.qa/api/transactions/listTransactions?filter[skip]=0&filter[limit]=50&filter[website_ref_no]=$websiteRefNo',
      );
      final listResp = await http.get(
        listUri,
        headers: {'Authorization': token},
      );
      if (listResp.statusCode != 200) {
        throw Exception('Sadad list failed (${listResp.statusCode})');
      }
      final parsed = jsonDecode(listResp.body);
      if (parsed is! List) {
        throw Exception('Unexpected Sadad response');
      }

      final List<Map<String, dynamic>> items = [];
      for (final e in parsed) {
        final row = (e as Map).cast<String, dynamic>();
        final entity = (row['transactionentity'] ?? {}) as Map<String, dynamic>;
        final status = (row['transactionstatus'] ?? {}) as Map<String, dynamic>;
        final mode = (row['transactionmode'] ?? {}) as Map<String, dynamic>;
        final entityId = int.tryParse('${entity['id'] ?? ''}') ?? -1;
        if (entityId == 4) continue; // skip entity id 4 like the PHP logic

        final amount = row['amount']?.toString() ?? '0.00';
        final statusId = int.tryParse('${status['id'] ?? ''}') ?? 0;
        final modeName = mode['name']?.toString();
        final invoice = row['invoicenumber']?.toString();

        items.add({
          'amount': amount,
          'statusId': statusId,
          'modeName': modeName,
          'invoice': invoice,
        });
      }

      if (mounted) {
        setState(() {
          _sadadTxns = items;
          _sadadLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _sadadError = 'Sadad error: $e';
          _sadadLoading = false;
        });
      }
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
          backgroundColor: Colors.black,
          child: Stack(
            children: [
              InteractiveViewer(
                panEnabled: true,
                minScale: 0.5,
                maxScale: 4,
                child: AspectRatio(
                  aspectRatio: 1,
                  child: CachedNetworkImage(
                    imageUrl: url,
                    fit: BoxFit.contain,
                    placeholder:
                        (context, _) => Center(
                          child: Image.asset(
                            'assets/Iphone_spinner.gif',
                            width: 32,
                            height: 32,
                          ),
                        ),
                    errorWidget:
                        (context, _, __) =>
                            Image.network(noimageurl, fit: BoxFit.contain),
                  ),
                ),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
              ),
            ],
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
                      child: Text('Shipping', style: _titleStyle()),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        addressLines.join('\n'),
                        style: _subtitleStyle(),
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
                      child: Text('Payment Method', style: _titleStyle()),
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
                          // Keep the existing payment label as-is
                          Text(paymentLabel, style: _subtitleStyle()),
                          const SizedBox(height: 6),

                          // Additional row(s) for Sadad QA results
                          if ((order.paymentMethod ?? '')
                                  .trim()
                                  .toLowerCase() ==
                              'sadadqa') ...[
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
                                style: _subtitleStyle().copyWith(
                                  color: Colors.red,
                                ),
                              )
                            else if (_sadadTxns.isEmpty)
                              Text(
                                '- No online transactions found -',
                                style: _subtitleStyle(),
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
                                          color:
                                              (t['statusId'] == 3)
                                                  ? Colors.green
                                                  : Colors.red,
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
                                              ((t['statusId'] == 3)
                                                  ? '(Online Paid)'
                                                  : '(Failed)'),
                                          style: customTextStyle(
                                            fontStyle: FontStyle.BodyS_Bold,
                                            color: FontColor.White,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        '${t['modeName'] ?? '-'}',
                                        style: _subtitleStyle(),
                                      ),
                                      if ((t['invoice'] ?? '')
                                          .toString()
                                          .isNotEmpty) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          '${t['invoice']}',
                                          style: _subtitleStyle(),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ],
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
                      child: Text('Shipping Method', style: _titleStyle()),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            shippingLabel.isEmpty ? '-' : shippingLabel,
                            style: _subtitleStyle(),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Delivery Charges: ' +
                                (shippingCharge == 0
                                    ? 'Free Shipping'
                                    : shippingCharge.toStringAsFixed(2)),
                            style: _subtitleStyle(),
                          ),
                          Text(
                            '(Total Shipping Charges QAR ${shippingCharge.toStringAsFixed(2)})',
                            style: _subtitleStyle(),
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

  // Build a table-like layout for items with a fixed set of columns.
  Widget _buildItemsTableSection() {
    final colors = customColors();

    // Apply the same filtering as before
    final filtered =
        order.items.where((i) {
          final s = (i.itemStatus).toString().toLowerCase();
          return s != 'item_not_available' &&
              s != 'canceled' &&
              s != 'cancelled';
        }).toList();

    final withChanges = filtered.where(_hasPriceChange).toList();
    final withoutChanges = filtered.where((i) => !_hasPriceChange(i)).toList();

    DataTable buildTable(List<Item> items) {
      // Pre-calc totals
      double totalQty = 0;
      double totalSubtotal = 0;

      final rows = <DataRow>[];
      for (int index = 0; index < items.length; index++) {
        final item = items[index];
        final orderQty = _toDouble(item.qtyOrdered);
        final qty = _toDouble(item.qtyShipped);
        final orderPrice = _toDouble(item.price);
        final pickerPrice = _toDouble(item.finalPrice);
        final webPrice = _toDouble(item.webprice);
        final unitPrice = pickerPrice != 0 ? pickerPrice : orderPrice;

        final subtotal =
            item.finalPrice != "0.0000"
                ? double.parse(item.finalPrice.toString())
                : double.parse(item.price.toString()) * qty;

        log("subtotal ${item.price} * Qty $qty");

        log("subtotal value $subtotal");

        totalQty += qty;
        // totalSubtotal += subtotal;

        rows.add(
          DataRow(
            color: MaterialStateProperty.resolveWith(
              (states) =>
                  index.isEven
                      ? colors.backgroundPrimary.withOpacity(0.02)
                      : null,
            ),
            cells: [
              DataCell(
                Checkbox(
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
              DataCell(Text('${index + 1}')),
              // Image thumbnail cell
              DataCell(
                InkWell(
                  onTap: () => _openImage(item.imageurl),
                  child: SizedBox(
                    width: 48,
                    height: 48,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Builder(
                        builder: (_) {
                          final raw = (item.imageurl ?? '').toString().trim();
                          final imgUrl =
                              raw.isEmpty ? noimageurl : resolveImageUrl(raw);
                          return CachedNetworkImage(
                            imageUrl: imgUrl,
                            fit: BoxFit.cover,
                            placeholder:
                                (context, _) => const Center(
                                  child: SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                            errorWidget:
                                (context, _, __) => Image.network(
                                  noimageurl,
                                  fit: BoxFit.cover,
                                ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
              DataCell(
                SizedBox(
                  width: 260,
                  child: Text(
                    item.productName == "" ? item.name : item.productName!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              DataCell(SizedBox(width: 120, child: Text(item.sku))),
              DataCell(Text(webPrice.toStringAsFixed(2))),
              DataCell(Text(orderPrice.toStringAsFixed(2))),
              DataCell(Text(pickerPrice.toStringAsFixed(2))),
              DataCell(Text(orderQty.toStringAsFixed(0))),
              DataCell(Text(qty.toStringAsFixed(2))),
              const DataCell(Text('0.00')),
              DataCell(Text(subtotal.toStringAsFixed(2))),
            ],
          ),
        );
      }

      // Totals row
      // rows.add(
      //   DataRow(
      //     color: MaterialStateProperty.all(
      //       colors.backgroundPrimary.withOpacity(0.06),
      //     ),
      //     cells: [
      //       const DataCell(Text('')),
      //       const DataCell(Text('')),
      //       const DataCell(Text('')),
      //       const DataCell(Text('')),
      //       DataCell(Text('Total', style: _amountBold())),
      //       const DataCell(Text('')),
      //       const DataCell(Text('')),
      //       const DataCell(Text('')),
      //       DataCell(Text(totalQty.toStringAsFixed(0), style: _amountBold())),
      //       const DataCell(Text('')),
      //       DataCell(
      //         Text(totalSubtotal.toStringAsFixed(2), style: _amountBold()),
      //       ),
      //     ],
      //   ),
      // );

      return DataTable(
        headingRowHeight: 40,
        dataRowMinHeight: 40,
        dataRowMaxHeight: 60,
        headingRowColor: MaterialStateProperty.all(colors.backgroundPrimary),
        border: TableBorder.all(color: colors.primary),
        // Slightly tighter spacing so more columns fit without horizontal scroll
        columnSpacing: 8,
        columns: [
          const DataColumn(label: Text('')),
          const DataColumn(label: Text('Sr No'), numeric: true),
          const DataColumn(label: Text('Image')),
          const DataColumn(label: Text('Product')),
          const DataColumn(label: Text('SKU')),
          const DataColumn(label: Text('Web.Price'), numeric: true),
          const DataColumn(label: Text('Price'), numeric: true),
          const DataColumn(label: Text('Picker Price (QAR)'), numeric: true),
          const DataColumn(label: Text('Qty Order'), numeric: true),
          const DataColumn(label: Text('Qty shipp')),
          const DataColumn(label: Text('Discount (QAR)')),
          const DataColumn(label: Text('Row Total (QAR)'), numeric: true),
        ],
        rows: rows,
      );
    }

    List<Widget> sections = [];

    if (withChanges.isNotEmpty) {
      sections.add(
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
          decoration: BoxDecoration(
            color: customColors().carnationRed.withValues(alpha: 0.50),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '  Items Have Price Changes',
            style: customTextStyle(
              fontStyle: FontStyle.BodyM_Bold,
              color: FontColor.FontPrimary,
            ),
          ),
        ),
      );
      sections.add(const SizedBox(height: 8));
      sections.add(
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.zero,
          child: buildTable(withChanges),
        ),
      );
      if (withoutChanges.isNotEmpty) sections.add(const SizedBox(height: 12));
    }

    if (withoutChanges.isNotEmpty) {
      sections.add(
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
          decoration: BoxDecoration(
            color: customColors().secretGarden.withValues(alpha: 0.50),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '  Items Without Price Changes',
            style: customTextStyle(
              fontStyle: FontStyle.BodyM_Bold,
              color: FontColor.FontPrimary,
            ),
          ),
        ),
      );
      sections.add(const SizedBox(height: 8));
      sections.add(
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.zero,
          child: buildTable(withoutChanges),
        ),
      );
    }

    if (sections.isEmpty) {
      sections.add(Center(child: Text('-', style: _subtitleStyle())));
    }

    return Card(
      margin: EdgeInsets.zero,
      color: colors.backgroundSecondary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: sections,
      ),
    );
  }

  Future<void> _confirmAndMarkReady({
    bool forceLater = false,
    String status = 'ready_to_dispatch',
  }) async {
    final colors = customColors();
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

      final resp = await context.gTradingApiGateway.updateMainOrderStat(
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
        grandTotal:
            _toDouble(
              order.endPickTotal != 0
                  ? double.parse(order.endPickTotal.toString()) +
                      double.parse(order.shippingCharge.toString())
                  : order.grandTotal,
            ).toString(),
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

    return BlocListener<CashierOrderInnerPageCubit, CashierOrderInnerPageState>(
      listener: (context, state) {
        if (state is CashierOrderInnerPageStateLoaded) {
          setState(() {
            order = state.response;
            _posBillUrl = null;
          });

          _maybeFetchSadad();
          _loadExistingPosBillIfAny();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: colors.backgroundPrimary,
          title: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Text('#${order.subgroupIdentifier}', style: _titleStyle()),
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

                  order.driverType != null && order.driverType != ''
                      ? Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.purple,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              Image.asset(
                                'assets/rafeeq_logo.png',
                                width: 24,
                                height: 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                getDriverType(order.driverType!),
                                style: customTextStyle(
                                  fontStyle: FontStyle.BodyL_SemiBold,
                                  color: FontColor.White,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      : const SizedBox.shrink(),
                ],
              ],
            ),
          ),
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
                      child: Text(state.message, style: _subtitleStyle()),
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
            }
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                                data: order.subgroupIdentifier,
                                                color: colors.fontPrimary,
                                                drawText: false,
                                              ),
                                            ),
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
                                    const Spacer(),
                                    // Status chip aligned to the right
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: getStatusColor(
                                              order.orderStatus.toString(),
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                          child: Text(
                                            getStatus(
                                              order.orderStatus.toString(),
                                            ),
                                            style: customTextStyle(
                                              fontStyle: FontStyle.BodyM_Bold,
                                              color: FontColor.White,
                                            ),
                                          ),
                                        ),
                                        if (order.statusHistory != null &&
                                            DateUtils.isSameDay(
                                              order.statusHistory!.createdAt,
                                              DateTime.now(),
                                            )) ...[
                                          const SizedBox(height: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: customColors().islandAqua,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              'Ready to Dispatch',
                                              style: customTextStyle(
                                                fontStyle: FontStyle.BodyS_Bold,
                                                color: FontColor.White,
                                              ),
                                            ),
                                          ),
                                        ],
                                        if (order.isWhatsappOrder == 1) ...[
                                          const SizedBox(height: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color:
                                                  customColors().secretGarden,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
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
                                                        FontStyle.BodyS_Bold,
                                                    color: FontColor.White,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Customer Information
                            Padding(
                              padding: const EdgeInsets.only(left: 12.0),
                              child: _sectionTitle('Customer'),
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
                                          .toString()
                                          .trim()
                                          .isNotEmpty)
                                        _kvSelectable(
                                          'Delivery Note',
                                          order.deliveryNote!.trim(),
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
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
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
                                            if (_posBillUrl != null) ...[
                                              const SizedBox(width: 8),
                                              GestureDetector(
                                                onTap:
                                                    () =>
                                                        _openImage(_posBillUrl),
                                                child: SizedBox(
                                                  width: 80,
                                                  height: 80,
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          6,
                                                        ),
                                                    child: CachedNetworkImage(
                                                      imageUrl: _posBillUrl!,
                                                      fit: BoxFit.cover,
                                                      placeholder:
                                                          (
                                                            context,
                                                            _,
                                                          ) => const Center(
                                                            child: SizedBox(
                                                              width: 16,
                                                              height: 16,
                                                              child:
                                                                  CircularProgressIndicator(
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
                                                            fit: BoxFit.cover,
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
                              child: _sectionTitle('Items'),
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
                              child: _sectionTitle('Price Details'),
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _kvMoney(
                                      'Order Amount',
                                      _toDouble(order.orderAmount),
                                    ),
                                    _kvMoney(
                                      'End Pick Total',
                                      _toDouble(order.endPickTotal),
                                    ),
                                    _kvMoney(
                                      'Shipping Charge',
                                      _toDouble(order.shippingCharge),
                                    ),
                                    _kvMoney(
                                      'Discount',
                                      _toDouble(order.discountValue ?? 0),
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
                                    _kvMoney(
                                      'Grand Total',
                                      _toDouble(
                                        order.endPickTotal != 0
                                            ? double.parse(
                                                  order.endPickTotal.toString(),
                                                ) +
                                                double.parse(
                                                  order.shippingCharge
                                                      .toString(),
                                                )
                                            : order.grandTotal,
                                      ),
                                      bold: true,
                                    ),
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
          },
        ),
        bottomNavigationBar:
        // order.subgroupIdentifier.startsWith('SUP') ||
        //         order.subgroupIdentifier.startsWith('WAR')
        //     ? SafeArea(
        //       top: false,
        //       child: Padding(
        //         padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        //         child: SizedBox(
        //           height: 48,
        //           width: double.infinity,
        //           child: ElevatedButton(
        //             style: ElevatedButton.styleFrom(
        //               backgroundColor: colors.islandAqua,
        //             ),
        //             onPressed: () {
        //               _confirmAndMarkReady(status: 'sfo_order');
        //             },
        //             child: const Text('SFO Done'),
        //           ),
        //         ),
        //       ),
        //     )
        //     :
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child:
                order.orderStatus.toString() == 'ready_to_dispatch' ||
                        order.orderStatus.toString() != 'end_picking'
                    ? const SizedBox.shrink()
                    : SizedBox(
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
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
          ),
        ),
      ),
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
}
