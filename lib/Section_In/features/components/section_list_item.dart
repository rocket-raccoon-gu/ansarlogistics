import 'package:ansarlogistics/Section_In/features/components/custom_toggle_button.dart';
import 'package:ansarlogistics/constants/texts.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:ansarlogistics/user_controller/user_controller.dart';
import 'package:ansarlogistics/utils/preference_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:picker_driver_api/responses/check_section_status_list.dart';
import 'package:picker_driver_api/responses/section_item_response.dart';
import 'package:carousel_slider/carousel_slider.dart';

class SectionProductListItem extends StatefulWidget {
  Sectionitem sectionitem;
  List<Map<String, dynamic>> existingUpdates;
  List<StatusHistory> statusHistory;
  Function(String, String, String) onSectionChanged;
  SectionProductListItem({
    super.key,
    required this.sectionitem,
    required this.existingUpdates,
    required this.statusHistory,
    required this.onSectionChanged,
  });

  @override
  State<SectionProductListItem> createState() => _SectionProductListItemState();
}

class _SectionProductListItemState extends State<SectionProductListItem> {
  late CarouselSliderController _sliderController;

  int val = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _sliderController = CarouselSliderController();
  }

  int get _currentStatus {
    final currentBranch = UserController.userController.profile.branchCode;
    final currentSku = widget.sectionitem.sku;

    if (UserController.userController.profile.branchCode != 'Q013') {
      // 1. Check statusHistory for all matching entries
      final statusHistoryItems =
          widget.statusHistory
              .where(
                (item) =>
                    item.sku == currentSku && item.branchCode == currentBranch,
              )
              .toList();

      if (statusHistoryItems.isNotEmpty) {
        // Sort by timestamp descending (newest first) and take the first item
        statusHistoryItems.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        return statusHistoryItems.first.status;
      }

      // 2. Check existingUpdates for all matching entries
      final existingItems =
          widget.existingUpdates
              .where(
                (item) =>
                    item['sku'] == currentSku &&
                    item['branch'] == currentBranch,
              )
              .toList();

      if (existingItems.isNotEmpty) {
        // Sort by timestamp if available (newest first)
        existingItems.sort((a, b) {
          final aTime = a['updated_at'] ?? '';
          final bTime = b['updated_at'] ?? '';
          return bTime.compareTo(aTime); // Descending sort
        });
        return int.parse(existingItems.first['status'].toString());
      }
    }

    // 3. Fall back to default status
    return widget.sectionitem.isInStock;
  }

  @override
  Widget build(BuildContext context) {
    val = _currentStatus;
    // print(
    //   "https://media-qatar.ansargallery.com/catalog/product/cache/6445c95191c1b7d36f6f846ddd0b49b3/${getImageUrlEdited(widget.sectionitem.imageUrl)}",
    // );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              border: Border.all(color: customColors().fontTertiary),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Row(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10.0,
                        horizontal: 5.0,
                      ),
                      child: InkWell(
                        onTap: () {
                          // getImageViewver(
                          //   widget.sectionitem.productName,
                          //   widget.sectionitem.sku,
                          //   widget.sectionitem.imageUrl,
                          //   context,
                          //   _sliderController,
                          // );
                        },
                        child: Container(
                          height: 119.0,
                          width: 119.0,
                          padding: const EdgeInsets.only(right: 5.0),
                          decoration: BoxDecoration(
                            border: Border(
                              right: BorderSide(color: customColors().grey),
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),

                            child:
                                widget.sectionitem.imageUrl.isNotEmpty
                                    ? CachedNetworkImage(
                                      imageUrl:
                                          "https://media-qatar.ansargallery.com/catalog/product/cache/6445c95191c1b7d36f6f846ddd0b49b3/${getImageUrlEdited(widget.sectionitem.imageUrl)}",
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
                                      errorWidget: (context, url, error) {
                                        return Image.asset(
                                          'assets/placeholder.png',
                                        );
                                      },
                                    )
                                    : Image.asset('assets/placeholder.png'),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: customColors().backgroundPrimary,
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 5.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    widget.sectionitem.productName,
                                    style: customTextStyle(
                                      fontStyle: FontStyle.HeaderXS_Bold,
                                      color: FontColor.FontPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 10.0,
                                horizontal: 3.0,
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    widget.sectionitem.sku,
                                    style: customTextStyle(
                                      fontStyle: FontStyle.HeaderXS_Bold,
                                      color: FontColor.FontPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 5.0,
                                horizontal: 3.0,
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    // Check if SKU exists in updates, then use its status
                                    widget.sectionitem.isInStock == 1
                                        ? 'Enabled'
                                        : 'Disabled',
                                    style:
                                        widget.sectionitem.isInStock == 1
                                            ? customTextStyle(
                                              fontStyle:
                                                  FontStyle.HeaderXS_Bold,
                                              color: FontColor.Success,
                                            )
                                            : customTextStyle(
                                              fontStyle:
                                                  FontStyle.HeaderXS_Bold,
                                              color: FontColor.CarnationRed,
                                            ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 12.0,
            right: 3.0,
            child: CustomToggleButton1(
              isSelected: val,
              onChanged: (v) {
                setState(() {
                  // Update the in-stock status locally
                  widget.sectionitem.isInStock = v;
                  val = v;

                  // Notify parent widget about the change (if needed)
                  widget.onSectionChanged(
                    widget.sectionitem.sku,
                    widget.sectionitem.isInStock.toString(),
                    widget.sectionitem.productName,
                  );
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}

String getImageUrlEdited(String base) {
  String newPath = base.replaceFirst("/catalog/product/", "");
  return newPath;
}
