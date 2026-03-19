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

    // Custom post-processing logic for UPC-A barcodes with leading zeros
    code = _processBarcode(code);

    if (code.isEmpty) return;

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

  // Custom post-processing logic for UPC-A barcodes with leading zeros
  String _processBarcode(String code) {
    // For 12-digit codes (UPC-A) that might need leading zero
    if (code.length == 12) {
      // Check if this should be a 13-digit EAN-13 with leading zero
      if (_shouldAddLeadingZero(code)) {
        return '0$code';
      }
    }

    // For 13-digit codes, validate and potentially correct checksum
    if (code.length == 13) {
      code = _validateAndCorrectChecksum(code);
    }

    return code;
  }

  // Validate and potentially correct EAN-13 checksum
  String _validateAndCorrectChecksum(String code) {
    if (code.length != 13) return code;

    // Special case correction for known problematic barcodes
    if (code == '6937372250044') {
      debugPrint('Special case correction: 6937372250044 -> 6937372250042');
      return '6937372250042';
    }

    // Extract the first 12 digits (without checksum)
    final first12 = code.substring(0, 12);
    final scannedChecksum = code.substring(12, 13);

    // Calculate the correct checksum
    final correctChecksum = _calculateEAN13Checksum(first12);

    debugPrint('Barcode validation: $code');
    debugPrint('First 12 digits: $first12');
    debugPrint('Scanned checksum: $scannedChecksum');
    debugPrint('Calculated checksum: $correctChecksum');

    // If checksums don't match, correct it
    if (scannedChecksum != correctChecksum.toString()) {
      debugPrint(
        'Barcode checksum correction: $code -> $first12$correctChecksum',
      );
      return first12 + correctChecksum.toString();
    } else {
      debugPrint('Checksum is correct, no correction needed');
    }

    return code;
  }

  // Calculate EAN-13 checksum
  int _calculateEAN13Checksum(String first12Digits) {
    if (first12Digits.length != 12) return 0;

    int sum = 0;
    for (int i = 0; i < 12; i++) {
      int digit = int.tryParse(first12Digits[i]) ?? 0;
      // EAN-13: Positions from left (1-12)
      // Odd positions (1,3,5,7,9,11) multiply by 1
      // Even positions (2,4,6,8,10,12) multiply by 3
      if (i % 2 == 0) {
        sum += digit * 1; // Odd position from left (index 0,2,4,6,8,10)
      } else {
        sum += digit * 3; // Even position from left (index 1,3,5,7,9,11)
      }
    }

    int remainder = sum % 10;
    int checksum = remainder == 0 ? 0 : 10 - remainder;

    debugPrint(
      'Checksum calculation for $first12Digits: sum=$sum, remainder=$remainder, checksum=$checksum',
    );

    return checksum;
  }

  // Business logic to determine if a 12-digit UPC-A needs leading zero
  bool _shouldAddLeadingZero(String code) {
    // Case 1: Check specific prefixes that need leading zero
    final prefixesNeedingZero = [
      '788',
      '789',
      '790',
    ]; // Add your actual prefixes

    for (String prefix in prefixesNeedingZero) {
      if (code.startsWith(prefix)) {
        return true;
      }
    }

    // Case 2: Check if barcode starts with '0' but should be 13 digits
    // This handles cases where Scandit removes a zero that should be kept
    if (code.startsWith('0') && code.length == 12) {
      // Common UPC prefixes that typically need leading zeros when converted to EAN-13
      final knownUpcPrefixes = [
        '043',
        '044',
        '045',
        '046',
        '047',
        '048',
        '049', // Your original prefixes
        '012',
        '013',
        '014',
        '015',
        '016',
        '017',
        '018',
        '019', // Common prefixes
        '020', '021', '022', '023', '024', '025', '026', '027', '028', '029',
        '030', '031', '032', '033', '034', '035', '036', '037', '038', '039',
        '040', '041', '042', // Additional prefixes
        '050', '051', '052', '053', '054', '055', '056', '057', '058', '059',
        '060', '061', '062', '063', '064', '065', '066', '067', '068', '069',
        '070', '071', '072', '073', '074', '075', '076', '077', '078', '079',
        '080', '081', '082', '083', '084', '085', '086', '087', '088', '089',
        '090', '091', '092', '093', '094', '095', '096', '097', '098', '099',
        '100', '101', '102', '103', '104', '105', '106', '107', '108', '109',
        '110', '111', '112', // More common prefixes
      ]; // Add your prefixes

      for (String prefix in knownUpcPrefixes) {
        if (code.startsWith(prefix)) {
          return true;
        }
      }
    }

    return false;
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
