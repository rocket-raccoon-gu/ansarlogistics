import 'package:ansarlogistics/Driver/features/feature_driver_dashboard/ui/bottom_sheet/contact_customer_sheet.dart';
import 'package:ansarlogistics/Driver/features/feature_driver_dashboard/ui/bottom_sheet/view_direction_sheet.dart';
import 'package:ansarlogistics/app_page_injectable.dart';
import 'package:ansarlogistics/components/custom_app_components/scrollable_bottomsheet/schedular_sheet.dart';
import 'package:ansarlogistics/components/custom_app_components/scrollable_bottomsheet/scrollable_bottomsheet.dart';
import 'package:ansarlogistics/components/custom_app_components/textfields/translated_text.dart';
import 'package:ansarlogistics/constants/methods.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:flutter/material.dart';
import 'package:picker_driver_api/responses/driver_base_response.dart';

class DriverOrderListItem extends StatefulWidget {
  DataItem orderResponseItem;
  int index;
  Function() reschedulesuccess;
  DriverOrderListItem({
    super.key,
    required this.orderResponseItem,
    required this.index,
    required this.reschedulesuccess,
  });

  @override
  State<DriverOrderListItem> createState() => _DriverOrderListItemState();
}

class _DriverOrderListItemState extends State<DriverOrderListItem> {
  @override
  Widget build(BuildContext context) {
    final order = widget.orderResponseItem.order;
    final customer = widget.orderResponseItem.customer;
    final address = widget.orderResponseItem.address;
    final type = getType(widget.orderResponseItem);
    final typeColor = getTypeColor(type);
    final itemCount = widget.orderResponseItem.items.fold<int>(
      0,
      (sum, item) => sum + item.quantity,
    );
    final addressLine = [
      if (address.building.trim().isNotEmpty) 'Bldg ${address.building}',
      if (address.street.trim().isNotEmpty) address.street,
      if (address.zone.trim().isNotEmpty) 'Zone ${address.zone}',
      if (address.floor.trim().isNotEmpty) address.floor,
    ].join(', ');
    final isPrepaid = order.paymentMode.toUpperCase().contains('PREPAID');

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          context.gNavigationService.openDriverOrderInnerPage(
            context,
            arg: {'orderitem': widget.orderResponseItem},
          );
        },
        child: Dismissible(
          key: ValueKey(order.subgroupIdentifier),
          direction: DismissDirection.startToEnd,
          background: Container(
            decoration: BoxDecoration(
              color: customColors().pacificBlue,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Image.asset(
                  "assets/rescheduling.png",
                  height: 24,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                TranslatedText(
                  text: "Reschedule",
                  style: customTextStyle(
                    fontStyle: FontStyle.BodyM_Bold,
                    color: FontColor.White,
                  ),
                ),
              ],
            ),
          ),
          confirmDismiss: (direction) async {
            if (order.subgroupIdentifier.startsWith('EXP')) {
              schedularBottomSheets(
                context: context,
                inputwidget: OrderSchedulerDateRange(
                  orderid: order.subgroupIdentifier,
                  reschedulesuccess: widget.reschedulesuccess,
                ),
              );
            } else if (order.subgroupIdentifier.startsWith('NOL')) {
              schedularBottomSheets(
                context: context,
                inputwidget: OrderSchedulerNol(
                  mainorderid: order.subgroupIdentifier,
                  reschedulesuccess: widget.reschedulesuccess,
                ),
              );
            }
            return false;
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: typeColor.withOpacity(0.25)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: typeColor,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(15),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        type,
                        style: customTextStyle(
                          fontStyle: FontStyle.BodyS_Bold,
                          color: FontColor.White,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          order.subgroupIdentifier,
                          style: customTextStyle(
                            fontStyle: FontStyle.BodyL_Bold,
                            color: FontColor.White,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          getStatus(order.status).isNotEmpty
                              ? getStatus(order.status)
                              : order.status,
                          style: customTextStyle(
                            fontStyle: FontStyle.BodyS_Bold,
                            color: FontColor.White,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              customer.name.isNotEmpty
                                  ? customer.name
                                  : address.name,
                              style: customTextStyle(
                                fontStyle: FontStyle.BodyL_Bold,
                                color: FontColor.FontPrimary,
                              ),
                            ),
                          ),
                          Text(
                            getFormatedDate(order.deliveryFrom.toString()),
                            style: customTextStyle(
                              fontStyle: FontStyle.BodyS_Regular,
                              color: FontColor.FontSecondary,
                            ),
                          ),
                        ],
                      ),
                      if (customer.mobileNumber.trim().isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          customer.mobileNumber,
                          style: customTextStyle(
                            fontStyle: FontStyle.BodyM_Regular,
                            color: FontColor.FontSecondary,
                          ),
                        ),
                      ],
                      if (addressLine.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 16,
                              color: customColors().green3,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                addressLine,
                                style: customTextStyle(
                                  fontStyle: FontStyle.BodyM_Regular,
                                  color: FontColor.FontPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _infoChip(
                              isPrepaid ? 'Prepaid' : order.paymentMode,
                              isPrepaid
                                  ? customColors().secretGarden
                                  : customColors().dividentColor,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _infoChip(
                              '$itemCount item${itemCount == 1 ? '' : 's'}',
                              customColors().info,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          TranslatedText(
                            text: 'Collect',
                            style: customTextStyle(
                              fontStyle: FontStyle.BodyM_Regular,
                              color: FontColor.FontSecondary,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'QAR ${order.total.toStringAsFixed(2)}',
                            style: customTextStyle(
                              fontStyle: FontStyle.BodyL_Bold,
                              color: FontColor.FontPrimary,
                            ),
                          ),
                        ],
                      ),
                      if (order.deliveryNote.trim().isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: customColors().pTokenBackground,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.info_outline,
                                size: 16,
                                color: Colors.red,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  order.deliveryNote,
                                  style: customTextStyle(
                                    fontStyle: FontStyle.BodyM_SemiBold,
                                    color: FontColor.Danger,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (customer.mobileNumber.trim().isNotEmpty)
                            IconButton(
                              tooltip: 'Call Customer',
                              onPressed: () {
                                customShowModalBottomSheet(
                                  context: context,
                                  inputWidget: ContactCustomerSheet(
                                    orderResponseItem: widget.orderResponseItem,
                                  ),
                                );
                              },
                              icon: Icon(
                                Icons.phone_outlined,
                                color: customColors().green3,
                              ),
                            ),
                          IconButton(
                            tooltip: 'Directions',
                            onPressed: () {
                              customShowModalBottomSheet(
                                context: context,
                                inputWidget: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 12,
                                  ),
                                  child: ViewDirectionSheet(
                                    destinationlat: address.latitude,
                                    destinationlong: address.longitude,
                                  ),
                                ),
                              );
                            },
                            icon: Icon(
                              Icons.directions_outlined,
                              color: customColors().green3,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'View details',
                            style: customTextStyle(
                              fontStyle: FontStyle.BodyS_Bold,
                              color: FontColor.SecretGarden,
                            ),
                          ),
                          const Icon(Icons.chevron_right, size: 18),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
        style: customTextStyle(
          fontStyle: FontStyle.BodyS_Bold,
          color: FontColor.FontPrimary,
        ),
      ),
    );
  }

  void schedularBottomSheets({
    required BuildContext context,
    required inputwidget,
  }) {
    customShowModalBottomSheet(context: context, inputWidget: inputwidget);
  }
}
