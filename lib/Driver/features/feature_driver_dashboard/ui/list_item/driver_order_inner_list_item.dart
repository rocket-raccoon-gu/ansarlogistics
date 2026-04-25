import 'package:ansarlogistics/components/custom_app_components/image_widgets/list_image_widget.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:flutter/material.dart';
import 'package:picker_driver_api/responses/order_response.dart';

class DriverOrderInnerListItem extends StatelessWidget {
  EndPicking orderItem;
  DriverOrderInnerListItem({super.key, required this.orderItem});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 100.0,
              width: 100.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child:
                    orderItem.productImages.isNotEmpty
                        ? ListImageWidget(imageurl: orderItem.productImages[0])
                        : Container(
                          color: customColors().backgroundSecondary,
                          child: const Icon(
                            Icons.image_not_supported,
                            color: Colors.grey,
                            size: 40,
                          ),
                        ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    orderItem.productName,
                    style: customTextStyle(
                      fontStyle: FontStyle.BodyL_Bold,
                      color: FontColor.FontPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow("SKU", orderItem.productSku),
                  const SizedBox(height: 6),
                  _buildPriceRow(),
                  const SizedBox(height: 6),
                  _buildQuantityRow(),
                  const SizedBox(height: 8),
                  if (orderItem.branchName.isNotEmpty) ...[
                    _buildPickupRow(),
                    const SizedBox(height: 12),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: customColors().backgroundSecondary,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "$label : ",
            style: customTextStyle(
              fontStyle: FontStyle.BodyM_Bold,
              color: FontColor.FontTertiary,
            ),
          ),
          Text(
            value,
            style: customTextStyle(
              fontStyle: FontStyle.BodyM_Bold,
              color: FontColor.FontPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: customColors().backgroundSecondary,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Price : ",
            style: customTextStyle(
              fontStyle: FontStyle.BodyM_Bold,
              color: FontColor.FontTertiary,
            ),
          ),
          Text(
            double.parse(orderItem.price).toStringAsFixed(2),
            style: customTextStyle(
              fontStyle: FontStyle.BodyM_Bold,
              color: FontColor.FontPrimary,
            ),
          ),
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),

            child: Text(
              "QAR",
              style: customTextStyle(
                fontStyle: FontStyle.BodyM_Bold,
                color: FontColor.FontPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityRow() {
    final quantity =
        double.parse(orderItem.qtyOrdered).toInt() -
        double.parse(orderItem.qtyCanceled).toInt();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: customColors().backgroundSecondary,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Qty : ",
            style: customTextStyle(
              fontStyle: FontStyle.BodyL_Bold,
              color: FontColor.FontTertiary,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: customColors().primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: customColors().primary, width: 1),
            ),
            child: Text(
              quantity.toString(),
              style: customTextStyle(
                fontStyle: FontStyle.BodyM_Bold,
                color: FontColor.FontPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPickupRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: [
              Icon(Icons.location_on, size: 16, color: customColors().primary),
              const SizedBox(width: 6),
              Text(
                "Pickup From",
                style: customTextStyle(
                  fontStyle: FontStyle.BodyM_Bold,
                  color: FontColor.FontTertiary,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: customColors().primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: customColors().primary.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Text(
            orderItem.branchName,
            style: customTextStyle(
              fontStyle: FontStyle.BodyM_Bold,
              color: FontColor.FontPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
