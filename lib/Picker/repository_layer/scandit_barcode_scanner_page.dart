import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:scandit_flutter_datacapture_barcode/scandit_flutter_datacapture_barcode.dart';
import 'package:scandit_flutter_datacapture_barcode/scandit_flutter_datacapture_barcode_capture.dart';
import 'package:scandit_flutter_datacapture_core/scandit_flutter_datacapture_core.dart';
import 'package:ansarlogistics/services/scandit_manager.dart';

class ScanditBarcodeScannerPage extends StatefulWidget {
  const ScanditBarcodeScannerPage({super.key});

  @override
  State<ScanditBarcodeScannerPage> createState() =>
      _ScanditBarcodeScannerPageState();
}

class _ScanditBarcodeScannerPageState extends State<ScanditBarcodeScannerPage>
    implements BarcodeCaptureListener {
  late final DataCaptureContext _context;
  late final Camera _camera;
  late final DataCaptureView _captureView;
  late final BarcodeCapture _barcodeCapture;

  bool _handled = false;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initScanner();
  }

  Future<void> _initScanner() async {
    try {
      // 1. Read document from Firestore
      final doc =
          await FirebaseFirestore.instance
              .collection('base_path')
              .doc('7F32CBHMHACadSeNRWsY') // your doc id
              .get();
      final data = doc.data();
      if (data == null || data['scandit-key'] == null) {
        throw Exception('scandit-key not found in Firestore');
      }
      final String scankeyFromFs = data['scandit-key'] as String;

      // 2. Use ScanditManager to get shared context (prevents Error 1028)
      _context = ScanditManager.getContext(scankeyFromFs);

      // 3. Remove any existing modes to prevent conflicts
      ScanditManager.removeAllModes();

      // 4. Setup camera
      _camera = Camera.defaultCamera!;
      _context.setFrameSource(_camera);
      _camera.switchToDesiredState(FrameSourceState.on);

      // 5. Configure barcode settings
      final settings = BarcodeCaptureSettings();
      settings.enableSymbologies({
        Symbology.ean13Upca,
        Symbology.ean8,
        Symbology.upce,
        Symbology.code39,
        Symbology.code128,
        Symbology.interleavedTwoOfFive,
      });
      final ean13UpcaSettings = settings.settingsForSymbology(
        Symbology.ean13Upca,
      );
      ean13UpcaSettings.setExtensionEnabled(
        'remove_leading_upca_zero',
        enabled: true,
      );

      // 6. Create barcode capture with context
      _barcodeCapture = BarcodeCapture.forContext(_context, settings);
      _barcodeCapture.addListener(this);
      _barcodeCapture.isEnabled = true;

      // Register with ScanditManager for proper cleanup
      ScanditManager.registerMode(_barcodeCapture);

      // 7. Create view and overlay
      _captureView = DataCaptureView.forContext(_context);
      final overlay = BarcodeCaptureOverlay.withBarcodeCapture(_barcodeCapture);
      overlay.viewfinder = RectangularViewfinder();
      overlay.brush = Brush(Colors.transparent, Colors.greenAccent, 4);
      _captureView.addOverlay(overlay);

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_error != null) {
      return Scaffold(body: Center(child: Text('Scanner error: $_error')));
    }

    return Scaffold(body: SafeArea(child: _captureView));
  }

  @override
  void didScan(BarcodeCapture barcodeCapture, BarcodeCaptureSession session) {
    if (_handled) return;

    final newBarcodes = session.newlyRecognizedBarcodes;
    if (newBarcodes.isEmpty) return;

    final barcode = newBarcodes.first;

    String code = extractBarcodeValue(barcode);

    // Only normalize EAN-13; others are returned unchanged
    code = normalizeScannedBarcode(barcode, code);

    if (code.isEmpty) return;

    _handled = true;

    // Stop further scanning
    _barcodeCapture.isEnabled = false;

    Future.delayed(const Duration(milliseconds: 200), () {
      try {
        _camera.switchToDesiredState(FrameSourceState.standby);
      } catch (_) {}
      if (mounted) Navigator.pop(context, code);
    });
  }

  // Decode rawData (base64) if present; fallback to barcode.data
  String extractBarcodeValue(Barcode barcode) {
    // Always prefer .data first — it preserves leading zeros
    if (barcode.data != null && barcode.data!.isNotEmpty) {
      return barcode.data!;
    }

    // Fallback to rawData decode if .data is empty
    try {
      final raw = barcode.rawData;
      if (raw != null && raw.isNotEmpty) {
        final decoded = base64Decode(raw);
        final s = utf8.decode(decoded);
        if (s.isNotEmpty) return s;
      }
    } catch (_) {
      // ignore decode errors
    }

    return "";
  }

  // Normalize only EAN-13 values; leave others untouched
  // String normalizeScannedBarcode(Barcode barcode, String value) {
  //   final sym = barcode.symbology.toString().toLowerCase();
  //   String code = value;

  //   // Only normalize true EAN-13 barcodes that were originally UPC-A
  //   // if (sym.contains('ean13') && code.length == 13 && code.startsWith('0')) {
  //   //   return code.substring(1); // remove the extra leading zero
  //   // }

  //   // For all other barcodes, return exactly as scanned
  //   return code;
  // }

  // Normalize only EAN-13/UPC-A-like barcodes for our custom leading-zero rule
  String normalizeScannedBarcode(Barcode barcode, String value) {
    final sym = barcode.symbology.toString().toLowerCase();
    String code = value;

    // Only touch EAN13/UPCA-like barcodes
    // if (sym.contains('ean13') && code.length == 13) {
    //   // If starts with "00" -> drop exactly ONE leading zero
    //   if (code.startsWith('00')) {
    //     return code.substring(1); // e.g. 0054... -> 0544...
    //   }

    //   // If starts with a single "0" but not "00" -> remove that one leading zero
    //   if (code.startsWith('0')) {
    //     return code.substring(1);
    //   }
    // }

    // All other barcodes, or ones not matching the rule, return as-is
    return code;
  }

  @override
  void dispose() {
    try {
      _barcodeCapture.removeListener(this);
    } catch (_) {}
    try {
      _barcodeCapture.isEnabled = false;
    } catch (_) {}
    try {
      _camera.switchToDesiredState(FrameSourceState.off);
    } catch (_) {}

    // Unregister from ScanditManager for proper cleanup
    ScanditManager.unregisterMode(_barcodeCapture);

    super.dispose();
  }

  @override
  void didUpdateSession(
    BarcodeCapture barcodeCapture,
    BarcodeCaptureSession session,
  ) {}
}
