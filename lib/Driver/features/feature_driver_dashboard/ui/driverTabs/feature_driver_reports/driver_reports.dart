import 'package:ansarlogistics/Driver/features/feature_driver_dashboard/ui/driverTabs/feature_driver_reports/bloc/driver_reports_cubit.dart';
import 'package:ansarlogistics/Driver/features/feature_driver_dashboard/ui/driverTabs/feature_driver_reports/bloc/driver_reports_state.dart';
import 'package:ansarlogistics/Driver/features/feature_driver_dashboard/ui/driverTabs/feature_driver_reports/driver_report_orders_page.dart';
import 'package:ansarlogistics/components/custom_app_components/buttons/animation_switch.dart';
import 'package:ansarlogistics/components/custom_app_components/textfields/translated_text.dart';
import 'package:ansarlogistics/constants/methods.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:picker_driver_api/responses/order_report_response.dart';

class DriverReportsPage extends StatefulWidget {
  const DriverReportsPage({super.key});

  @override
  State<DriverReportsPage> createState() => _DriverReportsPageState();
}

class _DriverReportsPageState extends State<DriverReportsPage> {
  static const List<String> _statusOrder = [
    'assigned_driver',
    'on_the_way',
    'order_collected',
    'complete',
    'cancel_request',
    'material_request',
    'customer_not_answer',
  ];

  DateTime _parseDate(String value) {
    try {
      return DateTime.parse(value);
    } catch (_) {
      return DateTime.now();
    }
  }

  String _labelFor(String status) {
    final label = getStatus(status);
    if (label.isNotEmpty) return label;
    return status.replaceAll('_', ' ');
  }

  Color _colorFor(String status) {
    switch (status) {
      case 'assigned_driver':
        return green600;
      case 'on_the_way':
        return customColors().pacificBlue;
      case 'order_collected':
        return HexColor('#7b98c9');
      case 'complete':
        return customColors().secretGarden;
      case 'cancel_request':
        return customColors().carnationRed;
      case 'material_request':
        return customColors().ultraviolet;
      case 'customer_not_answer':
        return customColors().crisps;
      default:
        return customColors().accent;
    }
  }

  IconData _iconFor(String status) {
    switch (status) {
      case 'assigned_driver':
        return Icons.assignment_ind_outlined;
      case 'on_the_way':
        return Icons.local_shipping_outlined;
      case 'order_collected':
        return Icons.inventory_2_outlined;
      case 'complete':
        return Icons.check_circle_outline;
      case 'cancel_request':
        return Icons.cancel_outlined;
      case 'material_request':
        return Icons.assignment_outlined;
      case 'customer_not_answer':
        return Icons.phone_missed_outlined;
      default:
        return Icons.receipt_long_outlined;
    }
  }

  List<_ReportTile> _tiles(List<Datum> list) {
    final byStatus = <String, Datum>{};
    for (final item in list) {
      byStatus[item.status] = item;
    }

    final tiles = <_ReportTile>[];
    for (final status in _statusOrder) {
      final item = byStatus.remove(status);
      tiles.add(
        _ReportTile(
          status: status,
          count: int.tryParse(item?.orderCount ?? '0') ?? 0,
          orders: item?.orders ?? const [],
        ),
      );
    }
    byStatus.forEach((status, item) {
      tiles.add(
        _ReportTile(
          status: status,
          count: int.tryParse(item.orderCount) ?? 0,
          orders: item.orders,
        ),
      );
    });
    return tiles;
  }

