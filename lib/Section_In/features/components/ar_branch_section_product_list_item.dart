import 'dart:ui';

import 'package:ansarlogistics/Section_In/features/components/custom_toggle_button.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:picker_driver_api/responses/branch_section_data_response.dart';

class ArBranchSectionProductListItem extends StatefulWidget {
  Branchdatum branchdatum;
  Function(String, String, String) onSectionChanged;
  ArBranchSectionProductListItem({
    super.key,
    required this.branchdatum,
    required this.onSectionChanged,
  });

  @override
  State<ArBranchSectionProductListItem> createState() =>
      _ArBranchSectionProductListItemState();
}

class _ArBranchSectionProductListItemState
    extends State<ArBranchSectionProductListItem> {
  late CarouselSliderController _sliderController;

  @override
  Widget build(BuildContext context) {
    // print("norma;l");
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
                        onTap: () {},
                        child: Container(
                          height: 119.0,
                          width: 119.0,
                          padding: const EdgeInsets.only(right: 5.0),
                          decoration: BoxDecoration(
                            border: Border(
                              right: BorderSide(color: customColors().grey),
                            ),
                          ),
                          child:
                              widget.branchdatum.imageUrl.isNotEmpty
                                  ? CachedNetworkImage(
                                    imageUrl:
                                        "https://media-qatar.ansargallery.com/catalog/product/cache/6445c95191c1b7d36f6f846ddd0b49b3/${getImageUrlEdited(widget.branchdatum.imageUrl)}",
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
                  ],
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
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
                                    widget.branchdatum.productName,
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
                                    widget.branchdatum.sku,
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  widget.branchdatum.status == 1
                                      ? Text(
                                        'Enabled',
                                        style: customTextStyle(
                                          fontStyle: FontStyle.HeaderXS_Bold,
                                          color: FontColor.Success,
                                        ),
                                      )
                                      : Text(
                                        'Disabled',
                                        style: customTextStyle(
                                          fontStyle: FontStyle.HeaderXS_Bold,
                                          color: FontColor.CarnationRed,
                                        ),
                                      ),
                                  CustomToggleButton1(
                                    isSelected:
                                        widget
                                            .branchdatum
                                            .status, // ✅ int as expected
                                    onChanged: (v) {
                                      setState(() {
                                        widget.branchdatum.status =
                                            v; // ✅ assign int directly
                                        widget.onSectionChanged(
                                          widget.branchdatum.sku,
                                          v.toString(), // 🔄 convert only for method that expects String
                                          widget.branchdatum.productName,
                                        );
                                      });
                                    },
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
        ],
      ),
    );
  }
}

String getImageUrlEdited(String base) {
  String newPath = base.replaceFirst("/catalog/product/", "");
  return newPath;
}
