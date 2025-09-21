import 'package:ansarlogistics/constants/methods.dart';
import 'package:ansarlogistics/constants/texts.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:picker_driver_api/responses/orders_new_response.dart';

class PickedTab extends StatelessWidget {
  final Map<String, List<OrderItemNew>> groups;
  const PickedTab({super.key, required this.groups});

  @override
  Widget build(BuildContext context) {
    if (groups.isEmpty) return const Center(child: Text('No items'));
    final keys = groups.keys.toList();
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: keys.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (ctx, i) {
        final cat = keys[i];
        final items = groups[cat] ?? const [];
        return _CategoryExpansion(
          title: cat,
          subtitle: '${items.length} items',
          children: items.map((e) => _ItemTile(e)).toList(),
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

class _ItemTile extends StatelessWidget {
  final OrderItemNew item;
  const _ItemTile(this.item);

  @override
  Widget build(BuildContext context) {
    final raw = (item.imageUrl ?? '').toString().trim();
    final imgUrl = raw.isEmpty ? noimageurl : resolveImageUrl(raw);
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: customColors().backgroundTertiary),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: customColors().backgroundSecondary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: CachedNetworkImage(
              imageUrl: imgUrl,
              fit: BoxFit.contain,
              placeholder:
                  (context, _) => Center(
                    child: Image.asset(
                      'assets/Iphone_spinner.gif',
                      width: 32,
                      height: 32,
                    ),
                  ),
              errorWidget:
                  (context, _, __) =>
                      Image.network(noimageurl, fit: BoxFit.contain),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name ?? '-',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: customTextStyle(
                    fontStyle: FontStyle.BodyM_Bold,
                    color: FontColor.FontPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'SKU: ${item.sku ?? '-'}',
                  style: customTextStyle(
                    fontStyle: FontStyle.BodyS_Regular,
                    color: FontColor.FontSecondary,
                  ),
                ),

                Text(
                  'Price: ${item.price ?? '-'}',
                  style: customTextStyle(
                    fontStyle: FontStyle.BodyS_Regular,
                    color: FontColor.FontSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFE7F6EC),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '${double.parse(item.qtyOrdered ?? '0').toInt()}/${double.parse(item.qtyOrdered ?? '0').toInt()}',
              style: customTextStyle(
                fontStyle: FontStyle.BodyS_Bold,
                color: FontColor.FontPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
