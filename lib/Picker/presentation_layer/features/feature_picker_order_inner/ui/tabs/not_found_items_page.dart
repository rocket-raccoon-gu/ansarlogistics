import 'package:ansarlogistics/Picker/presentation_layer/features/feature_picker_order_inner/bloc/picker_order_details_cubit.dart';
import 'package:ansarlogistics/Picker/presentation_layer/features/feature_picker_order_inner/ui/picker_order_item.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:picker_driver_api/responses/order_items_response.dart';
import 'package:picker_driver_api/responses/order_response.dart';

class NotFoundItemsPage extends StatefulWidget {
  List<EndPicking> notfounditems;
  Order orderResponseItem;
  List<String> catlist = [];
  bool translate;

  NotFoundItemsPage({
    super.key,
    required this.notfounditems,
    required this.orderResponseItem,
    required this.catlist,
    required this.translate,
  });

  @override
  State<NotFoundItemsPage> createState() => _NotFoundItemsPageState();
}

class _NotFoundItemsPageState extends State<NotFoundItemsPage> {
  @override
  Widget build(BuildContext context) {
    if (widget.notfounditems.isNotEmpty) {
      return Expanded(
        child: RefreshIndicator(
          onRefresh: () async {
            await BlocProvider.of<PickerOrderDetailsCubit>(
              context,
            ).getrefreshedData(widget.orderResponseItem.subgroupIdentifier);
          },
          child: ListView.builder(
            itemCount: widget.catlist.length,
            shrinkWrap: true,
            physics: AlwaysScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              // List<EndPicking> items =
              //     widget.maplist[widget.maplist.keys.toList()[index]]!;

              // List<String> catlist = widget.maplist.keys.toList();

              List<EndPicking> itemslist =
                  widget.notfounditems
                      .where(
                        (element) => element.catename == widget.catlist[index],
                      )
                      .toList();

              return itemslist.isNotEmpty
                  ? PickerOrderItem(
                    catlist: widget.catlist,
                    index: index,
                    orderResponseItem: widget.orderResponseItem,
                    itemslistbackcategories: widget.notfounditems,
                    translate: widget.translate,
                  )
                  : SizedBox();
            },
          ),
        ),
      );
    } else {
      return Expanded(
        child: SingleChildScrollView(
          physics:
              AlwaysScrollableScrollPhysics(), // Ensures scrollable behavior
          child: Column(
            children: [
              Container(
                height:
                    MediaQuery.of(context).size.height -
                    (kToolbarHeight + 50), // Fill remaining screen height
                alignment: Alignment.center, // Center content
                child: Text(
                  "No data",
                  style: TextStyle(fontSize: 18.0, color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      );
    }
    //   return widget.maplist.isNotEmpty
    //       ? Expanded(
    //           child: ListView.builder(
    //               itemCount: widget.maplist.length,
    //               shrinkWrap: true,
    //               physics: AlwaysScrollableScrollPhysics(),
    //               itemBuilder: (context, index) {
    //                 List<EndPicking> items =
    //                     widget.maplist[widget.maplist.keys.toList()[index]]!;

    //                 List<String> catlist = widget.maplist.keys.toList();

    //                 return PickerOrderItem(
    //                     catlist: catlist,
    //                     index: index,
    //                     orderResponseItem: widget.orderResponseItem,
    //                     itemslistbackcategories: items);
    //               }),
    //         )
    //       : Expanded(
    //           child: SingleChildScrollView(
    //             physics:
    //                 AlwaysScrollableScrollPhysics(), // Ensures scrollable behavior
    //             child: Column(
    //               children: [
    //                 Container(
    //                   height: MediaQuery.of(context).size.height -
    //                       (kToolbarHeight + 50), // Fill remaining screen height
    //                   alignment: Alignment.center, // Center content
    //                   child: Text(
    //                     "No data",
    //                     style: TextStyle(fontSize: 18.0, color: Colors.grey),
    //                   ),
    //                 ),
    //               ],
    //             ),
    //           ),
    //         );
  }
}
