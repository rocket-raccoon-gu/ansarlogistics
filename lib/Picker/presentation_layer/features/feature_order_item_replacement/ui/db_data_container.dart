import 'package:ansarlogistics/components/custom_app_components/buttons/counter_button.dart';
import 'package:ansarlogistics/constants/texts.dart';
import 'package:ansarlogistics/constants/methods.dart';
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
          child: FutureBuilder<Map<String, dynamic>>(
            future: getData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError || !snapshot.hasData) {
                // Fallback to default no-image URL if Firestore fails
                return Image.network(noimageurl, fit: BoxFit.fill);
              }

              final Map<String, dynamic> data = snapshot.data!;
              final String base = (data['imagepath'] ?? '').toString().trim();

              final hasImages =
                  widget.productDBdata!.images != null &&
                  widget.productDBdata!.images!.isNotEmpty;

              if (!hasImages || base.isEmpty) {
                return Image.network(noimageurl, fit: BoxFit.fill);
              }

              final String firstImage =
                  getFirstImage(widget.productDBdata!.images).trim();

              // Ensure exactly one slash between base and path
              String resolve(String baseUrl, String path) {
                if (path.startsWith('http')) return path;
                String b = baseUrl;
                String p = path;
                if (b.endsWith('/') && p.startsWith('/')) {
                  p = p.substring(1);
                } else if (!b.endsWith('/') && !p.startsWith('/')) {
                  b = '$b/';
                }
                return '$b$p';
              }

              final String fullUrl = resolve(base, firstImage);

              return Image.network(fullUrl, fit: BoxFit.fill);
            },
          ),
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
                  // if (widget.productDBdata?.isProduce == "0")
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
                          width: 100, // adjust as you like (120–160 works well)
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
