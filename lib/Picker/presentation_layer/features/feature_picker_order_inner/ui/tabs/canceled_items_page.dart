import 'package:ansarlogistics/Picker/presentation_layer/features/feature_picker_order_inner/ui/picker_order_item.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:picker_driver_api/responses/order_response.dart';

class CanceledItemsPage extends StatefulWidget {
  List<EndPicking> canceleditems;
  Order orderResponseItem;
  List<String> catlist;
  CanceledItemsPage({
    super.key,
    required this.canceleditems,
    required this.orderResponseItem,
    required this.catlist,
  });

  @override
  State<CanceledItemsPage> createState() => _CanceledItemsPageState();
}

class _CanceledItemsPageState extends State<CanceledItemsPage> {
  @override
  Widget build(BuildContext context) {
    if (widget.canceleditems.isNotEmpty) {
      return Expanded(
        child: ListView.builder(
          itemCount: widget.catlist.length,
          shrinkWrap: true,
          physics: AlwaysScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            // List<EndPicking> items =
            //     widget.maplist[widget.maplist.keys.toList()[index]]!;

            // List<String> catlist = widget.maplist.keys.toList();

            List<EndPicking> itemslist =
                widget.canceleditems
                    .where(
                      (element) => element.catename == widget.catlist[index],
                    )
                    .toList();

            return itemslist.isNotEmpty
                ? PickerOrderItem(
                  catlist: widget.catlist,
                  index: index,
                  orderResponseItem: widget.orderResponseItem,
                  itemslistbackcategories: widget.canceleditems,
                )
                : SizedBox();
          },
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
  }
}