  void _openStatusOrders(_ReportTile tile) {
    if (tile.count <= 0 && tile.orders.isEmpty) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (_) => DriverReportOrdersPage(
              status: tile.status,
              title: _labelFor(tile.status),
              color: _colorFor(tile.status),
              orders: tile.orders,
            ),
      ),
    );
  }

  Future<void> _pickDates() async {
    final cubit = context.read<DriverReportCubit>();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      initialDateRange: DateTimeRange(
        start: _parseDate(cubit.startdate),
        end: _parseDate(cubit.enddate),
      ),
      saveText: 'Apply',
    );
    if (picked == null || !mounted) return;
    cubit.updatedata(
      DateFormat('yyyy-MM-dd').format(picked.start),
      DateFormat('yyyy-MM-dd').format(picked.end),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0.0),
        child: AppBar(elevation: 0, backgroundColor: HexColor('#F9FBFF')),
      ),
      backgroundColor: HexColor('#F9FBFF'),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: HexColor('#F9FBFF'),
              border: Border(
                bottom: BorderSide(
                  width: 1.0,
                  color: customColors().backgroundTertiary,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(
                left: 16.0,
                bottom: 16.0,
                top: 12.0,
              ),
              child: Center(
                child: TranslatedText(
                  text: "My Order Report",
                  style: customTextStyle(
                    fontStyle: FontStyle.BodyL_Bold,
                    color: FontColor.FontPrimary,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<DriverReportCubit, DriverReportState>(
              builder: (context, state) {
                final cubit = context.read<DriverReportCubit>();
                final isLoading = state is DriverReportLoadingState;
                final list =
                    state is DriverReportInitialState
                        ? state.statuslist
                        : cubit.statuslist;
                final tiles = _tiles(list);
                final total = tiles.fold<int>(
                  0,
                  (sum, item) => sum + item.count,
                );

                return RefreshIndicator(
                  onRefresh:
                      () => cubit.updatedata(cubit.startdate, cubit.enddate),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    children: [
                      _DateRangeCard(
                        start: cubit.startdate,
                        end: cubit.enddate,
                        onTap: _pickDates,
                      ),
                      const SizedBox(height: 16),
                      if (isLoading && list.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 80),
                          child: Center(child: loadingindecator()),
                        )
                      else ...[
                        _TotalCard(total: total),
                        const SizedBox(height: 16),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: tiles.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 1.15,
                              ),
                          itemBuilder: (context, index) {
                            final tile = tiles[index];
                            return _StatusCard(
                              title: _labelFor(tile.status),
                              count: tile.count,
                              color: _colorFor(tile.status),
                              icon: _iconFor(tile.status),
                              onTap: () => _openStatusOrders(tile),
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportTile {
  final String status;
  final int count;
  final List<ReportOrder> orders;

  _ReportTile({
    required this.status,
    required this.count,
    required this.orders,
  });
}

class _DateRangeCard extends StatelessWidget {
  final String start;
  final String end;
  final VoidCallback onTap;

  const _DateRangeCard({
    required this.start,
    required this.end,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final rangeText = start == end ? start : '$start  -  $end';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: customColors().backgroundPrimary,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: customColors().backgroundTertiary),
          boxShadow: [
            BoxShadow(
              color: customColors().backgroundTertiary.withOpacity(0.35),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: customColors().pacificBlue.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.calendar_month_outlined,
                color: customColors().pacificBlue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TranslatedText(
                    text: "Date range",
                    style: customTextStyle(
                      fontStyle: FontStyle.BodyM_Regular,
                      color: FontColor.FontSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    rangeText,
                    style: customTextStyle(
                      fontStyle: FontStyle.BodyL_Bold,
                      color: FontColor.FontPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: customColors().fontSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _TotalCard extends StatelessWidget {
  final int total;

  const _TotalCard({required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      decoration: BoxDecoration(
        color: customColors().secretGarden,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.analytics_outlined,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TranslatedText(
                  text: "Total orders",
                  style: customTextStyle(
                    fontStyle: FontStyle.BodyM_Regular,
                    color: FontColor.White,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$total',
                  style: customTextStyle(
                    fontStyle: FontStyle.HeaderL_Bold,
                    color: FontColor.White,
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

class _StatusCard extends StatelessWidget {
  final String title;
  final int count;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const _StatusCard({
    required this.title,
    required this.count,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: count > 0 ? onTap : null,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: customColors().backgroundPrimary,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.22)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const Spacer(),
                if (count > 0)
                  Icon(Icons.chevron_right, color: color, size: 20),
              ],
            ),
            const Spacer(),
            Text(
              '$count',
              style: customTextStyle(
                fontStyle: FontStyle.HeaderM_Bold,
                color: FontColor.FontPrimary,
              ),
            ),
            const SizedBox(height: 4),
            TranslatedText(
              text: title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: customTextStyle(
                fontStyle: FontStyle.BodyM_SemiBold,
                color: FontColor.FontSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
