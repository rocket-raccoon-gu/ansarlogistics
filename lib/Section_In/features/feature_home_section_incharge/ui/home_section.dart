import 'package:ansarlogistics/Picker/repository_layer/more_content.dart';
import 'package:ansarlogistics/Section_In/features/components/section_list_item.dart';
import 'package:ansarlogistics/Section_In/features/feature_home_section_incharge/bloc/home_section_incharge_cubit.dart';
import 'package:ansarlogistics/Section_In/features/feature_home_section_incharge/bloc/home_section_incharge_state.dart';
import 'package:ansarlogistics/components/custom_app_components/buttons/animation_switch.dart';
import 'package:ansarlogistics/components/custom_app_components/buttons/basket_button.dart';
import 'package:ansarlogistics/components/custom_app_components/textfields/custom_text_form_field.dart';
import 'package:ansarlogistics/constants/texts.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:ansarlogistics/user_controller/user_controller.dart';
import 'package:ansarlogistics/utils/preference_utils.dart';
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
  bool _isSyncDisabled = false;
  final _searchcontroller = TextEditingController();

  Widget _buildCategoryChip(String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: customColors().islandAqua,
        backgroundColor: Colors.grey[200],
        onSelected: (selected) {
          // Handle category selection
        },
      ),
    );
  }

  Widget _buildItemCard(String name, String description, String price) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: customColors().fontTertiary.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.image, color: Colors.grey[400]),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: customTextStyle(
                    fontStyle: FontStyle.BodyM_SemiBold,
                    color: FontColor.FontPrimary,
                  ),
                ),
                Text(
                  description,
                  style: customTextStyle(
                    fontStyle: FontStyle.BodyS_Regular,
                    color: FontColor.FontSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            price,
            style: customTextStyle(
              fontStyle: FontStyle.BodyM_Bold,
              color: FontColor.FontPrimary,
            ),
          ),
          SizedBox(width: 8),
          Checkbox(
            value: false,
            onChanged: (value) {
              // Handle item selection
            },
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // _loadInitialData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProfile = UserController().profile;
    // final sectionName =
    //     userProfile.empId.contains("fish")
    //         ? "fish section"
    //         : userProfile.empId.contains("veg")
    //         ? "vegetable section"
    //         : userProfile.empId.contains("butch")
    //         ? "butcher section"
    //         : "section";

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Header with greeting, logout and PDF buttons
                Container(
                  padding: const EdgeInsets.all(6.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.account_circle,
                        size: 35,
                        color: customColors().islandAqua,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Hi, ${userProfile.name}",
                              style: customTextStyle(
                                fontStyle: FontStyle.HeaderS_SemiBold,
                                color: FontColor.FontPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // PDF Button
                      InkWell(
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

                          // Simulate PDF generation
                          await Future.delayed(Duration(seconds: 2));
                          Navigator.pop(context);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'PDF report generated successfully!',
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: customColors().primary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.picture_as_pdf,
                            color: customColors().backgroundPrimary,
                            size: 20,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      // Logout Button
                      IconButton(
                        onPressed: () {
                          // Add logout functionality here
                          showDialog(
                            context: context,
                            builder:
                                (ctx) => AlertDialog(
                                  title: Text('Logout'),
                                  content: Text(
                                    'Are you sure you want to logout?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed:
                                          () => Navigator.of(ctx).pop(false),
                                      child: Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        Navigator.of(ctx).pop(true);

                                        await PreferenceUtils.removeDataFromShared(
                                          "userCode",
                                        );
                                        await PreferenceUtils.removeDataFromShared(
                                          "profiledetails",
                                        );

                                        await logout(context);
                                      },
                                      child: Text('Logout'),
                                    ),
                                  ],
                                ),
                          );
                        },
                        icon: Icon(
                          Icons.logout,
                          color: customColors().islandAqua,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),

                // Search Bar with Add Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: customColors().fontTertiary,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: TextField(
                            controller: _searchcontroller,
                            decoration: InputDecoration(
                              hintText: "Search Orderid",
                              prefixIcon: Icon(
                                Icons.search,
                                color: customColors().fontSecondary,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            onChanged: (value) {
                              BlocProvider.of<HomeSectionInchargeCubit>(
                                context,
                              ).updatesearchorder(
                                UserController().sectionitems,
                                value,
                              );
                            },
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      // Add Button
                      InkWell(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (ctx) {
                              return StatefulBuilder(
                                builder: (context, setState) {
                                  return Container(
                                    height:
                                        MediaQuery.of(ctx).size.height * 0.45,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(20),
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        // Handle Bar
                                        Container(
                                          margin: EdgeInsets.only(top: 8),
                                          width: 40,
                                          height: 4,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[300],
                                            borderRadius: BorderRadius.circular(
                                              2,
                                            ),
                                          ),
                                        ),

                                        // Header
                                        Padding(
                                          padding: EdgeInsets.all(16),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'Add New Item',
                                                style: customTextStyle(
                                                  fontStyle:
                                                      FontStyle.HeaderM_Bold,
                                                ),
                                              ),
                                              IconButton(
                                                onPressed:
                                                    () => Navigator.pop(ctx),
                                                icon: Icon(Icons.close),
                                              ),
                                            ],
                                          ),
                                        ),

                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0,
                                          ),
                                          child: CustomTextFormField(
                                            hintText: 'Enter item name',
                                            context: context,
                                            controller: TextEditingController(),
                                            fieldName: 'Item Name',
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: CustomTextFormField(
                                            hintText: 'Enter item SKU',
                                            context: context,
                                            controller: TextEditingController(),
                                            fieldName: 'Item SKU',
                                          ),
                                        ),

                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0,
                                          ),
                                          child: BasketButton(
                                            text: "Add Item",
                                            textStyle: customTextStyle(
                                              fontStyle: FontStyle.BodyM_Bold,
                                            ),
                                            bgcolor: customColors().accent,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: customColors().accent,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Icon(
                            Icons.add,
                            color: customColors().backgroundPrimary,
                          ),
                        ),
                      ),
                    ],
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
                                        BlocProvider.of<
                                          HomeSectionInchargeCubit
                                        >(context).searchresult[index],
                                    existingUpdates:
                                        BlocProvider.of<
                                          HomeSectionInchargeCubit
                                        >(context).updateHistory,
                                    statusHistory:
                                        BlocProvider.of<
                                          HomeSectionInchargeCubit
                                        >(context).statusHistories,
                                    onSectionChanged: (p0, p1, p2) {
                                      context
                                          .read<HomeSectionInchargeCubit>()
                                          .addToStockStatusList(
                                            p0,
                                            p1,
                                            p2,
                                            BlocProvider.of<
                                              HomeSectionInchargeCubit
                                            >(
                                              context,
                                            ).searchresult[index].imageUrl,
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18.0,
                              ),
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
                                        BlocProvider.of<
                                          HomeSectionInchargeCubit
                                        >(context).sectionitems[index],
                                    existingUpdates:
                                        BlocProvider.of<
                                          HomeSectionInchargeCubit
                                        >(context).updateHistory,
                                    statusHistory:
                                        BlocProvider.of<
                                          HomeSectionInchargeCubit
                                        >(context).statusHistories,
                                    onSectionChanged: (p0, p1, p2) {
                                      context
                                          .read<HomeSectionInchargeCubit>()
                                          .addToStockStatusList(
                                            p0,
                                            p1,
                                            p2,
                                            BlocProvider.of<
                                              HomeSectionInchargeCubit
                                            >(
                                              context,
                                            ).sectionitems[index].imageUrl,
                                          );
                                    },
                                  );
                                },
                              ),
                            ),

                          SizedBox(height: 80.0),
                        ],
                      ),
                    ),
                  ),

                // Sync Data Button at bottom
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: customColors().islandAqua,
                        disabledBackgroundColor: customColors().islandAqua
                            .withOpacity(0.5),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.sync, color: customColors().fontPrimary),
                          const SizedBox(width: 8),
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
          ],
        ),
      ),
    );
  }
}
