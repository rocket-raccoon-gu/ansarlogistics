import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class WebsiteCashReader extends StatefulWidget {
  @override
  _WebsiteCashReaderState createState() => _WebsiteCashReaderState();
}

class _WebsiteCashReaderState extends State<WebsiteCashReader> {
  String websiteCashAmount = "";
  final ImagePicker _picker = ImagePicker();

  Future<void> _scanWebsiteCash() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile == null) return;

    final inputImage = InputImage.fromFile(File(pickedFile.path));
    final textRecognizer = TextRecognizer();
    final RecognizedText recognizedText = await textRecognizer.processImage(
      inputImage,
    );

    String extractedAmount = "";
    List<String> allLines = [];

    // Collect all text lines first
    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        allLines.add(line.text.trim());
        log(line.text);
      }
    }

    // Look for Website Cash pattern
    // Replace the search logic with this:
    for (int i = 0; i < allLines.length; i++) {
      String currentLine = allLines[i];

      if (currentLine.toLowerCase().contains("website cash") ||
          currentLine == "Website Cash /.") {
        // Look for the amount pattern in a specific range
        int startIndex = i + 1;
        int endIndex = min(i + 10, allLines.length);

        for (int j = startIndex; j < endIndex; j++) {
          String line = allLines[j];

          // Skip lines that are clearly not amounts
          if (line.contains("Keep the bill") ||
              line.contains("Exchange") ||
              line.length > 20)
            continue;

          final amountRegex = RegExp(r"-\d+\.\d+");
          final match = amountRegex.firstMatch(line);

          if (match != null) {
            extractedAmount = match.group(0)!;
            break;
          }
        }

        if (extractedAmount.isNotEmpty) break;
      }
    }
    setState(() {
      websiteCashAmount =
          extractedAmount.isEmpty ? "Not found" : extractedAmount;
    });

    textRecognizer.close();
  }

  String _extractAmountFromLine(String line) {
    // Look for negative amounts with decimal places
    final negativeRegex = RegExp(r"-\d+\.\d+");
    final negativeMatch = negativeRegex.firstMatch(line);
    if (negativeMatch != null) {
      return negativeMatch.group(0)!;
    }

    return "";
  }

  int min(int a, int b) => a < b ? a : b;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Website Cash Reader")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _scanWebsiteCash,
              child: Text("Scan Website Cash"),
            ),
            SizedBox(height: 20),
            Text(
              websiteCashAmount.isEmpty
                  ? "Scanning..."
                  : "Website Cash Amount: $websiteCashAmount",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
