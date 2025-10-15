import 'package:ansarlogistics/Sales_staff/features/staff_summery_list.dart/bloc/staff_summery_list_cubit.dart';
import 'package:ansarlogistics/Sales_staff/features/staff_summery_list.dart/bloc/staff_summery_list_state.dart';
import 'package:ansarlogistics/constants/methods.dart';
import 'package:ansarlogistics/constants/texts.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:ansarlogistics/user_controller/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StaffSummeryListPage extends StatefulWidget {
  const StaffSummeryListPage({super.key});

  @override
  State<StaffSummeryListPage> createState() => _StaffSummeryListPageState();
}

class _StaffSummeryListPageState extends State<StaffSummeryListPage> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    // In case the initial list is shorter than the viewport, attempt a load after first layout
    WidgetsBinding.instance.addPostFrameCallback((_) => _onScroll());
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    // When the remaining scrollable extent below the viewport is small, load more
    const double threshold = 300.0;
    if (_scrollController.position.extentAfter < threshold) {
      context.read<StaffSummeryListCubit>().loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0.0),
        child: AppBar(elevation: 0, backgroundColor: HexColor('#b9d737')),
      ),
      body: BlocBuilder<StaffSummeryListCubit, StaffSummeryListState>(
        builder: (context, state) {
          Widget header = Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(color: HexColor('#b9d737')),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                      icon: Icon(Icons.menu),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 6.0),
                      child: Text(
                        "Staff Summary Report",
                        style: customTextStyle(
                          fontStyle: FontStyle.BodyL_Bold,
                          color: FontColor.FontPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );

          if (state is StaffSummeryListLoadingState) {
            return Column(
              children: [
                header,
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                ),
              ],
            );
          }

          if (state is StaffSummeryListErrorState) {
            return Column(
              children: [
                header,
                Expanded(
                  child: Center(
                    child: Text(
                      state.message,
                      style: customTextStyle(
                        fontStyle: FontStyle.BodyM_Bold,
                        color: FontColor.FontPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            );
          }

          if (state is StaffSummeryListSuccessState) {
            final summary = state.summary;
            final items = state.data;
            return Column(
              children: [
                header,
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _SummaryChip(
                            label: 'Total Scans',
                            value: (summary['total_scans'] ?? '').toString(),
                          ),
                          // _SummaryChip(
                          //   label: 'Unique Products',
                          //   value:
                          //       (summary['unique_products'] ?? '').toString(),
                          // ),
                          _SummaryChip(
                            label: 'Total Qty',
                            value: (summary['total_quantity'] ?? '').toString(),
                          ),
                          // _SummaryChip(
                          //   label: 'First Scan',
                          //   value: (summary['first_scan'] ?? '').toString(),
                          // ),
                          // _SummaryChip(
                          //   label: 'Last Scan',
                          //   value: (summary['last_scan'] ?? '').toString(),
                          // ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView.separated(
                    controller: _scrollController,
                    shrinkWrap: true,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (ctx, i) {
                      final it = items[i];
                      final sku = (it['erp_sku'] ?? '').toString();
                      final qty = (it['erp_qty'] ?? '').toString();
                      final uom = (it['uom'] ?? '').toString();
                      final branch = (it['branch_code'] ?? '').toString();
                      final section = (it['section_id'] ?? '').toString();
                      final time =
                          (it['updated_at'] ?? it['scan_time'] ?? '')
                              .toString();
                      return ListTile(
                        dense: true,
                        leading: const Icon(Icons.qr_code_2),
                        title: Text(sku),
                        subtitle: Text(
                          'Qty: ' + qty + (uom.isNotEmpty ? (' • ' + uom) : ''),
                        ),
                        trailing: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(branch),
                            Text(section),
                            // Text(time, style: customTextStyle(fontStyle: FontStyle.BodyM_Bold)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }

          return Column(children: [header]);
        },
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final String value;
  const _SummaryChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
