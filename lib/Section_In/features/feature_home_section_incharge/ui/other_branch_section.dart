import 'package:ansarlogistics/Section_In/features/components/section_list_item.dart';
import 'package:ansarlogistics/Section_In/features/feature_home_section_incharge/bloc/home_section_incharge_cubit.dart';
import 'package:ansarlogistics/Section_In/features/feature_home_section_incharge/bloc/home_section_incharge_state.dart';
import 'package:ansarlogistics/components/custom_app_components/buttons/animation_switch.dart';
import 'package:ansarlogistics/components/custom_app_components/textfields/custom_search_field.dart';
import 'package:ansarlogistics/constants/texts.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:ansarlogistics/user_controller/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OtherBranchSection extends StatefulWidget {
  HomeSectionInchargeState state;

  OtherBranchSection({super.key, required this.state});

  @override
  State<OtherBranchSection> createState() => _OtherBranchSectionState();
}

class _OtherBranchSectionState extends State<OtherBranchSection> {
  GlobalKey<FormFieldState<String>> _ordersearchFormKey =
      GlobalKey<FormFieldState<String>>();

  bool searchactive = false;

  final _searchcontroller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // print("other branch section");
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
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
              },
              controller: _searchcontroller,
            ),
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
              context: context,
              removeTop: true,
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
                      padding: const EdgeInsets.symmetric(horizontal: 18.0),
                      child: ListView.builder(
                        itemCount:
                            BlocProvider.of<HomeSectionInchargeCubit>(
                              context,
                            ).searchresult.length,
                        shrinkWrap: true,
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
                                  .addToStockStatusList(p0, p1, p2, "");
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
                                  .addToStockStatusList(p0, p1, p2, "");
                            },
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
