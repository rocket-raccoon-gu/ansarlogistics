import 'package:ansarlogistics/Picker/presentation_layer/features/feature_orders/bloc/picker_orders_cubit.dart';
import 'package:ansarlogistics/app_page_injectable.dart';
import 'package:ansarlogistics/constants/methods.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:ansarlogistics/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:picker_driver_api/responses/orders_new_response.dart';

class IncompleteOrdersPage extends StatefulWidget {
  Map<String, dynamic> args;
  IncompleteOrdersPage({super.key, required this.args});

  @override
  State<IncompleteOrdersPage> createState() => _IncompleteOrdersPageState();
}

class _IncompleteOrdersPageState extends State<IncompleteOrdersPage> {
  @override
  Widget build(BuildContext context) {
    final GroupedProduct product = widget.args['product'] as GroupedProduct;
    final List<ProductOrders> orders = product.orders;
    final List<OrderNew> ordersNew = widget.args['ordersNew'] as List<OrderNew>;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0.0),
        child: AppBar(elevation: 0, backgroundColor: HexColor('#F9FBFF')),
      ),
      backgroundColor: customColors().backgroundPrimary,
      body: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.symmetric(
              vertical: 10.0,
              horizontal: 10.0,
            ),
            decoration: BoxDecoration(
              color: HexColor('#F9FBFF'),
              border: Border(
                bottom: BorderSide(
                  width: 2.0,
                  color: customColors().backgroundTertiary,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: customColors().backgroundTertiary.withOpacity(1.0),
                  spreadRadius: 3,
                  blurRadius: 5,
                  // offset: Offset(0, 3), // changes the position of the shadow
                ),
              ],
            ),

            child: Container(
              height: 35.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(
                      Icons.arrow_back,
                      size: 25,
                      color: HexColor("#A3A3A3"),
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Incomplete Orders",
                          style: customTextStyle(
                            fontStyle: FontStyle.Lato_Bold,
                            color: FontColor.FontPrimary,
                          ),
                        ),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18.0,
                            vertical: 5.0,
                          ),
                          child: Row(children: []),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Builder(
              builder: (_) {
                String firstImage(String? productImages) {
                  if (productImages == null || productImages.isEmpty) return '';
                  final parts = productImages.split(',');
                  return parts.first.trim();
                }

                final resolvedImage = resolveImageUrl(
                  (product.productImages != null &&
                          product.productImages!.isNotEmpty)
                      ? firstImage(product.productImages)
                      : (product.imageUrl ?? ''),
                );

                return Container(
                  decoration: BoxDecoration(
                    color: customColors().backgroundSecondary,
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(
                      color: customColors().backgroundTertiary,
                    ),
                  ),
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child:
                                resolvedImage.isNotEmpty
                                    ? Image.network(
                                      resolvedImage,
                                      width: 64,
                                      height: 64,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (_, __, ___) => Image.asset(
                                            'assets/ansar-logistics.png',
                                            width: 64,
                                            height: 64,
                                            fit: BoxFit.cover,
                                          ),
                                    )
                                    : Image.asset(
                                      'assets/ansar-logistics.png',
                                      width: 64,
                                      height: 64,
                                      fit: BoxFit.cover,
                                    ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        product.name ?? '-',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: customTextStyle(
                                          fontStyle: FontStyle.BodyM_Bold,
                                          color: FontColor.FontPrimary,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10.0,
                                        vertical: 4.0,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.transparent,
                                        borderRadius: BorderRadius.circular(
                                          8.0,
                                        ),
                                        border: Border.all(
                                          color: HexColor('#2D7EFF'),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Text(
                                        product.price != null
                                            ? 'QAR ${(product.price as num).toStringAsFixed(2)}'
                                            : '—',
                                        style: customTextStyle(
                                          fontStyle: FontStyle.BodyS_Bold,
                                          color: FontColor.Info,
                                        ).copyWith(color: HexColor('#2D7EFF')),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'SKU: ${product.sku ?? '-'}',
                                  style: customTextStyle(
                                    fontStyle: FontStyle.BodyS_Regular,
                                    color: FontColor.FontSecondary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0,
                                    vertical: 10.0,
                                  ),
                                  decoration: BoxDecoration(
                                    color: HexColor('#F39D5E'),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Text(
                                    'Picked 0/${product.totalQuantity ?? 0} items',
                                    textAlign: TextAlign.center,
                                    style: customTextStyle(
                                      fontStyle: FontStyle.BodyS_Bold,
                                      color: FontColor.White,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Warning banner
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 12.0,
                        ),
                        decoration: BoxDecoration(
                          color: HexColor('#FFF1E6'),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              color: HexColor('#D66435'),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'This item is missing from following orders',
                                style: customTextStyle(
                                  fontStyle: FontStyle.BodyS_Bold,
                                  color: FontColor.FontPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Orders list
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              itemCount: orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final o = orders[index]; // ProductOrders
                final dateStr = formatDate(
                  o.deliveryDate,
                ); // DateTime -> formatted

                void openDetails() {
                  OrderNew? match;
                  try {
                    match = ordersNew.firstWhere(
                      (e) => e.id?.toString() == o.orderId.toString(),
                      orElse:
                          () => ordersNew.firstWhere(
                            (e) =>
                                (e.subgroupIdentifier ?? '') ==
                                o.subgroupIdentifier,
                          ),
                    );
                  } catch (_) {
                    match = null;
                  }

                  if (match != null) {
                    context.gNavigationService.openPickerOrderDetailsPage(
                      context,
                      arg: {'orderitem': match},
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Order details not found for #${o.orderId}',
                        ),
                      ),
                    );
                  }
                }

                return InkWell(
                  onTap: openDetails,
                  child: Container(
                    decoration: BoxDecoration(
                      color: customColors().backgroundSecondary,
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(
                        color: customColors().backgroundTertiary,
                      ),
                    ),
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.local_mall_outlined,
                                  color: HexColor('#2D7EFF'),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'ID  #${o.orderId}',
                                  style: customTextStyle(
                                    fontStyle: FontStyle.BodyM_SemiBold,
                                    color: FontColor.FontPrimary,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                                vertical: 4.0,
                              ),
                              decoration: BoxDecoration(
                                color: HexColor('#E76E3C'),
                                borderRadius: BorderRadius.circular(6.0),
                              ),
                              child: Text(
                                '0/${o.quantity}',
                                style: customTextStyle(
                                  fontStyle: FontStyle.BodyS_Bold,
                                  color: FontColor.White,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.event_available_outlined,
                              color: HexColor('#28A745'),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Delivery Date  $dateStr',
                              style: customTextStyle(
                                fontStyle: FontStyle.BodyS_Regular,
                                color: FontColor.FontPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.access_time, color: HexColor('#6F42C1')),
                            const SizedBox(width: 6),
                            Text(
                              'Time Range  ${o.timeRange ?? '-'}',
                              style: customTextStyle(
                                fontStyle: FontStyle.BodyS_Regular,
                                color: FontColor.FontPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              // TODO: Hook to pick flow for this order/item

                              // 1) Flatten all OrderItemNew from the loaded orders
                              final List<OrderItemNew> allItems =
                                  ordersNew.expand((e) => e.items).toList();

                              // 2) Locate the matching item by itemId from ProductOrders (o.itemId)
                              OrderItemNew? itemNew;
                              try {
                                itemNew = allItems.firstWhere(
                                  (it) => (it.id ?? '') == o.itemId.toString(),
                                );
                              } catch (_) {
                                itemNew = null;
                              }

                              if (itemNew == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Unable to locate item ${o.itemId} in loaded orders',
                                    ),
                                  ),
                                );
                                return;
                              }

                              // 3) Navigate to Order Item Details page
                              //    Include:
                              //    - itemNew: the matched item
                              //    - preparationLabel: use subgroupIdentifier from ProductOrders
                              //    - itemIds: pass GroupedProduct.itemIds as requested
                              context.gNavigationService
                                  .openOrderItemDetailsPage(
                                    context,
                                    arg: {
                                      'itemNew': itemNew,
                                      'preparationLabel': o.orderId,
                                      'itemid': o.itemId,
                                      'from': 'incomplete_orders',
                                    },
                                  );
                            },

                            style: ElevatedButton.styleFrom(
                              backgroundColor: HexColor('#D66435'),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                vertical: 12.0,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            child: Text(
                              'Pick this item',
                              style: customTextStyle(
                                fontStyle: FontStyle.BodyM_Bold,
                                color: FontColor.White,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Footer button
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  // TODO: Navigate to overall list if needed
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  side: BorderSide(color: customColors().backgroundTertiary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  backgroundColor: customColors().backgroundSecondary,
                  foregroundColor: customColors().backgroundTertiary,
                ),
                child: Text(
                  'VIEW ALL ITEMS TO PICK',
                  style: customTextStyle(
                    fontStyle: FontStyle.BodyM_Bold,
                    color: FontColor.FontPrimary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
