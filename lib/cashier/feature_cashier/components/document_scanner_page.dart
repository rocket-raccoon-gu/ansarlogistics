import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class DocumentScanSelection {
  const DocumentScanSelection({required this.imagePaths});

  final List<String> imagePaths;
}

class DocumentScannerPage extends StatefulWidget {
  const DocumentScannerPage({super.key});

  @override
  State<DocumentScannerPage> createState() => _DocumentScannerPageState();
}

class _DocumentScannerPageState extends State<DocumentScannerPage> {
  bool _isScanning = false;
  List<String> _scannedImages = [];
  String? _errorMessage;

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

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Capture POS Bill')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isScanning ? null : _captureImageWithCamera,
                icon:
                    _isScanning
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Icon(Icons.camera_alt),
                label: Text(
                  _isScanning ? 'Opening camera...' : 'Capture image',
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
                    ? const Center(child: Text('No image captured yet'))
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
