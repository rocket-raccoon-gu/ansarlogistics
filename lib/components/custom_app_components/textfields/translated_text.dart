import 'dart:developer';

import 'package:ansarlogistics/constants/methods.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:ansarlogistics/user_controller/user_controller.dart';
import 'package:ansarlogistics/utils/preference_utils.dart';
import 'package:flutter/material.dart';

class TranslatedText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final int? maxLines;
  final bool? softWrap;
  final TextOverflow? overflow;
  final TextAlign? textAlign;

  const TranslatedText({
    super.key,
    required this.text,
    this.style,
    this.maxLines,
    this.softWrap,
    this.overflow,
    this.textAlign,
  });

  @override
  State<TranslatedText> createState() => _TranslatedTextState();
}

class _TranslatedTextState extends State<TranslatedText> {
  static final _translations = <String, String>{};

  late Future<String?> _translationFuture;

  @override
  void initState() {
    super.initState();
    // Check cache first

    // trnslatedatacheck();

    if (UserController.userController.translationCache.containsKey(
      widget.text,
    )) {
      _translationFuture = Future.value(
        UserController.userController.translationCache[widget.text],
      );
    } else {
      _translationFuture = getTranslateto(widget.text).then((translation) {
        UserController.userController.translationCache[widget.text] =
            translation ?? widget.text;
        return translation;
      });
    }
  }

  // trnslatedatacheck() async {
  //   String? langval = await PreferenceUtils.getDataFromShared('language');

  //   if (_translations["lang"] == langval) {
  //     _translations.addAll({"lang": langval!});
  //   } else {
  //     _translationCache.clear();
  //     _translations.addAll({"lang": langval!});
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _translationFuture,
      initialData:
          UserController.userController.translationCache[widget
              .text], // Use cached if available
      builder: (context, snapshot) {
        return Text(
          snapshot.data ?? widget.text,
          style: widget.style,
          maxLines: widget.maxLines,
          softWrap: widget.softWrap,
          overflow: widget.overflow,
        );
      },
    );
  }
}

class TranslatedTextSpan extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final int? maxLines;
  final bool? softWrap;
  final TextOverflow? overflow;

  const TranslatedTextSpan({
    super.key,
    required this.text,
    this.style,
    this.maxLines,
    this.softWrap,
    this.overflow,
  });

  @override
  State<TranslatedTextSpan> createState() => _TranslatedTextStateSpan();
}

class _TranslatedTextStateSpan extends State<TranslatedTextSpan> {
  static final _translations = <String, String>{};

  late Future<String?> _translationFuture;

  @override
  void initState() {
    super.initState();
    // Check cache first

    // trnslatedatacheck();

    if (UserController.userController.translationCache.containsKey(
      widget.text,
    )) {
      _translationFuture = Future.value(
        UserController.userController.translationCache[widget.text],
      );
    } else {
      _translationFuture = getTranslateto(widget.text).then((translation) {
        UserController.userController.translationCache[widget.text] =
            translation ?? widget.text;
        return translation;
      });
    }
  }

  // trnslatedatacheck() async {
  //   String? langval = await PreferenceUtils.getDataFromShared('language');

  //   if (_translations["lang"] == langval) {
  //     _translations.addAll({"lang": langval!});
  //   } else {
  //     _translationCache.clear();
  //     _translations.addAll({"lang": langval!});
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _translationFuture,
      initialData:
          UserController.userController.translationCache[widget
              .text], // Use cached if available
      builder: (context, snapshot) {
        return RichText(
          text: TextSpan(
            text: "Comment",
            style: customTextStyle(fontStyle: FontStyle.Inter_Light),
            children: [
              TextSpan(
                text: snapshot.data ?? getTranslateWord11(widget.text),
                style: customTextStyle(
                  fontStyle: FontStyle.Inter_Medium,
                  color: FontColor.FontPrimary,
                ),
              ),
            ],
          ),
        );
        // return Text(
        //   snapshot.data ?? widget.text,
        //   style: widget.style,
        //   maxLines: widget.maxLines,
        //   softWrap: widget.softWrap,
        //   overflow: widget.overflow,
        // );
      },
    );
  }
}
