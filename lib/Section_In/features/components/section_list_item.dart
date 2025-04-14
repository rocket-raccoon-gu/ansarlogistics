import 'package:ansarlogistics/Section_In/features/components/custom_toggle_button.dart';
import 'package:ansarlogistics/constants/texts.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:ansarlogistics/user_controller/user_controller.dart';
import 'package:ansarlogistics/utils/preference_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:picker_driver_api/responses/section_item_response.dart';
import 'package:carousel_slider/carousel_slider.dart';

class SectionProductListItem extends StatefulWidget {
  Sectionitem sectionitem;
  List<Map<String, dynamic>> existingUpdates;
  Function(String, String, String) onSectionChanged;
  SectionProductListItem({
    super.key,
    required this.sectionitem,
    required this.existingUpdates,
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

    final existingItem = widget.existingUpdates.firstWhere(
      (item) =>
          item['sku'] == widget.sectionitem.sku &&
          item['branch'] == currentBranch,
      orElse: () => <String, dynamic>{},
    );

    return existingItem.isNotEmpty
        ? int.parse(existingItem['status'].toString())
        : widget.sectionitem.isInStock;
  }

  @override
  Widget build(BuildContext context) {
    val = _currentStatus;

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
                                    val == 1 ? 'Enabled' : 'Disabled',
                                    style:
                                        _currentStatus == 1
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

                            // Padding(
                            //   padding: const EdgeInsets.symmetric(
                            //       horizontal: 4.0, vertical: 4.0),
                            //   child: Row(
                            //     children: [
                            //       Text("Price : "),
                            //       Text(
                            //         "${double.parse(widget.sectionitem.price)} QAR",
                            //         style: customTextStyle(
                            //             fontStyle: FontStyle.HeaderXS_SemiBold,
                            //             color: FontColor.FontPrimary),
                            //       ),
                            //     ],
                            //   ),
                            // )
                            // : SizedBox()
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
                  // widget.sectionitem.status = v;
                  widget.sectionitem.isInStock = v;
                  val = v;

                  if (UserController.userController.profile.branchCode !=
                      'Q013') {
                    final index = widget.existingUpdates.indexWhere(
                      (item) => item['sku'] == widget.sectionitem.sku,
                    );
                    if (index >= 0) {
                      widget.existingUpdates[index] = {
                        ...widget.existingUpdates[index],
                        'status': v,
                      };
                    }

                    // Save to SharedPreferences
                    PreferenceUtils.storeListmap(
                      'updates_history',
                      widget.existingUpdates,
                    );
                  }

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

// getImageViewver(
//   String name,
//   String sku,
//   List<MediaGalleryEntry> mediaGalleryEntries,
//   context,
//   CarouselSliderController sliderController,
// ) {
//   showGeneralDialog(
//     context: context,
//     barrierDismissible: true,
//     barrierLabel: "",
//     pageBuilder: (ctx, a1, a2) {
//       return Container();
//     },
//     transitionBuilder: (ctx, a1, a2, child) {
//       var curve = Curves.easeInOut.transform(a1.value);
//       return Transform.scale(
//         scale: curve,
//         child: AlertDialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(8.0),
//           ),
//           content: Stack(
//             children: [
//               Positioned(
//                 top: 0,
//                 right: 0,
//                 child: InkWell(
//                   onTap: () {
//                     Navigator.pop(context);
//                   },
//                   child: Icon(Icons.close, color: customColors().fontPrimary),
//                 ),
//               ),
//               // Column(
//               //   mainAxisSize: MainAxisSize.min,
//               //   children: [
//               //     Column(
//               //       children: [
//               //         SizedBox(
//               //           height: 250,
//               //           width: 250,
//               //           child: CarouselSlider.builder(
//               //               unlimitedMode: true,
//               //               controller: sliderController,
//               //               slideTransform: CubeTransform(),
//               //               slideIndicator: CircularSlideIndicator(
//               //                   padding: EdgeInsets.only(bottom: 32),
//               //                   indicatorBorderColor: Colors.black),
//               //               initialPage: 0,
//               //               enableAutoSlider: true,
//               //               slideBuilder: (index) {
//               //                 return Image.network(
//               //                   "https://media-qatar.ahmarket.com/media/catalog/product/cache/2b71e5a2b5266e17ec3596451a32baea/${mediaGalleryEntries[index].file.toString()}",
//               //                   fit: BoxFit.fill,
//               //                 );
//               //               },
//               //               itemCount: mediaGalleryEntries.length, itemBuilder: (BuildContext context, int index, int realIndex) {  },),
//               //         )
//               //       ],
//               //     ),
//               //     Padding(
//               //       padding: const EdgeInsets.only(top: 25.0, bottom: 25.0),
//               //       child: Column(
//               //         children: [
//               //           Row(
//               //             children: [
//               //               Expanded(
//               //                 child: Text(
//               //                   name,
//               //                   textAlign: TextAlign.center,
//               //                   style: customTextStyle(
//               //                       fontStyle: FontStyle.BodyL_Bold,
//               //                       color: FontColor.Primary),
//               //                 ),
//               //               ),
//               //             ],
//               //           ),
//               //           Row(
//               //             children: [
//               //               Expanded(
//               //                 child: Text(
//               //                   sku,
//               //                   textAlign: TextAlign.center,
//               //                   style: customTextStyle(
//               //                       fontStyle: FontStyle.BodyL_Bold,
//               //                       color: FontColor.Primary),
//               //                 ),
//               //               ),
//               //             ],
//               //           ),
//               //         ],
//               //       ),
//               //     ),
//               //   ],
//               // )
//             ],
//           ),
//         ),
//       );
//     },
//   );
// }
// }

String getImageUrlEdited(String base) {
  String newPath = base.replaceFirst("/catalog/product/", "");
  return newPath;
}
