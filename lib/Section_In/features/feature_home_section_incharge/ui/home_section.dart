import 'dart:async';
import 'package:ansarlogistics/Section_In/features/components/section_list_item.dart';
import 'package:ansarlogistics/Section_In/features/feature_home_section_incharge/bloc/home_section_incharge_cubit.dart';
import 'package:ansarlogistics/Section_In/features/feature_home_section_incharge/bloc/home_section_incharge_state.dart';
import 'package:ansarlogistics/components/custom_app_components/buttons/animation_switch.dart';
import 'package:ansarlogistics/components/custom_app_components/textfields/custom_search_field.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:ansarlogistics/user_controller/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:picker_driver_api/responses/section_item_response.dart';

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

  final _searchcontroller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;

  // Pagination variables
  static const int _itemsPerPage = 20;
  int _currentPage = 0;
  bool _isLoadingMore = false;
  List<Sectionitem> _displayedItems = [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialItems();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchcontroller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreItems();
    }
  }

  void _loadInitialItems() {
    final cubit = BlocProvider.of<HomeSectionInchargeCubit>(context);
    final allItems =
        cubit.searchactive ? cubit.searchresult : cubit.sectionitems;

    setState(() {
      _currentPage = 0;
      final take =
          allItems.length < _itemsPerPage ? allItems.length : _itemsPerPage;
      _displayedItems = allItems.take(take).toList();
    });
  }

  void _loadMoreItems() {
    if (_isLoadingMore) return;

    final cubit = BlocProvider.of<HomeSectionInchargeCubit>(context);
    final allItems =
        cubit.searchactive ? cubit.searchresult : cubit.sectionitems;

    final startIndex = (_currentPage + 1) * _itemsPerPage;
    if (startIndex >= allItems.length) return;

    setState(() {
      _isLoadingMore = true;
    });

    // Simulate network delay for smooth UX
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          final endIndex = (startIndex + _itemsPerPage).clamp(
            0,
            allItems.length,
          );
          _displayedItems.addAll(allItems.sublist(startIndex, endIndex));
          _currentPage++;
          _isLoadingMore = false;
        });
      }
    });
  }

  Widget _buildOptimizedList() {
    final cubit = BlocProvider.of<HomeSectionInchargeCubit>(context);

    if (cubit.searchactive && cubit.searchresult.isEmpty) {
      return _buildNoResultsWidget();
    }

    // If we have not yet populated displayed items but data exists in cubit,
    // schedule an initialization and show a small loader meanwhile.
    if (_displayedItems.isEmpty) {
      final hasData =
          (cubit.searchactive ? cubit.searchresult : cubit.sectionitems)
              .isNotEmpty;
      if (hasData) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _loadInitialItems();
        });
      }
      return _buildLoadingIndicator();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: MediaQuery.removePadding(
        removeTop: true,
        removeBottom: true,
        context: context,
        child: ListView.builder(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: _displayedItems.length + (_isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= _displayedItems.length) {
              return _buildLoadingIndicator();
            }

            return _buildOptimizedListItem(_displayedItems[index], cubit);
          },
        ),
      ),
    );
  }

  Widget _buildNoResultsWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset('assets/placeholder.png', height: 180.0, width: 180.0),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            "Item not found",
            style: customTextStyle(fontStyle: FontStyle.HeaderXS_SemiBold),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      alignment: Alignment.center,
      child: const CircularProgressIndicator(),
    );
  }

  Widget _buildOptimizedListItem(
    Sectionitem item,
    HomeSectionInchargeCubit cubit,
  ) {
    return SectionProductListItem(
      key: ValueKey(item.sku),
      sectionitem: item,
      existingUpdates: cubit.updateHistory,
      statusHistory: cubit.statusHistories,
      onSectionChanged: (p0, p1, p2) {
        cubit.addToStockStatusList(p0, p1, p2);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
                // Debounce search and reset pagination on every change
                _debounce?.cancel();
                _debounce = Timer(const Duration(milliseconds: 250), () {
                  final cubit = BlocProvider.of<HomeSectionInchargeCubit>(
                    context,
                  );
                  cubit.updatesearchorder(
                    UserController().sectionitems,
                    p0.toString(),
                  );
                  // Clear displayed items so the list rebuilds from first page
                  setState(() {
                    _displayedItems.clear();
                    _currentPage = 0;
                    _isLoadingMore = false;
                  });
                });
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

        Expanded(
          child:
              BlocBuilder<HomeSectionInchargeCubit, HomeSectionInchargeState>(
                builder: (context, state) {
                  if (state is HomeSectionInchargeLoading) {
                    return Center(child: loadingindecator());
                  }
                  if (state is HomeSectionInchargeInitial) {
                    // While remote search is in progress, show a loader
                    if (state.isSearching) {
                      return _buildLoadingIndicator();
                    }
                    // Initialize the first page when data available
                    if (_displayedItems.isEmpty) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) _loadInitialItems();
                      });
                    }
                    return _buildOptimizedList();
                  }
                  // Fallback
                  return _buildLoadingIndicator();
                },
              ),
        ),
      ],
    );
  }
}
