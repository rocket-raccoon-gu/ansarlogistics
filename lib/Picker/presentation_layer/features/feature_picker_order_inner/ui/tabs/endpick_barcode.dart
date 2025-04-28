import 'package:ansarlogistics/themes/style.dart';
import 'package:flutter/material.dart';

class EndpickBarcode extends StatefulWidget {
  const EndpickBarcode({super.key});

  @override
  State<EndpickBarcode> createState() => _EndpickBarcodeState();
}

class _EndpickBarcodeState extends State<EndpickBarcode> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset("assets/barcode.png", height: 150, fit: BoxFit.fitWidth),
        Container(
          margin: EdgeInsets.all(20.0),
          child: Text(
            "12365412",
            textAlign: TextAlign.center,
            style: customTextStyle(
              fontStyle: FontStyle.BodyL_Bold,
              color: FontColor.CarnationRed,
            ),
          ),
        ),
      ],
    );
  }
}
