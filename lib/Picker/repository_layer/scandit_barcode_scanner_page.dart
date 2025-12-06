import 'package:flutter/material.dart';
import 'package:scandit_flutter_datacapture_barcode/scandit_flutter_datacapture_barcode.dart';
import 'package:scandit_flutter_datacapture_barcode/scandit_flutter_datacapture_barcode_capture.dart';
import 'package:scandit_flutter_datacapture_barcode/scandit_flutter_datacapture_spark_scan.dart';
import 'package:scandit_flutter_datacapture_core/scandit_flutter_datacapture_core.dart';
import 'package:ansarlogistics/constants/texts.dart';

class ScanditBarcodeScannerPage extends StatefulWidget {
  const ScanditBarcodeScannerPage({super.key});

  @override
  State<ScanditBarcodeScannerPage> createState() =>
      _ScanditBarcodeScannerPageState();
}

class _ScanditBarcodeScannerPageState extends State<ScanditBarcodeScannerPage>
    implements SparkScanListener {
  late final DataCaptureContext _context;
  late final Camera _camera;
  late final BarcodeCapture _barcodeCapture;
  bool _handled = false;

  late SparkScan _sparkScan;

  late final SparkScanViewSettings _viewSettings;

  @override
  void initState() {
    super.initState();
    _context = DataCaptureContext.forLicenseKey(scankey);

    final settings = SparkScanSettings();
    settings.enableSymbologies({
      Symbology.ean13Upca,
      Symbology.ean8,
      Symbology.upce,
      Symbology.code39,
      Symbology.code128,
      Symbology.interleavedTwoOfFive,
    });
    final symbologySettings = settings.settingsForSymbology(Symbology.code39);
    symbologySettings.activeSymbolCounts = {
      7,
      8,
      9,
      10,
      11,
      12,
      13,
      14,
      15,
      16,
      17,
      18,
      19,
      20,
    };

    _sparkScan = SparkScan.withSettings(settings);
    _sparkScan.addListener(this);

    _viewSettings = SparkScanViewSettings();
  }

  @override
  void dispose() {
    _sparkScan.removeListener(this);
    super.dispose();
  }

  @override
  Future<void> didScan(
    SparkScan sparkScan,
    SparkScanSession session,
    Future<FrameData> Function() getFrameData,
  ) async {
    final barcode = session.newlyRecognizedBarcode;
    if (barcode?.data == null || barcode!.data!.isEmpty) return;
    if (!mounted) return;
    Navigator.of(context).pop<String>(barcode.data);
  }

  @override
  Widget build(BuildContext context) {
    final view = SparkScanView.forContext(
      Container(),
      _context,
      _sparkScan,
      _viewSettings,
    );

    return Scaffold(body: SafeArea(child: view));
  }

  @override
  void didUpdateSession(
    SparkScan sparkScan,
    SparkScanSession session,
    Future<FrameData> Function() getFrameData,
  ) {
    // TODO: implement didUpdateSession
  }

  // implement other listener methods as empty bodies
}
