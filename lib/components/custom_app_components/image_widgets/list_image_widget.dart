import 'dart:developer';
import 'dart:io';

import 'package:ansarlogistics/constants/methods.dart';
import 'package:ansarlogistics/constants/texts.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:picker_driver_api/picker_driver_api.dart';

class ListImageWidget extends StatelessWidget {
  String imageurl;
  ListImageWidget({super.key, required this.imageurl});

  @override
  Widget build(BuildContext context) {
    log('${mainimageurl}${imageurl}');

    return FutureBuilder<Map<String, dynamic>>(
      future: getData(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          Map<String, dynamic> data = snapshot.data!;
          log('${data['imagepath']}${imageurl}');
          // return CachedNetworkImage(
          //   imageUrl: '${data['imagepath']}${imageurl}',
          //   imageBuilder: (context, imageProvider) {
          //     return Container(
          //       decoration: BoxDecoration(
          //         image: DecorationImage(
          //           image: imageProvider,
          //           fit: BoxFit.cover,
          //         ),
          //       ),
          //     );
          //   },
          //   placeholder:
          //       (context, url) =>
          //           Center(child: Image.asset('assets/Iphone_spinner.gif')),
          //   errorWidget: (context, url, error) {
          //     return Image.network('${noimageurl}');
          //   },
          // );

          return CachedNetworkImage(
            imageUrl:
                'https://media-qatar.ansargallery.com/catalog/product/cache/6445c95191c1b7d36f6f846ddd0b49b3${imageurl}',
            httpHeaders: {
              'User-Agent':
                  'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
              'Referer':
                  'https://media-qatar.ansargallery.com/catalog/product/cache/6445c95191c1b7d36f6f846ddd0b49b3',
            },
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
              debugPrint('Failed to load image: $url, error: $error');
              return Image.asset('assets/placeholder.png', fit: BoxFit.cover);
            },
          );
        } else {
          return CachedNetworkImage(
            imageUrl: noimageurl,
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
              return Image.network('${mainimageurl}${imageurl}');
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
