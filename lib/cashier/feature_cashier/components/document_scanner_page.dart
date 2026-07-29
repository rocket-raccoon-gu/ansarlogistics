import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';

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
  late final DocumentScanner _documentScanner;

  bool _isScanning = false;
  List<String> _scannedImages = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    final options = DocumentScannerOptions(
      documentFormats: const {DocumentFormat.jpeg},
      mode: ScannerMode.filter,
      pageLimit: 5,
      isGalleryImport: true,
    );

    _documentScanner = DocumentScanner(options: options);

    // Automatically start scanning when the page opens.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _scanDocument();
    });
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

      final selection = DocumentScanSelection(
        imagePaths: result.images ?? const [],
      );

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
    _documentScanner.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Document Scanner')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isScanning ? null : _scanDocument,
                icon:
                    _isScanning
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Icon(Icons.document_scanner),
                label: Text(
                  _isScanning ? 'Opening scanner...' : 'Scan document',
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
                    ? const Center(child: Text('No scanned document'))
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
