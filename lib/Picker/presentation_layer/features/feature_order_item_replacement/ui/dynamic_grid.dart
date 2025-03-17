import 'package:ansarlogistics/themes/style.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:picker_driver_api/responses/similiar_item_response.dart';

class DynamicGrid extends StatefulWidget {
  List<SimiliarItems> replacements;
  int selectedindex;
  final void Function(int) onSelect;
  DynamicGrid({
    super.key,
    required this.replacements,
    required this.selectedindex,
    required this.onSelect,
  });

  @override
  State<DynamicGrid> createState() => _DynamicGridState();
}

class _DynamicGridState extends State<DynamicGrid> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: StaggeredGrid.count(
        crossAxisCount: 2,
        mainAxisSpacing: 5.0,
        crossAxisSpacing: 5.0,
        children: List.generate(widget.replacements.length, (index) {
          return InkWell(
            onTap: () {
              widget.onSelect(index);
            },
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: customColors().fontTertiary.withOpacity(0.5),
                ),
                borderRadius: BorderRadius.circular(5.0),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Container(
                        height: 128.0,
                        width: 128.0,
                        child: Center(
                          child: CachedNetworkImage(
                            imageUrl:
                                "https://www.ahmarket.com/pub/media/catalog/product/cache/c2449e95328d0e21c69cf45a1dbd3424/${widget.replacements[index].image}",
                            imageBuilder: (context, imageProvider) {
                              return Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: imageProvider,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            },
                            placeholder:
                                (context, url) => Center(
                                  child: Image.asset(
                                    'assets/Iphone_spinner.gif',
                                  ),
                                ),
                            errorWidget:
                                (context, url, error) => Image.network(
                                  'https://media-qatar.ansargallery.com/catalog/product/placeholder/default/thumbnail-placeholder.jpg',
                                ),
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            "SKU: ${widget.replacements[index].sku}",
                            style: customTextStyle(
                              fontStyle: FontStyle.Inter_Medium,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.replacements[index].name.toString(),
                              style: customTextStyle(
                                fontStyle: FontStyle.Inter_Medium,
                                color: FontColor.FontPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                double.parse(
                                  widget.replacements[index].price,
                                ).toStringAsFixed(2),
                                style: customTextStyle(
                                  fontStyle: FontStyle.BodyL_Bold,
                                  color: FontColor.FontPrimary,
                                ),
                              ),
                              Text(
                                " QAR",
                                style: customTextStyle(
                                  fontStyle: FontStyle.BodyL_Bold,
                                  color: FontColor.FontSecondary,
                                ),
                              ),
                            ],
                          ),
                          widget.selectedindex == index
                              ? Image.asset("assets/replace_selected.png")
                              : Image.asset("assets/replace_frame.png"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
        // staggeredTiles: List.generate(
        //   replacements.length,
        //   (index) => StaggeredTile.fit(2),
        // ),
      ),
    );
  }
}
