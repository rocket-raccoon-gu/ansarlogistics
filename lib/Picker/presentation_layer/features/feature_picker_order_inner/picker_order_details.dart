import 'package:ansarlogistics/Picker/presentation_layer/features/feature_picker_order_inner/bloc/picker_order_details_cubit.dart';
import 'package:ansarlogistics/Picker/presentation_layer/features/feature_picker_order_inner/bloc/picker_order_details_state.dart';
import 'package:ansarlogistics/Picker/presentation_layer/features/feature_picker_order_inner/ui/tabs/canceled_items_page.dart';
import 'package:ansarlogistics/Picker/presentation_layer/features/feature_picker_order_inner/ui/tabs/endpick_barcode.dart';
import 'package:ansarlogistics/Picker/presentation_layer/features/feature_picker_order_inner/ui/tabs/not_found_items_page.dart';
import 'package:ansarlogistics/Picker/presentation_layer/features/feature_picker_order_inner/ui/tabs/picked_items_page.dart';
import 'package:ansarlogistics/Picker/presentation_layer/features/feature_picker_order_inner/ui/tabs/to_pick_items_page.dart';
import 'package:ansarlogistics/app_page_injectable.dart';
import 'package:ansarlogistics/components/custom_app_components/app_bar/order_inner_app_bar.dart';
import 'package:ansarlogistics/components/custom_app_components/bottom_bar/custom_bottom_bar_details.dart';
import 'package:ansarlogistics/components/custom_app_components/buttons/basket_button.dart';
import 'package:ansarlogistics/components/custom_app_components/buttons/swipe_button.dart';
import 'package:ansarlogistics/components/loading_indecator.dart';
import 'package:ansarlogistics/constants/methods.dart';
import 'package:ansarlogistics/services/service_locator.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:ansarlogistics/utils/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:picker_driver_api/responses/order_items_response.dart';
import 'package:picker_driver_api/responses/order_response.dart';

class PickerOrderDetails extends StatefulWidget {
  Order orderResponseItem;
  ServiceLocator serviceLocator;
  PickerOrderDetails({
    super.key,
    required this.orderResponseItem,
    required this.serviceLocator,
  });

  @override
  State<PickerOrderDetails> createState() => _PickerOrderDetailsState();
}

class _PickerOrderDetailsState extends State<PickerOrderDetails> {
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PickerOrderDetailsCubit, PickerOrderDetailsState>(
      builder: (context, state) {
        return Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(0.0),
            child: AppBar(elevation: 0, backgroundColor: HexColor('#F9FBFF')),
          ),
          backgroundColor: customColors().backgroundPrimary,
          body: Stack(
            children: [
              Column(
                children: [
                  OrderInnerAppBar(
                    onTapBack: () async {
                      // if (UserController.userController.alloworderupdated) {
                      //   UserController.userController.alloworderupdated = false;
                      //   context.gNavigationService
                      //       .openPickerWorkspacePage(context);
                      // } else {
                      context.gNavigationService.back(context);
                      // }
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
                  Expanded(
                    child: Column(
                      children: [
                        if (state is PickerOrderDetailsInitialState)
                          getBody(
                            state.tabindex,
                            state,
                            widget.orderResponseItem,
                            state.mylist,
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
                  ),
                ],
              ),
              Positioned(
                bottom: 15.0,
                child:
                    widget.orderResponseItem.status != "end_picking" &&
                            BlocProvider.of<PickerOrderDetailsCubit>(
                                  context,
                                ).tabindex ==
                                1
                        ? SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 35.0,
                            ),
                            child:
                                BlocProvider.of<PickerOrderDetailsCubit>(
                                      context,
                                    ).loading
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
                                        borderRadius: BorderRadius.circular(
                                          20.0,
                                        ),
                                      ),
                                      child: SwipeableWidget(
                                        text: "Swipe to finish !",
                                        onSwipeFinish: () async {
                                          setState(() {
                                            loading = true;
                                          });
                                          BlocProvider.of<
                                            PickerOrderDetailsCubit
                                          >(context).updateMainOrderStat(
                                            widget
                                                .orderResponseItem
                                                .subgroupIdentifier,
                                          );
                                        },
                                      ),
                                    ),
                          ),
                        )
                        : SizedBox(),
              ),
            ],
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          bottomNavigationBar: CustomBottomBarDetails(),
          floatingActionButton:
              (widget.orderResponseItem.type == "EXP" ||
                          widget.orderResponseItem.type == "NOL") &&
                      BlocProvider.of<PickerOrderDetailsCubit>(
                            context,
                          ).tabindex ==
                          0
                  ? FloatingActionButton(
                    backgroundColor: customColors().dodgerBlue,
                    foregroundColor: customColors().carnationRed,
                    elevation: 8.0,
                    child: Icon(
                      Icons.add,
                      size: 30,
                      color: customColors().backgroundSecondary,
                    ),
                    onPressed: () {
                      context.gNavigationService.openOrderItemAddPage(
                        context,
                        arg: {"order": widget.orderResponseItem},
                      );
                    },
                  )
                  : null,
        );
      },
    );
  }
}

Widget getBody(
  int index,
  PickerOrderDetailsInitialState state,
  Order orderResponseItem,
  List<String> list,
) {
  switch (index) {
    case 0:
      return ToPickItemsPage(
        topickitems: state.topickitems,
        orderResponseItem: orderResponseItem,
        catlist: state.catlist,
      );

    case 1:
      return PickedItemsPage(
        pickeditems: state.pickeditems,
        orderResponseItem: orderResponseItem,
        catlist: state.catlist,
      );

    case 2:
      return NotFoundItemsPage(
        notfounditems: state.notfounditems,
        orderResponseItem: orderResponseItem,
        catlist: state.catlist,
      );

    case 3:
      // return CanceledItemsPage(
      //   canceleditems: state.canceleditems,
      //   orderResponseItem: orderResponseItem,
      //   catlist: state.catlist,
      // );
      return EndpickBarcode();
    default:
      return Container();
  }
}
