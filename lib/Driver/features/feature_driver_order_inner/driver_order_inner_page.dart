import 'package:ansarlogistics/Driver/features/feature_driver_dashboard/ui/list_item/driver_order_inner_list_item.dart';
import 'package:ansarlogistics/Driver/features/feature_driver_order_inner/bloc/driver_order_inner_page_cubit.dart';
import 'package:ansarlogistics/Driver/features/feature_driver_order_inner/bloc/driver_order_inner_page_state.dart';
import 'package:ansarlogistics/app_page_injectable.dart';
import 'package:ansarlogistics/components/custom_app_components/app_bar/order_inner_app_bar.dart';
import 'package:ansarlogistics/components/custom_app_components/buttons/basket_button.dart';
import 'package:ansarlogistics/components/custom_app_components/buttons/swipe_button.dart';
import 'package:ansarlogistics/components/loading_indecator.dart';
import 'package:ansarlogistics/constants/methods.dart';
import 'package:ansarlogistics/services/service_locator.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:ansarlogistics/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:picker_driver_api/responses/order_response.dart';

class DriverOrderInnerPage extends StatefulWidget {
  Order orderResponseItem;
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
        if (state is DriverOrderInitialErrorState) {
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
                child: OrderInnerAppBar(
                  onTapBack: () {
                    context.gNavigationService.back(context);
                  },
                  orderResponseItem: widget.orderResponseItem,
                  onTapinfo: () {
                    showTopModel(
                      context,
                      widget.serviceLocator,
                      widget.orderResponseItem,
                    );
                  },
                ),
              ),

              if (state is DriverOrderInitialPageState)
                Expanded(
                  child: ListView.builder(
                    itemCount: state.assignedDriver.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return DriverOrderInnerListItem(
                        orderItem: state.assignedDriver[index],
                      );
                    },
                  ),
                )
              else if (state is DriverOrderInitialErrorState)
                Expanded(
                  child: ListView.builder(
                    itemCount: state.assignedDriver.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return DriverOrderInnerListItem(
                        orderItem: state.assignedDriver[index],
                      );
                    },
                  ),
                )
              else
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [LoadingIndecator()],
                  ),
                ),

              // Expanded(
              //     child: Stack(
              //   children: [
              //     Column(
              //       children: [
              //         if (state is DriverOrderInitialPageState)
              //           Padding(
              //             padding: const EdgeInsets.symmetric(vertical: 10.0),
              //             child: Expanded(
              //               child: ListView.builder(
              //                   itemCount: state.assignedDriver.length,
              //                   shrinkWrap: true,
              //                   itemBuilder: (context, index) {
              //                     return DriverOrderInnerListItem(
              //                         orderItem: state.assignedDriver[index]);
              //                   }),
              //             ),
              //           )
              //         else if (state is DriverOrderInitialErrorState)
              //           Padding(
              //             padding: const EdgeInsets.symmetric(vertical: 10.0),
              //             child: Expanded(
              //               child: ListView.builder(
              //                   itemCount: state.assignedDriver.length,
              //                   shrinkWrap: true,
              //                   itemBuilder: (context, index) {
              //                     return DriverOrderInnerListItem(
              //                         orderItem: state.assignedDriver[index]);
              //                   }),
              //             ),
              //           )
              //         else
              //           Expanded(
              //             child: Column(
              //               mainAxisAlignment: MainAxisAlignment.center,
              //               children: [LoadingIndecator()],
              //             ),
              //           ),
              //       ],
              //     ),
              //   ],
              // ))
            ],
          ),
          bottomNavigationBar: SizedBox(
            height: screenSize.height * 0.1,
            child: Column(
              children: [
                widget.orderResponseItem.status != "on_the_way"
                    ? SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 35.0),
                        child:
                            loading
                                ? BasketButton(
                                  loading: true,
                                  bgcolor: customColors().green4,
                                  textStyle: customTextStyle(
                                    fontStyle: FontStyle.BodyL_Bold,
                                  ),
                                )
                                : Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: customColors().grey,
                                    ),
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  child: SwipeableWidget(
                                    text: "Ready To Deliver..!",
                                    onSwipeFinish: () async {
                                      setState(() {
                                        loading = true;
                                      });
                                      BlocProvider.of<
                                        DriverOrderInnerPageCubit
                                      >(context).updateMainOrderStat(
                                        widget
                                            .orderResponseItem
                                            .subgroupIdentifier,
                                        "on_the_way",
                                      );
                                    },
                                  ),
                                ),
                      ),
                    )
                    : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child:
                          double.parse(widget.orderResponseItem.grandTotal) >=
                                      500 ||
                                  widget.orderResponseItem.type == "VPO" ||
                                  widget.orderResponseItem.type == "SUP"
                              ? BasketButton(
                                onpress: () {
                                  context.gNavigationService
                                      .openDocumentUpdatePage(
                                        context,
                                        arg: {
                                          'order': widget.orderResponseItem,
                                        },
                                      );
                                },
                                text: "Upload Documents",
                                bgcolor: customColors().wTokenFontColor,
                                textStyle: customTextStyle(
                                  fontStyle: FontStyle.BodyL_Bold,
                                  color: FontColor.White,
                                ),
                              )
                              : BasketButton(
                                onpress: () {
                                  context.gNavigationService
                                      .openDeliveryUpdatePage(
                                        context,
                                        arg: {
                                          'order': widget.orderResponseItem,
                                        },
                                      );
                                },
                                text: "Upload Bill",
                                bgcolor: customColors().green600,
                                textStyle: customTextStyle(
                                  fontStyle: FontStyle.BodyL_Bold,
                                  color: FontColor.White,
                                ),
                              ),
                    ),
              ],
            ),
          ),
        );
      },
    );
  }
}
