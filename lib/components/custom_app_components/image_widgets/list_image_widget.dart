import 'dart:developer';
import 'dart:io';

import 'package:ansarlogistics/constants/methods.dart';
import 'package:ansarlogistics/constants/texts.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:ansarlogistics/utils/preference_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:picker_driver_api/picker_driver_api.dart';

class ListImageWidget extends StatelessWidget {
  String imageurl;
  ListImageWidget({super.key, required this.imageurl});

  @override
  Widget build(BuildContext context) {
    // log('${mainimageurl}${imageurl}');

    return FutureBuilder<List<dynamic>>(
      future: Future.wait([
        getData(), // Firestore document
        PreferenceUtils.getDataFromShared('region'), // e.g. 'UAE', 'QA', ...
      ]),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final data = snapshot.data![0] as Map<String, dynamic>;
          final region = snapshot.data![1] as String?;

          // Choose which key to use based on region
          final imageKey = region == 'UAE' ? 'imagepathuae' : 'imagepath';

          return CachedNetworkImage(
            imageUrl: '${data[imageKey]}$imageurl',
            imageBuilder: (context, imageProvider) {
              return Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
            placeholder:
                (context, url) =>
                    Center(child: Image.asset('assets/Iphone_spinner.gif')),
            errorWidget: (context, url, error) {
              return Image.network('$noimageurl');
            },
          );
        } else {
          // keep your existing fallback
          return CachedNetworkImage(
            imageUrl: '$noimageurl',
            imageBuilder: (context, imageProvider) {
              return Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
            placeholder:
                (context, url) =>
                    Center(child: Image.asset('assets/Iphone_spinner.gif')),
            errorWidget: (context, url, error) {
              return Image.network('${mainimageurl}$imageurl');
            },
          );
        }
      },
    );
  }
}

class DottedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint =
        Paint()
          ..color = customColors().fontTertiary
          ..strokeWidth = 1.0
          ..style = PaintingStyle.stroke;

    final double dashWidth = 3.0;
    final double dashSpace = 3.0;
    double currentX = 0.0;

    while (currentX < size.width) {
      canvas.drawLine(
        Offset(currentX, size.height),
        Offset(currentX + dashWidth, size.height),
        paint,
      );
      currentX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
