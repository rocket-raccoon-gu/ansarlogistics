import 'package:ansarlogistics/constants/methods.dart';
import 'package:flutter/material.dart';

class TranslatedText extends StatelessWidget {
  String text;
  TextStyle? style;
  int? maxLines;
  bool? softWrap;
  TextOverflow? overflow;
  TranslatedText({
    super.key,
    required this.text,
    this.style,
    this.maxLines,
    this.softWrap,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: getTranslateto(text),
      builder: (context, snaoshot) {
        return Text(
          snaoshot.data ?? text,
          style: style,
          maxLines: maxLines,
          softWrap: softWrap,
          overflow: overflow,
        );
      },
    );
  }
}
