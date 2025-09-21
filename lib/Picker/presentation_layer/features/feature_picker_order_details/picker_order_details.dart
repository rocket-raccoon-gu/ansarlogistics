import 'dart:math';

import 'package:ansarlogistics/app_page_injectable.dart';
import 'package:ansarlogistics/components/custom_app_components/app_bar/order_inner_app_bar.dart';
import 'package:ansarlogistics/constants/methods.dart';
import 'package:ansarlogistics/services/service_locator.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:ansarlogistics/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:picker_driver_api/responses/orders_new_response.dart';
import 'bloc/picker_order_details_cubit.dart';
import 'bloc/picker_order_details_state.dart';
import 'dart:convert';
import 'package:ansarlogistics/user_controller/user_controller.dart';

class PickerOrderDetailsPage extends StatefulWidget {
  final OrderNew orderDetails;
  final ServiceLocator serviceLocator;
  const PickerOrderDetailsPage({
    super.key,
    required this.orderDetails,
    required this.serviceLocator,
  });

  @override
  State<PickerOrderDetailsPage> createState() => _PickerOrderDetailsPageState();
}

class _PickerOrderDetailsPageState extends State<PickerOrderDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PickerOrderDetailsInnerCubit, PickerOrderDetailsState>(
      builder: (context, state) {
        return Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(0.0),
            child: AppBar(elevation: 0, backgroundColor: HexColor('#F9FBFF')),
          ),
          backgroundColor: customColors().backgroundPrimary,
          body: Column(
            children: [
              // ------------------------------- header start ----------------------------------------
              OrderInnerAppBar(
                onTapBack: () async {
                  context.gNavigationService.back(context);
                },
                orderResponseItem: widget.orderDetails,
                onTapinfo: () {
                  showTopModel(
                    context,
                    widget.serviceLocator,
                    widget.orderDetails,
                  );
                },
                onTaptranslate: () {
                  // setState(() {
                  //   translate = !translate;
                  // });
                },
              ),
              _deliveryNotes(),
              Expanded(child: _deliveryTypeGrid()),
            ],
          ),
          bottomNavigationBar: SafeArea(
            top: false,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 12.0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Text(
                      'Order Actions',
                      style: customTextStyle(
                        fontStyle: FontStyle.BodyM_Bold,
                        color: FontColor.FontPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // End Picking (primary)
                  SizedBox(
                    height: 44,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: HexColor('#D86A3A'),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      onPressed: _onEndPicking,
                      icon: const Icon(Icons.check_circle, color: Colors.white),
                      label: Text(
                        'End Picking',
                        style: customTextStyle(
                          fontStyle: FontStyle.BodyM_Bold,
                          color: FontColor.White,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Customer not answering (outline warning)
                  SizedBox(
                    height: 44,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: customColors().warning),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: _onCustomerNotAnswering,
                      icon: Icon(
                        Icons.restaurant_menu,
                        color: customColors().warning,
                      ),
                      label: Text(
                        'Customer not answering',
                        style: customTextStyle(
                          fontStyle: FontStyle.BodyM_Bold,
                          color: FontColor.FontPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Cancel Request for full order (danger subtle)
                  SizedBox(
                    height: 44,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: customColors().danger),
                        backgroundColor: customColors().danger.withOpacity(
                          0.06,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: _onCancelRequest,
                      icon: const Icon(Icons.cancel, color: Colors.red),
                      label: Text(
                        'Cancel Request for full order',
                        style: customTextStyle(
                          fontStyle: FontStyle.BodyM_Bold,
                          color: FontColor.FontPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _deliveryNotes() {
    final notes =
        widget.orderDetails.deliveryNote?.trim().isNotEmpty == true
            ? widget.orderDetails.deliveryNote!.trim()
            : (widget.orderDetails.statusText ?? '');
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(
          color: customColors().warning.withOpacity(0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: customColors().backgroundTertiary.withOpacity(0.5),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10.0,
              vertical: 6.0,
            ),
            decoration: BoxDecoration(
              color: customColors().adBackground,
              borderRadius: BorderRadius.circular(6.0),
              border: Border.all(color: customColors().warning),
            ),
            child: Text(
              'Delivery Notes',
              style: customTextStyle(
                fontStyle: FontStyle.BodyM_Bold,
                color: FontColor.FontPrimary,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 10.0,
            ),
            decoration: BoxDecoration(
              color: customColors().backgroundPrimary,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: customColors().backgroundTertiary),
            ),
            child: Text(
              notes.isEmpty ? '—' : notes,
              style: customTextStyle(
                fontStyle: FontStyle.BodyM_Regular,
                color: FontColor.FontSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _deliveryTypeGrid() {
    final summaries = _buildTypeSummaries(widget.orderDetails.items);

    if (summaries.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'No items found',
            style: customTextStyle(
              fontStyle: FontStyle.BodyM_Regular,
              color: FontColor.FontSecondary,
            ),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            // Give tiles a bit more vertical room to avoid Column overflow
            childAspectRatio: 0.85,
          ),
          itemCount: summaries.length,
          itemBuilder: (context, index) => _typeCard(summaries[index]),
        ),
      ),
    );
  }

  List<_TypeSummary> _buildTypeSummaries(List<OrderItemNew> items) {
    final Map<String, List<OrderItemNew>> grouped = {};
    for (final it in items) {
      final key = (it.deliveryType ?? '').toLowerCase();
      if (key.isEmpty) continue;
      grouped.putIfAbsent(key, () => []).add(it);
    }

    final List<_TypeSummary> out = [];

    Map<String, _TypeMeta> meta = {
      'exp': _TypeMeta(
        code: 'exp',
        title: 'EXP (Express)',
        color: HexColor('#2DBE60'),
        statusLabel:
            getStatus(widget.orderDetails.suborderStatuses?['exp']) ??
            'Started Picking',
      ),
      'nol': _TypeMeta(
        code: 'nol',
        title: 'NOL (Normal)',
        color: HexColor('#2D7EFF'),
        statusLabel:
            getStatus(widget.orderDetails.suborderStatuses?['nol']) ??
            'Assigned Picker',
      ),
      'war': _TypeMeta(
        code: 'war',
        title: 'WAR (Warehouse)',
        color: customColors().mattPurple,
        statusLabel:
            getStatus(widget.orderDetails.suborderStatuses?['war']) ??
            'Picking Completed',
      ),
      'vpo': _TypeMeta(
        code: 'vpo',
        title: 'VPO (Vendor PO)',
        color: HexColor('#F39C12'),
        statusLabel:
            getStatus(widget.orderDetails.suborderStatuses?['vpo']) ??
            'Assigned Picker',
      ),
      'sup': _TypeMeta(
        code: 'sup',
        title: 'SUP (Supplier)',
        color: customColors().danger,
        statusLabel:
            getStatus(widget.orderDetails.suborderStatuses?['sup']) ??
            'Assigned Picker',
      ),
      'aby': _TypeMeta(
        code: 'aby',
        title: 'ABY',
        color: HexColor('#00B8D9'),
        statusLabel:
            getStatus(widget.orderDetails.suborderStatuses?['aby']) ??
            'Assigned Picker',
      ),
      'typ': _TypeMeta(
        code: 'typ',
        title: 'TYP (Type)',
        color: HexColor('#2D7EFF'),
        statusLabel:
            getStatus(widget.orderDetails.suborderStatuses?['typ']) ??
            'Assigned Picker',
      ),
    };

    grouped.forEach((code, list) {
      final m =
          meta[code] ??
          _TypeMeta(
            code: code,
            title: code.toUpperCase(),
            color: customColors().fontPrimary,
            statusLabel: 'Assigned Picker',
          );

      // Item-status based counts
      int assignedCount = 0;
      int startPickingCount = 0;
      num subtotal = 0;
      for (final it in list) {
        final st = (it.itemStatus ?? '').toLowerCase();
        // if (st == 'assigned_picker') assignedCount++;
        if (st == 'end_picking') startPickingCount++;
        subtotal += (it.rowTotalInclTax ?? it.rowTotal ?? 0);
      }

      assignedCount = list.length;

      out.add(
        _TypeSummary(
          meta: m,
          assignedCount: assignedCount,
          startPickingCount: startPickingCount,
          subtotal: subtotal,
        ),
      );
    });

    final order = ['exp', 'nol', 'war', 'vpo', 'sup', 'aby', 'typ'];
    out.sort(
      (a, b) =>
          order.indexOf(a.meta.code).compareTo(order.indexOf(b.meta.code)),
    );
    return out;
  }

  Widget _typeCard(_TypeSummary t) {
    final denom =
        (t.assignedCount == 0)
            ? (t.startPickingCount == 0 ? 1 : t.startPickingCount)
            : t.assignedCount;
    final ratio =
        (denom == 0) ? 0.0 : (t.startPickingCount / denom).clamp(0.0, 1.0);

    log(t.assignedCount);

    return InkWell(
      onTap: () {
        context.gNavigationService.openPickerDashboardPage(
          context,
          arg: {
            "suborder_id": t.meta.code,
            "order_id": widget.orderDetails.id,
            "order_items": widget.orderDetails.items,
            "preparation_label": widget.orderDetails.subgroupIdentifier,
          },
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: customColors().backgroundTertiary),
        ),
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              t.meta.title,
              style: customTextStyle(
                fontStyle: FontStyle.BodyM_Bold,
                color: FontColor.FontPrimary,
              ).copyWith(color: t.meta.color),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 60,
              height: 60,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 56,
                    height: 56,
                    child: CircularProgressIndicator(
                      value: ratio,
                      strokeWidth: 6,
                      backgroundColor: t.meta.color.withOpacity(0.15),
                      valueColor: AlwaysStoppedAnimation<Color>(t.meta.color),
                    ),
                  ),
                  Text(
                    '${t.startPickingCount}/${t.assignedCount}',
                    style: customTextStyle(
                      fontStyle: FontStyle.BodyM_Bold,
                      color: FontColor.FontPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical: 6.0,
                ),
                decoration: BoxDecoration(
                  color: t.meta.color,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  t.meta.statusLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: customTextStyle(
                    fontStyle: FontStyle.BodyS_Bold,
                    color: FontColor.White,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Sub Total: QAR ${t.subtotal.toStringAsFixed(2)}',
              style: customTextStyle(
                fontStyle: FontStyle.BodyM_Regular,
                color: FontColor.FontSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onEndPicking() async {
    await _updateMainOrderMain(
      status: 'end_picking',
      comment:
          "${UserController().profile.name} (${UserController().profile.empId}) is end picked the order",
    );
  }

  Future<void> _onCustomerNotAnswering() async {
    await _updateMainOrderMain(
      status: 'customer_not_answer',
      comment: 'Customer not answering',
    );
  }

  Future<void> _onCancelRequest() async {
    final ok = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Cancel full order?'),
            content: const Text(
              'Are you sure you want to send a cancel request for the full order?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Yes'),
              ),
            ],
          ),
    );
    if (ok == true) {
      await _updateMainOrderMain(
        status: 'cancel_request',
        comment: 'Cancel Request for full order',
      );
    }
  }

  Future<void> _updateMainOrderMain({
    required String status,
    required String comment,
  }) async {
    final orderId =
        widget.orderDetails.subgroupIdentifier?.toString() ??
        widget.orderDetails.id?.toString() ??
        '';
    if (orderId.isEmpty) {
      showSnackBar(
        context: context,
        snackBar: showErrorDialogue(errorMessage: 'Missing order id'),
      );
      return;
    }

    try {
      final resp = await widget.serviceLocator.tradingApi.updateMainOrderStat(
        orderid: orderId,
        orderstatus: status,
        comment: comment,
        userid: UserController().profile.id.toString(),
        latitude: UserController.userController.locationlatitude,
        longitude: UserController.userController.locationlongitude,
      );

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        final msg =
            (data['message']?.toString().isNotEmpty ?? false)
                ? data['message'].toString()
                : 'Status updated';
        showSnackBar(
          context: context,
          snackBar: showSuccessDialogue(message: msg),
        );
      } else {
        showSnackBar(
          context: context,
          snackBar: showErrorDialogue(
            errorMessage: 'Status update failed. Please try again.',
          ),
        );
      }
    } catch (e) {
      showSnackBar(
        context: context,
        snackBar: showErrorDialogue(
          errorMessage: 'Status update failed. Please try again.',
        ),
      );
    }
  }
}

class _TypeMeta {
  final String code;
  final String title;
  final Color color;
  final String statusLabel;

  _TypeMeta({
    required this.code,
    required this.title,
    required this.color,
    required this.statusLabel,
  });
}

class _TypeSummary {
  final _TypeMeta meta;
  final int assignedCount;
  final int startPickingCount;
  final num subtotal;
  _TypeSummary({
    required this.meta,
    required this.assignedCount,
    required this.startPickingCount,
    required this.subtotal,
  });
}
