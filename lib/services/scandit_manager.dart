import 'package:scandit_flutter_datacapture_core/scandit_flutter_datacapture_core.dart';
import 'package:scandit_flutter_datacapture_barcode/scandit_flutter_datacapture_barcode_capture.dart';

/// Global manager for Scandit DataCaptureContext to prevent Error 1028
class ScanditManager {
  static DataCaptureContext? _sharedContext;
  static String? _currentLicenseKey;
  static final Set<BarcodeCapture> _activeModes = {};

  /// Get or create a shared context for the given license key
  static DataCaptureContext getContext(String licenseKey) {
    if (_sharedContext == null || _currentLicenseKey != licenseKey) {
      // Clean up existing context if license key changed
      dispose();
      // _sharedContext = DataCaptureContext.forLicenseKey(licenseKey);
      _sharedContext = DataCaptureContext.forLicenseKey(licenseKey);
      _currentLicenseKey = licenseKey;
    }
    return _sharedContext!;
  }

  /// Register a barcode capture mode
  static void registerMode(BarcodeCapture mode) {
    _activeModes.add(mode);
  }

  /// Unregister a barcode capture mode
  static void unregisterMode(BarcodeCapture mode) {
    _activeModes.remove(mode);
    try {
      _sharedContext?.removeMode(mode);
    } catch (_) {}
  }

  /// Remove all modes from context (prevents Error 1028)
  static void removeAllModes() {
    try {
      _sharedContext?.removeAllModes();
    } catch (_) {}
    _activeModes.clear();
  }

  /// Dispose all resources
  static void dispose() {
    // Disable all active modes
    for (final mode in _activeModes) {
      try {
        mode.isEnabled = false;
        // Note: Listeners should be removed by the scanner page itself
        // We can't remove listeners here because we don't have reference to the listener
      } catch (_) {}
    }

    // Remove all modes from context
    removeAllModes();

    // Clear context
    _sharedContext = null;
    _currentLicenseKey = null;
  }

  /// Check if context is initialized
  static bool get isInitialized => _sharedContext != null;

  /// Get current license key
  static String? get currentLicenseKey => _currentLicenseKey;
}
