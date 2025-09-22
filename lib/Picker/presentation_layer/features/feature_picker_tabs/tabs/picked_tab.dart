import 'package:ansarlogistics/constants/methods.dart';
import 'package:ansarlogistics/constants/texts.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:ansarlogistics/utils/utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:picker_driver_api/responses/orders_new_response.dart';
import 'package:ansarlogistics/Picker/presentation_layer/features/feature_picker_tabs/ui/item_tile.dart';

class PickedTab extends StatelessWidget {
  final Map<String, List<OrderItemNew>> groups;
  final bool showFinishButton;
  final VoidCallback? onFinishPick;
  final String preparationLabel;
  const PickedTab({
    super.key,
    required this.groups,
    this.showFinishButton = false,
    this.onFinishPick,
    required this.preparationLabel,
  });

  @override
  Widget build(BuildContext context) {
    if (groups.isEmpty) return const Center(child: Text('No items'));
    final keys = groups.keys.toList();
    final list = ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: keys.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (ctx, i) {
        final cat = keys[i];
        final items = groups[cat] ?? const [];
        return _CategoryExpansion(
          title: cat,
          subtitle: '${items.length} items',
          children:
              items
                  .map(
                    (e) =>
                        ItemTile(item: e, preparationLabel: preparationLabel),
                  )
                  .toList(),
        );
      },
    );

    if (!showFinishButton) return list;

    return Column(
      children: [
        Expanded(child: list),
        SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            color: Colors.white,
            child: SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: HexColor('#2DBE60'),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                onPressed: onFinishPick,
                icon: const Icon(Icons.flag, color: Colors.white),
                label: Text(
                  'Finish Pick',
                  style: customTextStyle(
                    fontStyle: FontStyle.BodyM_Bold,
                    color: FontColor.White,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CategoryExpansion extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> children;
  const _CategoryExpansion({
    required this.title,
    required this.subtitle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: customColors().backgroundTertiary),
      ),
      child: ExpansionTile(
        initiallyExpanded: true,
        tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        title: Text(
          title,
          style: customTextStyle(
            fontStyle: FontStyle.BodyM_Bold,
            color: FontColor.FontPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: customTextStyle(
            fontStyle: FontStyle.BodyS_Regular,
            color: FontColor.FontSecondary,
          ),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        children: children,
      ),
    );
  }
}
