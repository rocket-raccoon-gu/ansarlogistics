import 'package:ansarlogistics/app_page_injectable.dart';
import 'package:ansarlogistics/constants/methods.dart';
import 'package:flutter/material.dart';
import 'package:picker_driver_api/responses/orders_new_response.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ansarlogistics/utils/utils.dart';
import 'package:ansarlogistics/themes/style.dart';

class ItemTile extends StatelessWidget {
  final OrderItemNew item;
  final String preparationLabel;
  const ItemTile({
    super.key,
    required this.item,
    required this.preparationLabel,
  });

  @override
  Widget build(BuildContext context) {
    final rawImg = item.productImage;
    final imgPath =
        (rawImg == null || rawImg.isEmpty) ? '' : getFirstImage(rawImg);
    final resolved = resolveImageUrl(imgPath);
    return GestureDetector(
      onTap: () {
        context.gNavigationService.openOrderItemDetailsPage(
          context,
          arg: {'itemNew': item, 'preparationLabel': preparationLabel},
        );
      },
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: customColors().backgroundTertiary),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: customColors().backgroundSecondary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: CachedNetworkImage(
                imageUrl: resolved,
                imageBuilder:
                    (context, imageProvider) => Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                placeholder:
                    (context, url) =>
                        const Center(child: CircularProgressIndicator()),
                errorWidget:
                    (context, url, error) =>
                        const Icon(Icons.error, color: Colors.red),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name ?? '-',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: customTextStyle(
                      fontStyle: FontStyle.BodyM_Bold,
                      color: FontColor.FontPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'SKU: ${item.sku ?? '-'}',
                    style: customTextStyle(
                      fontStyle: FontStyle.BodyS_Regular,
                      color: FontColor.FontSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Builder(
                    builder: (_) {
                      final bool isProduce = item.isProduce == true;
                      final Color borderColor =
                          isProduce ? green500 : HexColor('#2D7EFF');
                      final Color textColor = borderColor;

                      num? priceNum;
                      if (item.price != null) {
                        priceNum = num.tryParse(item.price!.trim());
                      }

                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10.0,
                          vertical: 4.0,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(color: borderColor, width: 1.5),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isProduce) ...[
                              Container(
                                width: 18,
                                height: 18,
                                decoration: BoxDecoration(
                                  color: borderColor,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.scale,
                                  size: 12,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 6),
                            ],
                            Text(
                              priceNum != null
                                  ? 'QAR ${priceNum.toStringAsFixed(2)}'
                                  : (item.price == null || item.price!.isEmpty
                                      ? '—'
                                      : 'QAR ${item.price}'),
                              style: customTextStyle(
                                fontStyle: FontStyle.BodyS_Bold,
                                color: FontColor.Info,
                              ).copyWith(color: textColor),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: HexColor('#D66435'),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '0/${double.parse(item.qtyOrdered.toString()).toInt()}',
                style: customTextStyle(
                  fontStyle: FontStyle.BodyS_Bold,
                  color: FontColor.White,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
