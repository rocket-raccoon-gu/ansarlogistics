import 'package:ansarlogistics/common_features/feature_status_history/status_history_cubit.dart';
import 'package:ansarlogistics/common_features/feature_status_history/status_history_state.dart';
import 'package:ansarlogistics/components/custom_app_components/custom_timeline.dart';
import 'package:ansarlogistics/components/loading_indecator.dart';
import 'package:ansarlogistics/services/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:picker_driver_api/responses/order_response.dart';
import 'package:picker_driver_api/responses/orders_new_response.dart';

class StatusHistory extends StatefulWidget {
  final ServiceLocator serviceLocator;
  OrderNew orderResponseItem;
  StatusHistory({
    super.key,
    required this.serviceLocator,
    required this.orderResponseItem,
  });

  @override
  State<StatusHistory> createState() => _StatusHistoryState();
}

class _StatusHistoryState extends State<StatusHistory> {
  @override
  Widget build(BuildContext context) {
    return Container();
    // return BlocProvider(
    //   create:
    //       (context) => StatusHistoryCubit(
    //         context,
    //         widget.serviceLocator,
    //         widget.orderResponseItem.subgroupIdentifier,
    //       ),
    //   child: BlocBuilder<StatusHistoryCubit, StatusHistoryState>(
    //     builder: (context, state) {
    //       if (state is StatusHistorystateInitial) {
    //         return Column(
    //           children: [
    //             Expanded(
    //               child: MediaQuery.removePadding(
    //                 removeTop: true,
    //                 context: context,
    //                 child: ListView.builder(
    //                   itemCount: state.historylist.length,
    //                   shrinkWrap: true,
    //                   itemBuilder: (context, index) {
    //                     return CustomTimeline(
    //                       isFirst: index == 0,
    //                       isLast: index == state.historylist.length - 1,
    //                       statushistory: state.historylist[index],
    //                     );
    //                   },
    //                 ),
    //               ),
    //             ),
    //           ],
    //         );
    //       } else {
    //         return Column(
    //           mainAxisAlignment: MainAxisAlignment.center,
    //           children: [LoadingIndecator()],
    //         );
    //       }
    //     },
    //   ),
    // );
  }
}
