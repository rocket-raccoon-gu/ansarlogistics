import 'dart:developer';

import 'package:ansarlogistics/app_page_injectable.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:ansarlogistics/user_controller/user_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:picker_driver_api/responses/orders_new_response.dart';

class PickerOrderListItem extends StatefulWidget {
  OrderNew orderResponseItem;
  int index;
  PickerOrderListItem({
    super.key,
    required this.orderResponseItem,
    required this.index,
  });

  @override
  State<PickerOrderListItem> createState() => _PickerOrderListItemState();
}

class _PickerOrderListItemState extends State<PickerOrderListItem> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // if (widget.orderResponseItem.status != "assigned_picker") {
        //   // context.gNavigationService.openPickerOrderDetailsPage(
        //   //   context,
        //   //   arg: {'orderitem': widget.orderResponseItem},
        //   // );

        //   context.gNavigationService.openPickerDashboardPage(
        //     context,
        //     arg: {
        //       "suborder_id": widget.orderResponseItem.subgroupIdentifier,
        //       "order_id": widget.orderResponseItem.id,
        //       "order_items": widget.orderResponseItem.items,
        //       "preparation_label": widget.orderResponseItem.subgroupIdentifier,
        //       "order": widget.orderResponseItem,
        //     },
        //   );
        // }

        if (widget.orderResponseItem.status != "assigned_picker") {
          final suborderStatuses =
              widget.orderResponseItem.suborderStatuses ?? {};
          final String suborderType =
              suborderStatuses.keys.isNotEmpty
                  ? suborderStatuses.keys.first
                  : '';

          context.gNavigationService.openPickerDashboardPage(
            context,
            arg: {
              "suborder_id": suborderType, // e.g. 'nol' or 'exp'
              "order_id": widget.orderResponseItem.id,
              "preparation_label": widget.orderResponseItem.subgroupIdentifier,
              "order": widget.orderResponseItem, // let root builder use this
            },
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: customColors().backgroundSecondary,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: customColors().backgroundTertiary),
        ),
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //     // Top: ID and Status Chip
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.badge_outlined,
                      size: 18,
                      color: customColors().fontPrimary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '#${widget.orderResponseItem.subgroupIdentifier ?? widget.orderResponseItem.id ?? '-'}',
                      style: customTextStyle(
                        fontStyle: FontStyle.BodyM_Bold,
                        color: FontColor.FontPrimary,
                      ),
                    ),
                  ],
                ),
                _StatusChip(
                  status: widget.orderResponseItem.status,
                  statusText: widget.orderResponseItem.statusText,
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Delivery Date
            Row(
              children: [
                Icon(
                  Icons.event_available_outlined,
                  size: 18,
                  color: customColors().fontPrimary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Delivery Date ${widget.orderResponseItem.deliveryDate ?? '-'}',
                  style: customTextStyle(
                    fontStyle: FontStyle.Inter_Medium,
                    color: FontColor.FontPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            // Time Range
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                widget.orderResponseItem.timeRange != null
                    ? Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 18,
                          color: customColors().fontPrimary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Time ${widget.orderResponseItem.timeRange ?? '-'}',
                          style: customTextStyle(
                            fontStyle: FontStyle.BodyS_Regular,
                            color: FontColor.FontPrimary,
                          ),
                        ),
                      ],
                    )
                    : const SizedBox(),

                Text(
                  '${widget.orderResponseItem.items.length} items',
                  style: customTextStyle(
                    fontStyle: FontStyle.BodyM_SemiBold,
                    color: FontColor.FontPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Bottom Banner
            if (widget.orderResponseItem.status == "assigned_picker")
              _BottomBanner(order: widget.orderResponseItem),

            if (widget.orderResponseItem.deliveryNote != null)
              CustomerBottomBanner(order: widget.orderResponseItem),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String? status; // e.g., assigned_picker, start_picking
  final String? statusText; // optional pretty text from API
  const _StatusChip({required this.status, this.statusText});

  @override
  Widget build(BuildContext context) {
    final colors = customColors();
    Color bg;
    String label;
    switch (status) {
      case 'start_picking':
      case 'Start Picking':
        bg = colors.info;
        label = 'Started Picking';
        break;
      case 'assigned_picker':
      case 'Assigned':
        bg = colors.secretGarden;
        label = 'Assigned Picker';
        break;
      case 'end_picking':
      case 'End Picking':
        bg = colors.mattPurple;
        label = 'End Picking';
        break;
      case 'holded':
      case 'Holded':
        bg = colors.warning;
        label = 'Holded';
        break;
      case 'material_request':
      case 'Material Request':
        bg = colors.danger;
        label = 'Material Request';
        break;
      case 'customer_not_answer':
      case 'Customer Not Answer':
        bg = colors.danger;
        label = 'Customer Not Answer';
        break;
      default:
        bg = colors.fontPrimary;
        label = status ?? '';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: customTextStyle(
          fontStyle: FontStyle.BodyS_Bold,
          color: FontColor.White,
        ),
      ),
    );
  }
}

class _BottomBanner extends StatelessWidget {
  final OrderNew order;
  const _BottomBanner({required this.order});

  @override
  Widget build(BuildContext context) {
    final colors = customColors();
    final isStarted = order.status != 'assigned_picker';
    return Container(
      decoration: BoxDecoration(
        color: colors.adBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.backgroundTertiary),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: colors.warning),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isStarted ? 'Orders being picked' : 'Ready to Start',
                  style: customTextStyle(
                    fontStyle: FontStyle.BodyS_Bold,
                    color: FontColor.FontPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isStarted
                      ? 'Complete picking on time'
                      : 'Swipe left to start picking.',
                  style: customTextStyle(
                    fontStyle: FontStyle.BodyS_Regular,
                    color: FontColor.FontSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          if (isStarted)
            // ElevatedButton(
            //   onPressed: () {
            //     // Navigate to status/details if needed
            //     context.gNavigationService.openPickerOrderInnerPage(
            //       context,
            //       arg: {'orderitem': order},
            //     );
            //   },
            //   style: ElevatedButton.styleFrom(
            //     backgroundColor: colors.fontPrimary,
            //     foregroundColor: Colors.white,
            //     padding: const EdgeInsets.symmetric(
            //       horizontal: 12,
            //       vertical: 8,
            //     ),
            //     shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(8),
            //     ),
            //   ),
            //   child: Text(
            //     'View Status',
            //     style: customTextStyle(
            //       fontStyle: FontStyle.BodyS_Bold,
            //       color: FontColor.White,
            //     ),
            //   ),
            // )
            SizedBox()
          else
            Icon(Icons.swipe_left, color: colors.warning),
        ],
      ),
    );
  }
}

class CustomerBottomBanner extends StatelessWidget {
  final OrderNew? order;
  const CustomerBottomBanner({required this.order});

  @override
  Widget build(BuildContext context) {
    final colors = customColors();
    return Container(
      decoration: BoxDecoration(
        color: colors.adBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.backgroundTertiary),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Icon(Icons.person, color: colors.warning),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Customer Saying',
                  style: customTextStyle(
                    fontStyle: FontStyle.BodyS_Bold,
                    color: FontColor.FontPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "\" ${order?.deliveryNote ?? ''} \" ",
                  style: customTextStyle(
                    fontStyle: FontStyle.BodyL_Bold,
                    color: FontColor.CarnationRed,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
