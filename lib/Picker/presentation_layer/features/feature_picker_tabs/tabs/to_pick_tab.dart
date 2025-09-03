import 'package:ansarlogistics/Picker/presentation_layer/features/feature_picker_tabs/ui/item_tile.dart';
import 'package:ansarlogistics/constants/methods.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:flutter/material.dart';
import 'package:picker_driver_api/responses/orders_new_response.dart';

class ToPickTab extends StatelessWidget {
  final Map<String, List<OrderItemNew>> groups;
  final String preparationLabel;
  const ToPickTab({
    super.key,
    required this.groups,
    required this.preparationLabel,
  });

  @override
  Widget build(BuildContext context) {
    if (groups.isEmpty) {
      return const Center(child: Text('No items'));
    }
    final keys = groups.keys.toList();
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: keys.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (ctx, i) {
        final cat = keys[i];
        final items = groups[cat] ?? const [];
        final pickedCount =
            items
                .where(
                  (e) => (e.itemStatus ?? '').toLowerCase() == 'end_picking',
                )
                .length;

        return _CategoryExpansion(
          title: cat,
          subtitle:
              '${pickedCount}/${items.length} items picked $preparationLabel',
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
