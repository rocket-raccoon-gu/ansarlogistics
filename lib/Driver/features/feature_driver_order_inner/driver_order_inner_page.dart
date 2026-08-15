import 'package:ansarlogistics/Driver/features/feature_driver_dashboard/ui/list_item/driver_order_inner_list_item.dart';
import 'package:ansarlogistics/Driver/features/feature_driver_order_inner/bloc/driver_order_inner_page_cubit.dart';
import 'package:ansarlogistics/Driver/features/feature_driver_order_inner/bloc/driver_order_inner_page_state.dart';
import 'package:ansarlogistics/Driver/features/feature_driver_order_inner/ui/driver_customer_details_sheet.dart';
import 'package:ansarlogistics/app_page_injectable.dart';
import 'package:ansarlogistics/constants/methods.dart';
import 'package:ansarlogistics/components/custom_app_components/app_bar/order_inner_app_bar_driver.dart';
import 'package:ansarlogistics/components/custom_app_components/buttons/basket_button.dart';
import 'package:ansarlogistics/components/custom_app_components/buttons/swipe_button.dart';
import 'package:ansarlogistics/components/loading_indecator.dart';
import 'package:ansarlogistics/services/service_locator.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:picker_driver_api/responses/driver_base_response.dart';

class DriverOrderInnerPage extends StatefulWidget {
  DataItem orderResponseItem;
  ServiceLocator serviceLocator;
  DriverOrderInnerPage({
    super.key,
    required this.orderResponseItem,
    required this.serviceLocator,
  });

  @override
  State<DriverOrderInnerPage> createState() => _DriverOrderInnerPageState();
}

class _DriverOrderInnerPageState extends State<DriverOrderInnerPage> {
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return BlocConsumer<DriverOrderInnerPageCubit, DriverOrderInnerPageState>(
      listener: (context, state) {
        if (state is DriverOrderInitialErrorState ||
            state is DriverOrderInitialPageState) {
          setState(() {
            loading = false;
          });
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: customColors().backgroundPrimary,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(0.0),
            child: AppBar(elevation: 0, backgroundColor: HexColor('#F9FBFF')),
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: OrderInnerAppBarDriver(
                  onTapBack: () {
                    context.gNavigationService.back(context);
                  },
                  orderResponseItem: widget.orderResponseItem,
                  onTapinfo: () {
                    showDriverCustomerTopModel(
                      context,
                      widget.serviceLocator,
                      widget.orderResponseItem,
                    );
                  },
                ),
              ),
              if (isReturnOrder(widget.orderResponseItem))
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: HexColor('#FFF7ED'),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: HexColor('#D97706')),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.assignment_return_outlined,
                          color: HexColor('#D97706'),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.orderResponseItem.order.returnId.isNotEmpty
                                ? 'Return  ${widget.orderResponseItem.order.returnId}'
                                : 'Return order',
                            style: customTextStyle(
                              fontStyle: FontStyle.BodyL_Bold,
                              color: FontColor.FontPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (state is DriverOrderInitialPageState)
                Expanded(
                  child: ListView(
                    children: _orderItemWidgets(state.assignedDriver),
                  ),
                )
              else if (state is DriverOrderInitialErrorState)
                Expanded(
                  child: ListView(
                    children: _orderItemWidgets(state.assignedDriver),
                  ),
                )
              else
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [LoadingIndecator()],
                  ),
                ),
            ],
          ),
          bottomNavigationBar: SizedBox(
            height: screenSize.height * 0.1,
            child: Column(
              children: [
                _bottomAction(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _swipeAction({
    required String text,
    required Color color,
    required String status,
  }) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 35.0),
        child:
            loading
                ? BasketButton(
                  loading: true,
                  bgcolor: color,
                  textStyle: customTextStyle(fontStyle: FontStyle.BodyL_Bold),
                )
                : Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: customColors().grey),
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: SwipeableWidget(
                    text: text,
                    onSwipeFinish: () async {
                      setState(() {
                        loading = true;
                      });
                      BlocProvider.of<DriverOrderInnerPageCubit>(
                        context,
                      ).updateMainOrderStat(
                        driverActionOrderId(widget.orderResponseItem),
                        status,
                      );
                    },
                  ),
                ),
      ),
    );
  }

  Widget _bottomAction() {
    final isReturn = isReturnOrder(widget.orderResponseItem);
    final status = widget.orderResponseItem.order.status;

    if (isReturn) {
      if (status == "returned") {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: BasketButton(
            text: "Returned",
            enabled: false,
            bgcolor: HexColor('#D97706'),
            textStyle: customTextStyle(
              fontStyle: FontStyle.BodyL_Bold,
              color: FontColor.White,
            ),
          ),
        );
      }

      if (status == "on_the_way_to_return") {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: BasketButton(
            onpress: () {
              context.gNavigationService.openDeliveryUpdatePage(
                context,
                arg: {'order': widget.orderResponseItem},
              );
            },
            text: "Upload Return Image",
            bgcolor: HexColor('#D97706'),
            textStyle: customTextStyle(
              fontStyle: FontStyle.BodyL_Bold,
              color: FontColor.White,
            ),
          ),
        );
      }

      return _swipeAction(
        text: "Ready To Return..!",
        color: HexColor('#D97706'),
        status: "on_the_way_to_return",
      );
    }

    if (status != "on_the_way") {
      return _swipeAction(
        text: "Ready To Deliver..!",
        color: customColors().green4,
        status: "on_the_way",
      );
    }

    final needsDocuments = needsDriverDeliveryDocuments(
      widget.orderResponseItem,
    );

    if (needsDocuments) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: BasketButton(
          onpress: () {
            context.gNavigationService.openDocumentUpdatePage(
              context,
              arg: {'order': widget.orderResponseItem},
            );
          },
          text: "Upload Documents",
          bgcolor: customColors().wTokenFontColor,
          textStyle: customTextStyle(
            fontStyle: FontStyle.BodyL_Bold,
            color: FontColor.White,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: BasketButton(
        onpress: () {
          context.gNavigationService.openDeliveryUpdatePage(
            context,
            arg: {'order': widget.orderResponseItem},
          );
        },
        text: "Upload Bill",
        bgcolor: customColors().green600,
        textStyle: customTextStyle(
          fontStyle: FontStyle.BodyL_Bold,
          color: FontColor.White,
        ),
      ),
    );
  }

  List<Widget> _orderItemWidgets(List<ItemItem> items) {
    final groups = <String, List<ItemItem>>{};
    for (final item in items) {
      final key =
          item.subgroupIdentifier.isNotEmpty
              ? item.subgroupIdentifier
              : 'Items';
      groups.putIfAbsent(key, () => []).add(item);
    }

    if (groups.length <= 1) {
      return items
          .map((item) => DriverOrderInnerListItem(orderItem: item))
          .toList();
    }

    final widgets = <Widget>[];
    for (final entry in groups.entries) {
      final type = entry.key.split('-').first.toUpperCase();
      widgets.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: getTypeColor(type),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  type,
                  style: customTextStyle(
                    fontStyle: FontStyle.BodyS_Bold,
                    color: FontColor.White,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  entry.key,
                  style: customTextStyle(
                    fontStyle: FontStyle.BodyM_Bold,
                    color: FontColor.FontPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
      widgets.addAll(
        entry.value.map((item) => DriverOrderInnerListItem(orderItem: item)),
      );
    }
    return widgets;
  }
}
