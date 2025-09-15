import 'package:ansarlogistics/components/custom_app_components/textfields/translated_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class DriverSummeryPage extends StatefulWidget {
  const DriverSummeryPage({super.key});

  @override
  State<DriverSummeryPage> createState() => _DriverSummeryPageState();
}

class _DriverSummeryPageState extends State<DriverSummeryPage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      // child: Text("Coming Soon...!"),
      child: TranslatedText(text: "Coming Soon....!"),
    );
  }
}
