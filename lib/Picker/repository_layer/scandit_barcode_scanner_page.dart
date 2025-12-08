import 'dart:convert';
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

  @override
  void initState() {
    super.initState();

    // Create a fresh context
    _context = DataCaptureContext.forLicenseKey(scankey);

    // Remove any previously attached modes (prevents Error 1028)
    try {
      _context.removeAllModes();
    } catch (_) {}

    // Setup camera
    _camera = Camera.defaultCamera!;
    _context.setFrameSource(_camera);
    _camera.switchToDesiredState(FrameSourceState.on);

    // Configure barcode settings
    final settings = BarcodeCaptureSettings();
    settings.enableSymbologies({
      Symbology.ean13Upca,
      Symbology.ean8,
      Symbology.upce,
      Symbology.code39,
      Symbology.code128,
      Symbology.interleavedTwoOfFive,
    });

    // DON'T use non-existent setters (e.g. singleBarcodeAutoDetection)
    _barcodeCapture = BarcodeCapture.forContext(_context, settings);
    _barcodeCapture.addListener(this);
    _barcodeCapture.isEnabled = true;

    // Create native camera view and overlay
    _captureView = DataCaptureView.forContext(_context);

    final overlay = BarcodeCaptureOverlay.withBarcodeCapture(_barcodeCapture);
    overlay.viewfinder = RectangularViewfinder();

    // Use named parameters for Brush for clarity
    overlay.brush = Brush(Colors.transparent, Colors.greenAccent, 4);

    _captureView.addOverlay(overlay);
  }

  @override
  Widget build(BuildContext context) {
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
  String normalizeScannedBarcode(Barcode barcode, String value) {
    final sym = barcode.symbology.toString().toLowerCase();
    String code = value;

    // Only normalize true EAN-13 barcodes that were originally UPC-A
    if (sym.contains('ean13') && code.length == 13 && code.startsWith('0')) {
      return code.substring(1); // remove the extra leading zero
    }

    // For all other barcodes, return exactly as scanned
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
