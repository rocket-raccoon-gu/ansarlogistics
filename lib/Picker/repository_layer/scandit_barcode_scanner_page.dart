import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:scandit_flutter_datacapture_barcode/scandit_flutter_datacapture_barcode.dart';
import 'package:scandit_flutter_datacapture_barcode/scandit_flutter_datacapture_barcode_capture.dart';
import 'package:scandit_flutter_datacapture_core/scandit_flutter_datacapture_core.dart';
import 'package:ansarlogistics/constants/texts.dart';

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
    // TODO: implement initState
    super.initState();
    _initScanner();
  }

  // @override
  // void initState() {
  //   super.initState();

  //   // Create a fresh context
  //   _context = DataCaptureContext.forLicenseKey(scankey);

  //   // Remove any previously attached modes (prevents Error 1028)
  //   try {
  //     _context.removeAllModes();
  //   } catch (_) {}

  //   // Setup camera
  //   _camera = Camera.defaultCamera!;
  //   _context.setFrameSource(_camera);
  //   _camera.switchToDesiredState(FrameSourceState.on);

  //   // Configure barcode settings
  //   final settings = BarcodeCaptureSettings();
  //   settings.enableSymbologies({
  //     Symbology.ean13Upca,
  //     Symbology.ean8,
  //     Symbology.upce,
  //     Symbology.code39,
  //     Symbology.code128,
  //     Symbology.interleavedTwoOfFive,
  //   });

  //   // Enable UPC-A → remove leading zero (ONLY for UPC-A inside EAN13)
  //   final ean13UpcaSettings = settings.settingsForSymbology(
  //     Symbology.ean13Upca,
  //   );

  //   // Enable extension
  //   ean13UpcaSettings.setExtensionEnabled(
  //     'remove_leading_upca_zero',
  //     enabled: true,
  //   );

  //   // DON'T use non-existent setters (e.g. singleBarcodeAutoDetection)
  //   _barcodeCapture = BarcodeCapture.forContext(_context, settings);
  //   _barcodeCapture.addListener(this);
  //   _barcodeCapture.isEnabled = true;

  //   // Create native camera view and overlay
  //   _captureView = DataCaptureView.forContext(_context);

  //   final overlay = BarcodeCaptureOverlay.withBarcodeCapture(_barcodeCapture);
  //   overlay.viewfinder = RectangularViewfinder();

  //   // Use named parameters for Brush for clarity
  //   overlay.brush = Brush(Colors.transparent, Colors.greenAccent, 4);

  //   _captureView.addOverlay(overlay);
  // }

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
      // 2. Create Scandit context with key from Firestore
      _context = DataCaptureContext.forLicenseKey(scankeyFromFs);
      // 3. Rest of your initState logic, moved here:
      _context.removeAllModes();
      _camera = Camera.defaultCamera!;
      _context.setFrameSource(_camera);
      _camera.switchToDesiredState(FrameSourceState.on);
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
      _barcodeCapture = BarcodeCapture.forContext(_context, settings);
      _barcodeCapture.addListener(this);
      _barcodeCapture.isEnabled = true;
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
      _camera.switchToDesiredState(FrameSourceState.off);
    } catch (_) {}
    super.dispose();
  }

  @override
  void didUpdateSession(
    BarcodeCapture barcodeCapture,
    BarcodeCaptureSession session,
  ) {}
}
