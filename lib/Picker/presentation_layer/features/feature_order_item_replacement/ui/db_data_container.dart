import 'package:ansarlogistics/components/custom_app_components/buttons/counter_button.dart';
import 'package:ansarlogistics/constants/texts.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:ansarlogistics/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:picker_driver_api/responses/product_bd_data_response.dart';

class DbDataContainer extends StatefulWidget {
  ProductDBdata? productDBdata;
  Function(int) counterCallback;
  DbDataContainer({
    super.key,
    required this.productDBdata,
    required this.counterCallback,
  });

  @override
  State<DbDataContainer> createState() => _DbDataContainerState();
}

class _DbDataContainerState extends State<DbDataContainer> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(
          height: 275.0,
          width: 275.0,
          child:
              widget.productDBdata!.images != null &&
                      widget.productDBdata!.images != ""
                  ? Image.network(
                    '${mainimageurl}${getFirstImage(widget.productDBdata!.images)}',
                    fit: BoxFit.fill,
                  )
                  : Image.network(noimageurl, fit: BoxFit.fill),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Container(
            decoration: BoxDecoration(color: Colors.white),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + price row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name
                      Expanded(
                        child: Text(
                          widget.productDBdata!.skuName,
                          style: customTextStyle(
                            fontStyle: FontStyle.HeaderXS_Bold,
                            color: FontColor.FontPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Price block
                      _buildPriceBlock(widget.productDBdata!),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // SKU row
                  Text(
                    "SKU: ${widget.productDBdata!.sku}",
                    style: customTextStyle(
                      fontStyle: FontStyle.BodyS_Regular,
                      color: FontColor.FontSecondary,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Optional: small divider
                  Divider(
                    color: customColors().backgroundTertiary.withOpacity(0.5),
                  ),

                  // Quantity selector for non‑produce items
                  if (widget.productDBdata?.isProduce == "0")
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12.0,
                        horizontal: 4.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'Quantity',
                            style: customTextStyle(
                              fontStyle: FontStyle.BodyM_Bold,
                              color: FontColor.FontPrimary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          SizedBox(
                            width:
                                100, // adjust as you like (120–160 works well)
                            child: CounterDropdown(
                              initNumber: 0,
                              counterCallback: widget.counterCallback,
                              maxNumber: 500, // see next section
                              minNumber: 0,
                              showLabel: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceBlock(ProductDBdata data) {
    final hasSpecial =
        (data.specialPrice != null && data.specialPrice.toString().isNotEmpty);

    final double regular = double.tryParse(data.regularPrice.toString()) ?? 0.0;
    final double? special =
        hasSpecial ? double.tryParse(data.specialPrice.toString()) : null;

    if (hasSpecial && special != null && special > 0) {
      // Regular + special price
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Regular price, strikethrough
          Text(
            'QAR ${regular.toStringAsFixed(2)}',
            style: customTextStyle(
              fontStyle: FontStyle.BodyS_Regular,
              color: FontColor.FontSecondary,
            ).copyWith(decoration: TextDecoration.lineThrough),
          ),
          const SizedBox(height: 2),
          // Special price highlighted
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: customColors().adBackground,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'QAR ${special.toStringAsFixed(2)}',
              style: customTextStyle(
                fontStyle: FontStyle.BodyM_Bold,
                color: FontColor.Danger, // or FontColor.Info if you prefer
              ),
            ),
          ),
        ],
      );
    } else {
      // Only regular price
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'QAR ${regular.toStringAsFixed(2)}',
            style: customTextStyle(
              fontStyle: FontStyle.HeaderXS_Bold,
              color: FontColor.FontPrimary,
            ),
          ),
        ],
      );
    }
  }
}
