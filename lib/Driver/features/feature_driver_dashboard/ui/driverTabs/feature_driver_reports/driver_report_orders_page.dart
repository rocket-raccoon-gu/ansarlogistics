import 'package:ansarlogistics/components/custom_app_components/textfields/translated_text.dart';
import 'package:ansarlogistics/constants/methods.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:picker_driver_api/responses/order_report_response.dart';

String posBillImageUrl(String subgroupIdentifier) {
  final id = subgroupIdentifier.trim();
  if (id.isEmpty) return '';
  return 'https://media.ansargallery.com/pos-bill/$id.jpg';
}

class DriverReportOrdersPage extends StatelessWidget {
  final String status;
  final String title;
  final Color color;
  final List<ReportOrder> orders;

  const DriverReportOrdersPage({
    super.key,
    required this.status,
    required this.title,
    required this.color,
    required this.orders,
  });

  bool get _showBill => status == 'complete';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HexColor('#F9FBFF'),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: HexColor('#F9FBFF'),
        foregroundColor: customColors().fontPrimary,
        title: TranslatedText(
          text: title,
          style: customTextStyle(
            fontStyle: FontStyle.BodyL_Bold,
            color: FontColor.FontPrimary,
          ),
        ),
      ),
      body: orders.isEmpty
          ? Center(
              child: TranslatedText(
                text: "No orders in this status",
                style: customTextStyle(
                  fontStyle: FontStyle.BodyL_SemiBold,
                  color: FontColor.FontSecondary,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                return _ReportOrderCard(
                  order: orders[index],
                  accent: color,
                  showBill: _showBill,
                );
              },
            ),
    );
  }
}

class _ReportOrderCard extends StatelessWidget {
  final ReportOrder order;
  final Color accent;
  final bool showBill;

  const _ReportOrderCard({
    required this.order,
    required this.accent,
    required this.showBill,
  });

  String _typeLabel() {
    if (order.isMerged || order.subgroupIdentifiers.length > 1) {
      final types =
          order.subgroupIdentifiers
              .map((id) => id.split('-').first.toUpperCase())
              .toSet()
              .toList();
      if (types.length > 1) return types.join(' + ');
      return "COMBINED";
    }
    final id = order.subgroupIdentifier.toUpperCase();
    for (final type in const ["EXP", "NOL", "VPO", "SUP", "CAK", "WAR", "ABY"]) {
      if (id.startsWith('$type-')) return type;
    }
    return "Unknown";
  }

  String _paymentLabel() {
    final label = getPaymentMethod(order.paymentMethod);
    if (label.isNotEmpty) return label;
    if (order.paymentMethod.isEmpty) return "N/A";
    return order.paymentMethod;
  }

  String _createdLabel() {
    if (order.createdAt == null) return "";
    final parsed = DateTime.tryParse(order.createdAt.toString());
    if (parsed == null) return order.createdAt.toString();
    return DateFormat('dd MMM yyyy, hh:mm a').format(parsed.toLocal());
  }

  List<String> _billIds() {
    if (order.isMerged || order.subgroupIdentifiers.length > 1) {
      final ids =
          order.subgroupIdentifiers
              .map((id) => id.trim())
              .where((id) => id.isNotEmpty)
              .toList();
      if (ids.isNotEmpty) return ids;
    }
    final id = order.subgroupIdentifier.trim();
    return id.isEmpty ? [] : [id];
  }

  @override
  Widget build(BuildContext context) {
    final type = _typeLabel();
    final typeColor =
        type.contains('+') ? HexColor('#5B4CDB') : getTypeColor(type);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: customColors().backgroundPrimary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withOpacity(0.18)),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(0.06),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: typeColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  type,
                  style: customTextStyle(
                    fontStyle: FontStyle.BodyS_Bold,
                    color: FontColor.FontPrimary,
                  ).copyWith(color: typeColor),
                ),
              ),
              const Spacer(),
              if (_createdLabel().isNotEmpty)
                Text(
                  _createdLabel(),
                  style: customTextStyle(
                    fontStyle: FontStyle.BodyS_Regular,
                    color: FontColor.FontSecondary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            order.subgroupIdentifier,
            style: customTextStyle(
              fontStyle: FontStyle.BodyL_Bold,
              color: FontColor.FontPrimary,
            ),
          ),
          if (order.isMerged && order.subgroupIdentifiers.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              order.subgroupIdentifiers.join('  •  '),
              style: customTextStyle(
                fontStyle: FontStyle.BodyS_Regular,
                color: FontColor.FontSecondary,
              ),
            ),
          ],
          const SizedBox(height: 12),
          _InfoRow(
            icon: Icons.payments_outlined,
            label: "Payment method",
            value: _paymentLabel(),
          ),
          const SizedBox(height: 8),
          _InfoRow(
            icon: Icons.receipt_long_outlined,
            label: "POS amount",
            value: "QAR ${order.posAmount.toStringAsFixed(2)}",
          ),
          if (showBill) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  final ids = _billIds();
                  if (ids.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Order ID is missing for this bill.'),
                      ),
                    );
                    return;
                  }
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder:
                          (_) => DriverBillViewerPage(
                            orderId: order.subgroupIdentifier,
                            billIds: ids,
                          ),
                    ),
                  );
                },
                icon: Icon(Icons.image_outlined, color: accent),
                label: TranslatedText(
                  text: "View Bill",
                  style: customTextStyle(
                    fontStyle: FontStyle.BodyM_Bold,
                    color: FontColor.FontPrimary,
                  ).copyWith(color: accent),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: accent.withOpacity(0.45)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: customColors().fontSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: TranslatedText(
            text: label,
            style: customTextStyle(
              fontStyle: FontStyle.BodyM_Regular,
              color: FontColor.FontSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: customTextStyle(
            fontStyle: FontStyle.BodyM_Bold,
            color: FontColor.FontPrimary,
          ),
        ),
      ],
    );
  }
}

class DriverBillViewerPage extends StatelessWidget {
  final String orderId;
  final List<String> billIds;

  const DriverBillViewerPage({
    super.key,
    required this.orderId,
    required this.billIds,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          orderId,
          style: customTextStyle(
            fontStyle: FontStyle.BodyL_Bold,
            color: FontColor.White,
          ),
        ),
      ),
      body: PageView.builder(
        itemCount: billIds.length,
        itemBuilder: (context, index) {
          final id = billIds[index];
          final url = posBillImageUrl(id);
          return Column(
            children: [
              if (billIds.length > 1)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    '$id  (${index + 1}/${billIds.length})',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
              Expanded(
                child: InteractiveViewer(
                  minScale: 0.8,
                  maxScale: 4,
                  child: CachedNetworkImage(
                    imageUrl: url,
                    fit: BoxFit.contain,
                    placeholder:
                        (_, __) => const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                    errorWidget:
                        (_, __, ___) => Center(
                          child: TranslatedText(
                            text: "Bill image not found",
                            textAlign: TextAlign.center,
                            style: customTextStyle(
                              fontStyle: FontStyle.BodyL_SemiBold,
                              color: FontColor.White,
                            ),
                          ),
                        ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
