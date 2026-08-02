import 'dart:io';

import 'package:ansarlogistics/user_controller/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class DocumentScanSelection {
  const DocumentScanSelection({required this.imagePaths});

  final List<String> imagePaths;
}

bool shouldUseNormalCameraForBranch(String? branchCode) {
  final normalizedBranchCode = branchCode?.toString().trim().toUpperCase();
  return normalizedBranchCode == 'Q008';
}

class DocumentScannerPage extends StatefulWidget {
  const DocumentScannerPage({super.key});

  @override
  State<DocumentScannerPage> createState() => _DocumentScannerPageState();
}

class _DocumentScannerPageState extends State<DocumentScannerPage> {
  late final DocumentScanner _documentScanner;

  bool _isScanning = false;
  bool _useNormalCamera = false;
  List<String> _scannedImages = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    _useNormalCamera = shouldUseNormalCameraForBranch(
      UserController.userController.profile.branchCode,
    );

    if (!_useNormalCamera) {
      final options = DocumentScannerOptions(
        documentFormats: const {DocumentFormat.jpeg},
        mode: ScannerMode.filter,
        pageLimit: 5,
        isGalleryImport: true,
      );

      _documentScanner = DocumentScanner(options: options);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_useNormalCamera) {
        _captureImageWithCamera();
      } else {
        _scanDocument();
      }
    });
  }

  Future<String> _prepareImageForUpload(String sourcePath) async {
    final sourceFile = File(sourcePath);
    if (!sourceFile.existsSync()) {
      return sourcePath;
    }

    try {
      final tempDir = await getTemporaryDirectory();
      final targetPath =
          '${tempDir.path}/cashier_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        sourceFile.absolute.path,
        targetPath,
        quality: 95,
        minWidth: 1600,
        minHeight: 1600,
        format: CompressFormat.jpeg,
      );

      if (compressedFile != null && File(compressedFile.path).existsSync()) {
        return compressedFile.path;
      }
    } catch (_) {
      // Fall back to the original file on compression issues.
    }

    return sourcePath;
  }

  Future<void> _captureImageWithCamera() async {
    if (_isScanning) return;

    setState(() {
      _isScanning = true;
      _errorMessage = null;
    });

    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 100,
        requestFullMetadata: false,
      );

      if (!mounted) return;

      if (pickedFile == null) {
        setState(() {
          _errorMessage = 'No image was captured.';
          _scannedImages = const [];
        });
        return;
      }

      final preparedPath = await _prepareImageForUpload(pickedFile.path);
      final selection = DocumentScanSelection(imagePaths: [preparedPath]);

      setState(() {
        _scannedImages = selection.imagePaths;
      });

      Navigator.of(context).pop(selection);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
      }
    }
  }

  Future<void> _scanDocument() async {
    if (_isScanning) return;

    setState(() {
      _isScanning = true;
      _errorMessage = null;
    });

    try {
      final DocumentScanningResult result =
          await _documentScanner.scanDocument();

      if (!mounted) return;

      final imagePaths = <String>[];
      for (final imagePath in result.images ?? const []) {
        imagePaths.add(await _prepareImageForUpload(imagePath));
      }

      final selection = DocumentScanSelection(imagePaths: imagePaths);

      if (selection.imagePaths.isEmpty) {
        setState(() {
          _errorMessage = 'No document was returned from the scanner.';
          _scannedImages = const [];
        });
        return;
      }

      setState(() {
        _scannedImages = selection.imagePaths;
      });

      Navigator.of(context).pop(selection);
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
      }
    }
  }

  @override
  void dispose() {
    if (!_useNormalCamera) {
      _documentScanner.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_useNormalCamera ? 'Capture POS Bill' : 'Document Scanner'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed:
                    _isScanning
                        ? null
                        : (_useNormalCamera
                            ? _captureImageWithCamera
                            : _scanDocument),
                icon:
                    _isScanning
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : Icon(
                          _useNormalCamera
                              ? Icons.camera_alt
                              : Icons.document_scanner,
                        ),
                label: Text(
                  _isScanning
                      ? (_useNormalCamera
                          ? 'Opening camera...'
                          : 'Opening scanner...')
                      : (_useNormalCamera ? 'Capture image' : 'Scan document'),
                ),
              ),
            ),
          ),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          Expanded(
            child:
                _scannedImages.isEmpty
                    ? Center(
                      child: Text(
                        _useNormalCamera
                            ? 'No image captured yet'
                            : 'No scanned document',
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: _scannedImages.length,
                      itemBuilder: (context, index) {
                        final imagePath = _scannedImages[index];

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            children: [
                              Image.file(
                                File(imagePath),
                                width: double.infinity,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Padding(
                                    padding: EdgeInsets.all(20),
                                    child: Text(
                                      'Unable to display scanned image',
                                    ),
                                  );
                                },
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Text('Page ${index + 1}'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
