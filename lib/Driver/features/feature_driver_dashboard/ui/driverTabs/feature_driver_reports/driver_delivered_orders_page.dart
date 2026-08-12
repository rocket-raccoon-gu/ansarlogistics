import 'package:ansarlogistics/constants/methods.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:picker_driver_api/responses/order_report_response.dart';

String posBillImageUrl(String subgroupIdentifier) {
  final id = subgroupIdentifier.trim();
  if (id.isEmpty) return '';
  return 'https://media.ansargallery.com/pos-bill/$id.jpg';
}

void showPosBillViewer(BuildContext context, String subgroupIdentifier) {
  final url = posBillImageUrl(subgroupIdentifier);
  if (url.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Order ID is missing for this bill.')),
    );
    return;
  }

  Navigator.of(context).push(
    MaterialPageRoute(
      builder:
          (_) => _PosBillViewerPage(
            orderId: subgroupIdentifier.trim(),
            imageUrl: url,
          ),
    ),
  );
}

class _PosBillViewerPage extends StatelessWidget {
  const _PosBillViewerPage({
    required this.orderId,
    required this.imageUrl,
  });

  final String orderId;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: HexColor('#F9FBFF'),
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'POS Bill',
              style: customTextStyle(
                fontStyle: FontStyle.BodyL_Bold,
                color: FontColor.FontPrimary,
              ),
            ),
            Text(
              orderId,
              style: customTextStyle(
                fontStyle: FontStyle.BodyS_Regular,
                color: FontColor.FontSecondary,
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4,
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.contain,
            placeholder:
                (_, __) => const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
            errorWidget:
                (_, __, ___) => Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.receipt_long_outlined,
                        size: 48,
                        color: Colors.white70,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Bill image not available for this order.',
                        textAlign: TextAlign.center,
                        style: customTextStyle(
                          fontStyle: FontStyle.BodyM_Regular,
                          color: FontColor.White,
                        ),
                      ),
                    ],
                  ),
                ),
          ),
        ),
      ),
    );
  }
}

class DriverDeliveredOrdersPage extends StatelessWidget {
  const DriverDeliveredOrdersPage({
    super.key,
    required this.orders,
    required this.dateRangeLabel,
    this.fallbackOrderIds = const [],
  });

  final List<ReportOrderDetail> orders;
  final String dateRangeLabel;
  final List<String> fallbackOrderIds;

  @override
  Widget build(BuildContext context) {
    final displayOrders = _resolveOrders();

    return Scaffold(
      backgroundColor: HexColor('#F9FBFF'),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: HexColor('#F9FBFF'),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Delivered Orders',
              style: customTextStyle(
                fontStyle: FontStyle.BodyL_Bold,
                color: FontColor.FontPrimary,
              ),
            ),
            if (dateRangeLabel.isNotEmpty)
              Text(
                dateRangeLabel,
                style: customTextStyle(
                  fontStyle: FontStyle.BodyS_Regular,
                  color: FontColor.FontSecondary,
                ),
              ),
          ],
        ),
      ),
      body:
          displayOrders.isEmpty
              ? Center(
                child: Text(
                  'No delivered orders found for this date range.',
                  style: customTextStyle(
                    fontStyle: FontStyle.BodyM_Regular,
                    color: FontColor.FontSecondary,
                  ),
                ),
              )
              : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                itemCount: displayOrders.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final order = displayOrders[index];
                  return _DeliveredOrderCard(
                    index: index + 1,
                    order: order,
                  );
                },
              ),
    );
  }

  List<ReportOrderDetail> _resolveOrders() {
    if (orders.isNotEmpty) return orders;

    return fallbackOrderIds
        .map(
          (id) => ReportOrderDetail(
            subgroupIdentifier: id,
            paymentMethod: '',
            posAmount: '',
          ),
        )
        .toList();
  }
}

class _DeliveredOrderCard extends StatelessWidget {
  const _DeliveredOrderCard({
    required this.index,
    required this.order,
  });

  final int index;
  final ReportOrderDetail order;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: customColors().backgroundTertiary),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: customColors().secretGarden,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$index',
                      style: customTextStyle(
                        fontStyle: FontStyle.BodyS_Bold,
                        color: FontColor.White,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    order.subgroupIdentifier.isNotEmpty
                        ? order.subgroupIdentifier
                        : '-',
                    style: customTextStyle(
                      fontStyle: FontStyle.BodyL_Bold,
                      color: FontColor.FontPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _detailRow('Payment Method', order.paymentMethod),
            const SizedBox(height: 8),
            _detailRow(
              'POS Amount',
              order.posAmount.isNotEmpty ? 'QAR ${order.posAmount}' : '-',
              valueStyle: customTextStyle(
                fontStyle: FontStyle.BodyL_Bold,
                color: FontColor.FontPrimary,
              ),
            ),
            if (order.subgroupIdentifier.trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed:
                      () => showPosBillViewer(
                        context,
                        order.subgroupIdentifier,
                      ),
                  icon: const Icon(Icons.receipt_long_outlined),
                  label: const Text('View Bill'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: customColors().secretGarden,
                    side: BorderSide(color: customColors().secretGarden),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _detailRow(
    String label,
    String value, {
    TextStyle? valueStyle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: customTextStyle(
              fontStyle: FontStyle.BodyM_SemiBold,
              color: FontColor.FontSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value.isNotEmpty ? value : '-',
            style:
                valueStyle ??
                customTextStyle(
                  fontStyle: FontStyle.BodyM_Regular,
                  color: FontColor.FontPrimary,
                ),
          ),
        ),
      ],
    );
  }
}
