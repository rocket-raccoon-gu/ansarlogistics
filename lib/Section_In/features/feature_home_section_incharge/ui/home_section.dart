import 'package:ansarlogistics/Picker/repository_layer/pdf_service.dart';
import 'package:ansarlogistics/Section_In/features/components/section_list_item.dart';
import 'package:ansarlogistics/Section_In/features/feature_home_section_incharge/bloc/home_section_incharge_cubit.dart';
import 'package:ansarlogistics/Section_In/features/feature_home_section_incharge/bloc/home_section_incharge_state.dart';
import 'package:ansarlogistics/components/custom_app_components/buttons/animation_switch.dart';
import 'package:ansarlogistics/components/custom_app_components/buttons/basket_button.dart';
import 'package:ansarlogistics/components/custom_app_components/textfields/custom_search_field.dart';
import 'package:ansarlogistics/constants/texts.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:ansarlogistics/user_controller/user_controller.dart';
import 'package:ansarlogistics/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeSection extends StatefulWidget {
  HomeSectionInchargeState state;
  HomeSection({super.key, required this.state});

  @override
  State<HomeSection> createState() => _HomeSectionState();
}

class _HomeSectionState extends State<HomeSection> {
  GlobalKey<FormFieldState<String>> _ordersearchFormKey =
      GlobalKey<FormFieldState<String>>();

  bool searchactive = false;

  bool _isSyncDisabled = false;

  final _searchcontroller = TextEditingController();

  int _selectedCategoryIndex = 0;

