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

    _context = DataCaptureContext.forLicenseKey(scankey);

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

    _barcodeCapture = BarcodeCapture.forContext(_context, settings);
    _barcodeCapture.addListener(this);
    _barcodeCapture.isEnabled = true;

    _captureView = DataCaptureView.forContext(_context);

    /// ----------- HIGHLIGHT BARCODE HERE ------------
    final overlay = BarcodeCaptureOverlay.withBarcodeCapture(_barcodeCapture);

    // Viewfinder — focus area on screen
    overlay.viewfinder = RectangularViewfinder();

    // Brush — the highlight color
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
    final code = barcode.data;
    if (code == null || code.isEmpty) return;

    _handled = true;

    // Disable scanning so no more barcodes get scanned
    _barcodeCapture.isEnabled = false;

    Future.delayed(const Duration(milliseconds: 350), () {
      // Freeze camera view (optional)
      _camera.switchToDesiredState(FrameSourceState.standby);

      if (mounted) {
        Navigator.pop(context, code);
      }
    });
  }

  @override
  void dispose() {
    _barcodeCapture.removeListener(this);
    _camera.switchToDesiredState(FrameSourceState.off);
    super.dispose();
  }

  @override
  void didUpdateSession(
    BarcodeCapture barcodeCapture,
    BarcodeCaptureSession session,
  ) {
    // TODO: implement didUpdateSession
  }
}