  final _barcodeController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // _loadInitialData();
    });
  }

  // Get categories based on employee ID
  List<Map<String, dynamic>> _getCategories() {
    final empId = UserController().profile.empId?.toLowerCase() ?? '';

    if (empId == 'ahqa_veg') {
      return producecats;
    } else if (empId == 'ahqa_butch') {
      return butchcats;
    } else if (empId == 'ahqa_fish') {
      return fishcats;
    }

    // Default to produce categories if no match found
    return producecats;
  }

  @override
  Widget build(BuildContext context) {
    final categories = _getCategories();
    // print("home section");
    return Stack(
      children: [
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 15.0,
              ),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: customColors().fontTertiary),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: CustomSearchField(
                  searchFormKey: _ordersearchFormKey,
                  keyboardType: TextInputType.text,
                  focus:
                      BlocProvider.of<HomeSectionInchargeCubit>(
                        context,
                      ).searchactive,
                  onFilter: () {},
                  onSearch: (p0) {
                    BlocProvider.of<HomeSectionInchargeCubit>(
                      context,
                    ).updatesearchorder(
                      UserController().sectionitems,
                      p0.toString(),
                    );
                    // if (p0 != '') {
                    //   setState(() {
                    //     searchactive = true;
                    //   });
                    // } else {
                    //   setState(() {
                    //     searchactive = false;
                    //   });
                    // }
                  },
                  controller: _searchcontroller,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap:
                          _isSyncDisabled
                              ? null
                              : () async {
                                final confirmed = await showDialog<bool>(
                                  context: context,
                                  builder:
                                      (ctx) => AlertDialog(
                                        title: Text('Sync Data'),
                                        content: Text(
                                          'Are you sure you want to sync data?\n'
                                          'This will send your latest stock changes to the server.',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed:
                                                () => Navigator.of(
                                                  ctx,
                                                ).pop(false),
                                            child: Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed:
                                                () =>
                                                    Navigator.of(ctx).pop(true),
                                            child: Text('Yes, Sync'),
                                          ),
                                        ],
                                      ),
                                );

                                if (confirmed != true) return;

                                setState(() {
                                  _isSyncDisabled = true;
                                });

                                showSnackBar(
                                  context: context,
                                  snackBar: SnackBar(
                                    content: Text("Syncing data..."),
                                  ),
                                );
                                try {
                                  await context
                                      .read<HomeSectionInchargeCubit>()
                                      .syncData();
                                } finally {
                                  if (!mounted) return;
                                  setState(() {
                                    _isSyncDisabled = false;
                                  });
                                }
                              },
                      child: Container(
                        height: 40.0,
                        decoration: BoxDecoration(
                          color:
                              _isSyncDisabled
                                  ? customColors().islandAqua.withOpacity(0.5)
                                  : customColors().islandAqua,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.sync, color: customColors().fontPrimary),
                            Text(
                              "Sync Data",
                              style: customTextStyle(
                                fontStyle: FontStyle.BodyL_Bold,
                                color: FontColor.FontPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ChoiceChip(
                      label: Text(category['name']),
                      selected: _selectedCategoryIndex == index,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategoryIndex = index;
                        });
                        // Handle category selection
                        // You can add your filtering logic here
                        final cubit = BlocProvider.of<HomeSectionInchargeCubit>(
                          context,
                        );
                        if (category['id'] == 0) {
                          // Show all items
                          cubit.loadProducts();
                        } else {
                          cubit.updateloadProducts(category['id']);
                          // Filter by category
                          // You'll need to implement the filtering logic based on your data structure
                          // For example:
                          // final filteredItems = UserController().sectionitems.where((item) => item.categoryId == category['id']).toList();
                          // cubit.updatesearchorder(filteredItems, _searchcontroller.text);
                        }
                      },
                    ),
                  );
                },
              ),
            ),

            if (widget.state is HomeSectionInchargeLoading)
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [loadingindecator()],
                ),
              )
            else
              Expanded(
                child: MediaQuery.removePadding(
                  removeTop: true,
                  context: context,
                  child: ListView(
                    physics: AlwaysScrollableScrollPhysics(),
                    children: [
                      if (BlocProvider.of<HomeSectionInchargeCubit>(
                            context,
                          ).searchactive &&
                          BlocProvider.of<HomeSectionInchargeCubit>(
                            context,
                          ).searchresult.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18.0,
                            vertical: 10.0,
                          ),
                          child: ListView.builder(
                            itemCount:
                                BlocProvider.of<HomeSectionInchargeCubit>(
                                  context,
                                ).searchresult.length,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              return SectionProductListItem(
                                sectionitem:
                                    BlocProvider.of<HomeSectionInchargeCubit>(
                                      context,
                                    ).searchresult[index],
                                existingUpdates:
                                    BlocProvider.of<HomeSectionInchargeCubit>(
                                      context,
                                    ).updateHistory,
                                statusHistory:
                                    BlocProvider.of<HomeSectionInchargeCubit>(
                                      context,
                                    ).statusHistories,
                                onSectionChanged: (p0, p1, p2) {
                                  context
                                      .read<HomeSectionInchargeCubit>()
                                      .addToStockStatusList(
                                        p0,
                                        p1,
                                        p2,
                                        BlocProvider.of<
                                          HomeSectionInchargeCubit
                                        >(context).searchresult[index].imageUrl,
                                      );
                                },
                              );
                            },
                          ),
                        )
                      else if (BlocProvider.of<HomeSectionInchargeCubit>(
                            context,
                          ).searchactive &&
                          BlocProvider.of<HomeSectionInchargeCubit>(
                            context,
                          ).searchresult.isEmpty)
                        Column(
                          children: [
                            Image.network(
                              '${noimageurl}',
                              height: 180.0,
                              width: 180.0,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                "No Products Found..!",
                                style: customTextStyle(
                                  fontStyle: FontStyle.HeaderXS_SemiBold,
                                ),
                              ),
                            ),
                          ],
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18.0),
                          child: ListView.builder(
                            itemCount:
                                BlocProvider.of<HomeSectionInchargeCubit>(
                                  context,
                                ).sectionitems.length,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              return SectionProductListItem(
                                sectionitem:
                                    BlocProvider.of<HomeSectionInchargeCubit>(
                                      context,
                                    ).sectionitems[index],
                                existingUpdates:
                                    BlocProvider.of<HomeSectionInchargeCubit>(
                                      context,
                                    ).updateHistory,
                                statusHistory:
                                    BlocProvider.of<HomeSectionInchargeCubit>(
                                      context,
                                    ).statusHistories,
                                onSectionChanged: (p0, p1, p2) {
                                  context
                                      .read<HomeSectionInchargeCubit>()
                                      .addToStockStatusList(
                                        p0,
                                        p1,
                                        p2,
                                        BlocProvider.of<
                                          HomeSectionInchargeCubit
                                        >(context).sectionitems[index].imageUrl,
                                      );
                                },
                              );
                            },
                          ),
                        ),

                      SizedBox(height: 60.0),
                    ],
                  ),
                ),
              ),

            // Add PDF Report Button here
          ],
        ),

        // Item counts display
        if (context.read<HomeSectionInchargeCubit>().stockUpdates.isNotEmpty ||
            UserController().sectionitems.isNotEmpty)
          // Positioned(
          //   bottom: 95.0,
          //   left: 15.0,
          //   right: 15.0,
          //   child: Container(
          //     padding: EdgeInsets.all(12),
          //     decoration: BoxDecoration(
          //       color: customColors().backgroundPrimary,
          //       borderRadius: BorderRadius.circular(12),
          //       boxShadow: [
          //         BoxShadow(
          //           color: Colors.black.withOpacity(0.1),
          //           blurRadius: 8,
          //           offset: Offset(0, 2),
          //         ),
          //       ],
          //       border: Border.all(
          //         color: customColors().fontTertiary.withOpacity(0.3),
          //       ),
          //     ),
          //     child: Row(
          //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //       children: [
          //         if (context
          //             .read<HomeSectionInchargeCubit>()
          //             .stockUpdates
          //             .isNotEmpty)
          //           Expanded(
          //             child: Column(
          //               children: [
          //                 Text(
          //                   '${context.read<HomeSectionInchargeCubit>().stockUpdates.length}',
          //                   style: TextStyle(
          //                     fontSize: 20,
          //                     fontWeight: FontWeight.bold,
          //                     color: customColors().red1,
          //                   ),
          //                 ),
          //                 SizedBox(height: 4),
          //                 Text(
          //                   'Stock Updates',
          //                   style: TextStyle(
          //                     fontSize: 12,
          //                     color: customColors().fontSecondary,
          //                   ),
          //                 ),
          //               ],
          //             ),
          //           ),
          //         // if (context
          //         //         .read<HomeSectionInchargeCubit>()
          //         //         .stockUpdates
          //         //         .isNotEmpty &&
          //         //     UserController().sectionitems.isNotEmpty)
          //         // Container(
          //         //   width: 1,
          //         //   height: 40,
          //         //   color: customColors().fontTertiary.withOpacity(0.3),
          //         // ),
          //         // if (UserController().sectionitems.isNotEmpty)
          //         //   Expanded(
          //         //     child: Column(
          //         //       children: [
          //         //         Text(
          //         //           '${UserController().sectionitems.length}',
          //         //           style: TextStyle(
          //         //             fontSize: 20,
          //         //             fontWeight: FontWeight.bold,
          //         //             color: customColors().primary,
          //         //           ),
          //         //         ),
          //         //         SizedBox(height: 4),
          //         //         Text(
          //         //           'Section Items',
          //         //           style: TextStyle(
          //         //             fontSize: 12,
          //         //             color: customColors().fontSecondary,
          //         //           ),
          //         //         ),
          //         //       ],
          //         //     ),
          //         //   ),
          //         // if (context
          //         //         .read<HomeSectionInchargeCubit>()
          //         //         .stockUpdates
          //         //         .isNotEmpty &&
          //         //     UserController().sectionitems.isNotEmpty)
          //         //   Container(
          //         //     width: 1,
          //         //     height: 40,
          //         //     color: customColors().fontTertiary.withOpacity(0.3),
          //         //   ),
          //         // if (context
          //         //         .read<HomeSectionInchargeCubit>()
          //         //         .stockUpdates
          //         //         .isNotEmpty &&
          //         //     UserController().sectionitems.isNotEmpty)
          //         //   Expanded(
          //         //     child: Column(
          //         //       children: [
          //         //         Text(
          //         //           '${context.read<HomeSectionInchargeCubit>().stockUpdates.length + UserController().sectionitems.length}',
          //         //           style: TextStyle(
          //         //             fontSize: 20,
          //         //             fontWeight: FontWeight.bold,
          //         //             color: customColors().accent,
          //         //           ),
          //         //         ),
          //         //         SizedBox(height: 4),
          //         //         Text(
          //         //           'Total Items',
          //         //           style: TextStyle(
          //         //             fontSize: 12,
          //         //             color: customColors().fontSecondary,
          //         //           ),
          //         //         ),
          //         //       ],
          //         //     ),
          //         //   ),
          //       ],
          //     ),
          //   ),
          // ),
          // Single comprehensive report button - show if there's any data to report
          // Existing PDF button stays as is...
          // New: Add Item button - opens bottom sheet
          Positioned(
            bottom: 25.0,
            left: 15.0,
            child: InkWell(
              onTap: () {
                _barcodeController.clear();
                _nameController.clear();

                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  builder: (ctx) {
                    return Padding(
                      padding: EdgeInsets.only(
                        left: 16,
                        right: 16,
                        bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
                        top: 16,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Add New Item',
                            style: customTextStyle(
                              fontStyle: FontStyle.HeaderXS_Bold,
                            ),
                          ),
                          SizedBox(height: 12),
                          TextField(
                            controller: _barcodeController,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              labelText: 'Barcode / SKU',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          SizedBox(height: 12),
                          TextField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: 'Product Name',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {
                                final sku = _barcodeController.text.trim();
                                final name = _nameController.text.trim();

                                if (sku.isEmpty || name.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Please enter barcode and name',
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                await context
                                    .read<HomeSectionInchargeCubit>()
                                    .addNewTempItem(sku: sku, name: name);

                                Navigator.pop(ctx);
                              },
                              child: Text('Submit'),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              child: Container(
                height: 60.0,
                width: 60.0,
                decoration: BoxDecoration(
                  color: customColors().accent,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.add,
                    color: customColors().backgroundPrimary,
                  ),
                ),
              ),
            ),
          ),

        if (context.read<HomeSectionInchargeCubit>().stockUpdates.isNotEmpty ||
            UserController().sectionitems.isNotEmpty)
          Positioned(
            bottom: 25.0,
            right: 15.0,
            child: InkWell(
              onTap: () async {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder:
                      (context) => AlertDialog(
                        content: Row(
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(width: 16),
                            Text('Generating report...'),
                          ],
                        ),
                      ),
                );

                // try {
                //   final file = await PdfService.generateComprehensivePdf(
                //     context.read<HomeSectionInchargeCubit>().stockUpdates,
                //     UserController().sectionitems,
                //     context.read<HomeSectionInchargeCubit>().statusHistories,
                //   );
                //   Navigator.pop(context);
                //   await PdfService.shareComprehensivePdf(file);
                // } catch (e) {
                //   Navigator.pop(context);
                //   ScaffoldMessenger.of(context).showSnackBar(
                //     SnackBar(content: Text('Error generating report: $e')),
                //   );
                // }
              },
              child: Container(
                height: 60.0,
                width: 60.0,
                decoration: BoxDecoration(
                  color: customColors().primary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.picture_as_pdf,
                    color: customColors().backgroundPrimary,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
        //           ? Padding(
        //             padding: const EdgeInsets.symmetric(
        //               horizontal: 20.0,
        //               vertical: 8.0,
        //             ),
        //             child: ElevatedButton.icon(
        //               onPressed: () async {
        //                 final cubit = context.read<HomeSectionInchargeCubit>();
        //                 final loading = showDialog(
        //                   context: context,
        //                   barrierDismissible: false,
        //                   builder:
        //                       (context) => AlertDialog(
        //                         content: Row(
        //                           children: [
        //                             CircularProgressIndicator(),
        //                             SizedBox(width: 16),
        //                             Text('Generating report...'),
        //                           ],
        //                         ),
        //                       ),
        //                 );

        //                 try {
        //                   final file = await PdfService.generatePdf(
        //                     context
        //                         .read<HomeSectionInchargeCubit>()
        //                         .stockUpdates,
        //                   );
        //                   Navigator.pop(context);
        //                   await PdfService.sharePdf(file);
        //                 } catch (e) {
        //                   Navigator.pop(context);
        //                   ScaffoldMessenger.of(context).showSnackBar(
        //                     SnackBar(
        //                       content: Text('Error generating report: $e'),
        //                     ),
        //                   );
        //                 }
        //               },
        //               icon: Icon(Icons.picture_as_pdf),
        //               label: Text('Generate PDF Report'),
        //               style: ElevatedButton.styleFrom(
        //                 backgroundColor: customColors().primary,
        //                 foregroundColor: customColors().fontPrimary,
        //                 minimumSize: Size(double.infinity, 48),
        //               ),
        //             ),
        //           )
        //           : SizedBox(),
        // ),
      