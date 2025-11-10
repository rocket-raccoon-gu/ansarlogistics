import 'dart:async';
import 'dart:developer';

import 'package:ansarlogistics/Picker/presentation_layer/bloc_navigation/navigation_cubit.dart';
import 'package:ansarlogistics/Picker/presentation_layer/features/feature_incomplete_orders/bloc/incomplete_orders_cubit.dart';
import 'package:ansarlogistics/Picker/presentation_layer/features/feature_incomplete_orders/ui/incomplete_orders_page.dart';
import 'package:ansarlogistics/Picker/presentation_layer/features/feature_orders/bloc/picker_orders_cubit.dart';
import 'package:ansarlogistics/Picker/presentation_layer/features/feature_orders/bloc/picker_orders_state.dart';
import 'package:ansarlogistics/Picker/presentation_layer/features/feature_orders/ui/empty_box.dart';
import 'package:ansarlogistics/Picker/presentation_layer/features/feature_orders/ui/picker_order_list_item.dart';
import 'package:ansarlogistics/app_page_injectable.dart';
import 'package:ansarlogistics/components/custom_app_components/app_bar/custom_app_bar.dart';
import 'package:ansarlogistics/components/custom_app_components/scrollable_bottomsheet/scrollable_bottomsheet.dart';
import 'package:ansarlogistics/components/custom_app_components/textfields/custom_search_field.dart';
import 'package:ansarlogistics/components/custom_app_components/textfields/filter_by_type.dart';
import 'package:ansarlogistics/components/loading_indecator.dart';
import 'package:ansarlogistics/constants/methods.dart';
import 'package:ansarlogistics/constants/texts.dart';
import 'package:ansarlogistics/user_controller/user_controller.dart';
import 'package:ansarlogistics/utils/notifier.dart';
import 'package:ansarlogistics/utils/preference_utils.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:picker_driver_api/responses/orders_new_response.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PickerOrdersPage extends StatefulWidget {
  const PickerOrdersPage({super.key});

  @override
  State<PickerOrdersPage> createState() => _PickerOrdersPageState();
}

class _PickerOrdersPageState extends State<PickerOrdersPage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  final GlobalKey<FormFieldState<String>> _ordersearchFormKey =
      GlobalKey<FormFieldState<String>>();

  final _searchcontroller = TextEditingController();

  final ScrollController scrollController = ScrollController();

  StreamController<void> fcmRefreshStream = StreamController<void>.broadcast();

  StreamSubscription<void>? fcmRefreshSubScription;

  List<OrderNew>? orderitems = [];

  bool isloading = false;

  String data = "Initial Data";

  int _segmentIndex = 0; // 0 = All Orders, 1 = View Sections
  int _selectedCategoryIdx = 0;

  // Extract the first valid image URL from a potentially comma/space separated string
  String getFirstImage(String productImages) {
    if (productImages.isEmpty) return '';

    // Split by comma
    List<String> images = productImages.split(',');

    // Trim in case of spaces
    return images.first.trim();
  }

  // Resolve final image URL by handling absolute vs relative paths
  // Safely determine item count for a category
  int _safeItemCount(CategoryGroup cat) {
    final c = cat.itemCount;
    if (c != null && c >= 0) return c;
    return cat.items.length;
  }

  Widget _segmentedControl() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.all(4.0),
        decoration: BoxDecoration(
          color: customColors().backgroundTertiary,
          borderRadius: BorderRadius.circular(28.0),
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  if (_segmentIndex != 0) {
                    setState(() => _segmentIndex = 0);
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeInOut,
                  height: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color:
                        _segmentIndex == 0
                            ? customColors().fontPrimary
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(24.0),
                  ),
                  child: Text(
                    "All Orders",
                    style: customTextStyle(
                      fontStyle: FontStyle.BodyM_Bold,
                      color:
                          _segmentIndex == 0
                              ? FontColor.White
                              : FontColor.FontPrimary,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  if (_segmentIndex != 1) {
                    setState(() => _segmentIndex = 1);
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeInOut,
                  height: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color:
                        _segmentIndex == 1
                            ? customColors().fontPrimary
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(24.0),
                  ),
                  child: Text(
                    "View Sections",
                    style: customTextStyle(
                      fontStyle: FontStyle.BodyM_Bold,
                      color:
                          _segmentIndex == 1
                              ? FontColor.White
                              : FontColor.FontPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // New UI for non-paginated categories/products (class-scope)
  Widget _sectionChipsNew(List<CategoryGroup> categories) {
    if (categories.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 80,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isActive = _selectedCategoryIdx == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategoryIdx = index),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 10.0,
              ),
              decoration: BoxDecoration(
                color:
                    isActive
                        ? HexColor('#D66435')
                        : customColors().backgroundSecondary,
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: customColors().backgroundTertiary),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    cat.category ?? 'Category',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: customTextStyle(
                      fontStyle: FontStyle.BodyM_Bold,
                      color: isActive ? FontColor.White : FontColor.FontPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 4.0,
                    ),
                    decoration: BoxDecoration(
                      color: isActive ? Colors.white : HexColor('#D66435'),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text(
                          '${_safeItemCount(cat)} items',
                          style: customTextStyle(
                            fontStyle: FontStyle.BodyS_Bold,
                            color:
                                isActive
                                    ? FontColor.FontPrimary
                                    : FontColor.White,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemCount: categories.length,
      ),
    );
  }

  Widget _sectionProductListNew(List<GroupedProduct> items) {
    return Flexible(
      fit: FlexFit.loose,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
        child: ListView.separated(
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final it = items[index];
            final qty = it.totalQuantity ?? 0;
            final rawImg = it.productImages ?? it.imageUrl;
            final imgPath =
                (rawImg == null || rawImg.isEmpty) ? '' : getFirstImage(rawImg);
            final resolved = resolveImageUrl(imgPath);
            return InkWell(
              onTap: () {
                context.gNavigationService.openItemBatchPickupPage(
                  context,
                  arg: {'items_data': it},
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: customColors().backgroundSecondary,
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(color: customColors().backgroundTertiary),
                ),
                padding: const EdgeInsets.all(10.0),
                child: Stack(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child:
                              resolved.isNotEmpty
                                  ? CachedNetworkImage(
                                    imageUrl: resolved,
                                    width: 64,
                                    height: 64,
                                    fit: BoxFit.cover,
                                    errorWidget:
                                        (_, __, ___) => Image.asset(
                                          'assets/ansar-logistics.png',
                                          width: 64,
                                          height: 64,
                                          fit: BoxFit.cover,
                                        ),
                                  )
                                  : Image.asset(
                                    'assets/ansar-logistics.png',
                                    width: 64,
                                    height: 64,
                                    fit: BoxFit.cover,
                                  ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                it.name ?? '-',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: customTextStyle(
                                  fontStyle: FontStyle.BodyM_Bold,
                                  color: FontColor.FontPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'SKU: ${it.sku ?? '-'}',
                                style: customTextStyle(
                                  fontStyle: FontStyle.BodyS_Regular,
                                  color: FontColor.FontSecondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0,
                                      vertical: 4.0,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      borderRadius: BorderRadius.circular(8.0),
                                      border: Border.all(
                                        color: HexColor('#2D7EFF'),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Text(
                                      it.price != null
                                          ? 'QAR ${(it.price as num).toStringAsFixed(2)}'
                                          : '—',
                                      style: customTextStyle(
                                        fontStyle: FontStyle.BodyS_Bold,
                                        color: FontColor.Info,
                                      ).copyWith(color: HexColor('#2D7EFF')),
                                    ),
                                  ),
                                  const Spacer(),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder:
                                              (_) => BlocProvider(
                                                create:
                                                    (_) =>
                                                        IncompleteOrdersCubit(),
                                                child: IncompleteOrdersPage(
                                                  args: {
                                                    'product': it,
                                                    'ordersNew':
                                                        context
                                                            .read<
                                                              PickerOrdersCubit
                                                            >()
                                                            .ordersNew,
                                                  },
                                                ),
                                              ),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.black,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12.0,
                                        vertical: 8.0,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          10.0,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      'View Orders',
                                      style: customTextStyle(
                                        fontStyle: FontStyle.BodyS_Bold,
                                        color: FontColor.White,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      top: 2,
                      right: 2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: HexColor('#D66435'),
                          borderRadius: BorderRadius.circular(6.0),
                        ),
                        child: Text(
                          '$qty',
                          style: customTextStyle(
                            fontStyle: FontStyle.BodyM_Bold,
                            color: FontColor.White,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  int _countForStatus(List<OrderNew> orders, String status) {
    final list = orders;
    // if (UserController().selectedindex == 0) return list.length;
    if (status == 'all' || status == 'All') {
      return list.length;
    }
    return list.where((o) => (o.status == status)).length;
  }

  Color _badgeColorForStatus(String status) {
    switch (status) {
      case 'assigned_picker':
      case 'Assigned':
        return customColors().secretGarden; // green
      case 'start_picking':
      case 'Start Picking':
        return customColors().info; // blue
      case 'end_picking':
        return customColors().mattPurple; // purple
      case 'holded':
        return customColors().warning; // yellow
      case 'material_request':
        return customColors().danger; // red
      case 'all':
      default:
        return customColors().fontPrimary; // dark for All
    }
  }

  Widget _statusChips(List<OrderNew> orders) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        scrollDirection: Axis.horizontal,
        itemCount: statuslist.length,
        itemBuilder: (context, index) {
          final item = statuslist[index];
          final name = item['name'] as String;
          final status = item['status'] as String;
          // final count = _countForStatus(orders, status);
          final isActive = UserController().selectedindex == index;
          return GestureDetector(
            onTap: () {
              UserController().selectedindex = index;
              setState(() {});
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14.0,
                vertical: 8.0,
              ),
              decoration: BoxDecoration(
                color:
                    isActive
                        ? customColors().adBackground
                        : customColors().backgroundSecondary,
                borderRadius: BorderRadius.circular(24.0),
                border: Border.all(
                  color:
                      isActive
                          ? customColors().warning
                          : customColors().backgroundTertiary,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    name,
                    style: customTextStyle(
                      fontStyle: FontStyle.BodyM_SemiBold,
                      color: FontColor.FontPrimary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: _badgeColorForStatus(status),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: customColors().backgroundTertiary,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "${_countForStatus(orders, status)}",
                      style: customTextStyle(
                        fontStyle: FontStyle.BodyM_Bold,
                        color: FontColor.White,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 10),
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    // if (networkSubscription != null) {
    //   networkSubscription!.cancel();
    // }
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        // BlocProvider.of<PickerOrdersCubit>(context)
        //     .loadPosts(1, statuslist[UserController().selectedindex]['status']);
      }
    });

    fcmRefreshSubScription = fcmRefreshStream.stream.listen((event) {});

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // if (message. .toString().contains("assigned")) {
      onMessageRecieved(message.notification!.title.toString());
      // }
    });

    getusercheck();
    // DateTime current = DateTime.now();

    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Initial load happens in Cubit constructor; no need to trigger here.

    eventBus.on<DataChangedEvent>().listen((event) {
      setState(() {
        data = event.newData;
      });
      // No reload here; UI will reflect Cubit state.
    });
  }

  void onMessageRecieved(String title) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('orderlist');

    UserController.userController.notified = true;

    // No immediate reload; rely on background updates or pull-to-refresh.
  }

  getusercheck() async {
    FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

    NotificationSettings settings = await firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // print("user permission granted");
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      // print("user granted provisional permission");
    } else {
      // print("user permission not granted");
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      // print('App Resumed From Background----------------------------------');
      log('App Resumed From Background----------------------------------');

      // if (Platform.isAndroid && UserController.userController.firsttime) {
      //   UserController.userController.firsttime = false;
      // } else if (Platform.isAndroid &&
      //     !UserController.userController.firsttime) {
      await Future.delayed(Duration(seconds: 2));

      Timer.periodic(Duration(seconds: 30), (tim) async {
        await Permission.location.isGranted.then((value) async {
          if (value) {
            try {
              Position position = await Geolocator.getCurrentPosition();

              // log("location ${position.latitude},${position.longitude} ...${DateTime.now()}");

              await PreferenceUtils.storeDataToShared(
                "userlat",
                position.latitude.toString(),
              );

              await PreferenceUtils.storeDataToShared(
                "userlong",
                position.longitude.toString(),
              );

              UserController.userController.locationlatitude =
                  position.latitude.toString();

              UserController.userController.locationlongitude =
                  position.longitude.toString();
            } catch (e) {}
          }
        });
      });

      await Permission.location.isGranted.then((value) async {
        if (value) {
          try {
            Position position = await Geolocator.getCurrentPosition();

            // log("location ${position.latitude},${position.longitude} ...${DateTime.now()}");

            await PreferenceUtils.storeDataToShared(
              "userlat",
              position.latitude.toString(),
            );

            await PreferenceUtils.storeDataToShared(
              "userlong",
              position.longitude.toString(),
            );

            UserController.userController.locationlatitude =
                position.latitude.toString();

            UserController.userController.locationlongitude =
                position.longitude.toString();

            // BlocProvider.of<PickerOrdersCubit>(context).updatelocation(
            //     position.latitude.toString(), position.longitude.toString());
          } catch (e) {
            log("error updating in location");
          }
        }
      });

      // Simulating a delay for the splash screen
      //   RestartWidget.restartApp(context);
      // }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomAppBar(onpressfind: () async {}, ispicker: true),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: CustomSearchField(
            onSearch: (val) {
              // BlocProvider.of<PickerOrdersCubit>(context).updatesearchorder(
              //   UserController().orderitems,
              //   val.toString().toUpperCase(),
              // );
            },
            controller: _searchcontroller,
            searchFormKey: _ordersearchFormKey,
            keyboardType: TextInputType.text,
            onFilter: () {
              customShowModalBottomSheet(
                context: context,
                inputWidget: FilterByType(
                  onTapSubmit: (int indexed) {
                    // Filtering changes only the view; no reload.
                    context.gNavigationService.back(context);
                  },
                  selectedindex: UserController().selectedindex,
                  statuslist: statuslist,
                ),
              );
            },
          ),
        ),
        // Segmented control: All Orders / View Sections
        _segmentedControl(),
        // Tabs body
        // if (_segmentIndex == 0)
        //   _statusChips(context.read<PickerOrdersCubit>().ordersNew),
        BlocBuilder<PickerOrdersCubit, PickerOrdersState>(
          builder: (context, state) {
            // If new data loaded but user is on 'All Orders' and list is empty, kick legacy load
            if (state is PickerOrdersNewLoadedState) {
              // WidgetsBinding.instance.addPostFrameCallback((_) {
              //   if (mounted) {
              //     BlocProvider.of<PickerOrdersCubit>(context).loadPosts(0, "");
              //   }
              // });
              orderitems = state.orders;

              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() {});
                }
              });
            }
            // if (state is PickerOrdersLoadingState) {
            //   orderitems = state.oldpost;
            //   isloading = true;
            // } else if (state is PickerOrdersLoadedState) {
            //   orderitems = state.posts;
            //   // UserController.userController.orderitems = orderitems!;
            //   isloading = false;
            // }

            if (state is PickerOrdersNewLoadingState) {
              return const Flexible(
                fit: FlexFit.loose,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [LoadingIndecator()],
                ),
              );
            }

            if (_segmentIndex == 1) {
              if (state is PickerOrdersNewLoadedState) {
                final cats = state.categories;
                final safeIndex =
                    cats.isEmpty
                        ? 0
                        : _selectedCategoryIdx.clamp(0, cats.length - 1);
                final items =
                    cats.isEmpty ? <GroupedProduct>[] : cats[safeIndex].items;
                return Flexible(
                  fit: FlexFit.loose,
                  child: Column(
                    children: [
                      _sectionChipsNew(cats),
                      if (cats.isEmpty)
                        const Flexible(
                          fit: FlexFit.loose,
                          child: Center(child: Text('No sections available')),
                        )
                      else
                        _sectionProductListNew(items),
                    ],
                  ),
                );
              } else if (state is PickerOrdersNewErrorState) {
                return Flexible(
                  fit: FlexFit.loose,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(state.message),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed:
                              () =>
                                  BlocProvider.of<PickerOrdersCubit>(
                                    context,
                                  ).loadOrdersNew(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                // Show spinner while Cubit initial load runs.
                return const Flexible(
                  fit: FlexFit.loose,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [LoadingIndecator()],
                  ),
                );
              }
            }
            if (state is PickerOrdersLoadingState && state.isFirstFetch) {
              return const Flexible(
                fit: FlexFit.loose,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [LoadingIndecator()],
                ),
              );
            } else if (state is PickerOrdersLoadingState && orderitems!.isEmpty)
              // ignore: curly_braces_in_flow_control_structures
              return const Flexible(
                fit: FlexFit.loose,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [LoadingIndecator()],
                ),
              );
            else {
              return Flexible(
                fit: FlexFit.loose,
                child: Column(
                  children: [
                    _statusChips(orderitems!),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () async {
                          BlocProvider.of<PickerOrdersCubit>(
                            context,
                          ).loadOrdersNew();
                        },
                        child:
                            orderitems!.isEmpty
                                ? ListView(
                                  physics: AlwaysScrollableScrollPhysics(),
                                  children: [EmptyBox()],
                                )
                                : ListView.builder(
                                  controller: scrollController,
                                  itemCount:
                                      orderitems!.length + (isloading ? 1 : 0),
                                  physics: AlwaysScrollableScrollPhysics(),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12.0,
                                    vertical: 12.0,
                                  ),
                                  itemBuilder: (context, index) {
                                    if (index < orderitems!.length) {
                                      return PickerOrderListItem(
                                        orderResponseItem: orderitems![index],
                                        index: index,
                                      );
                                    } else {
                                      Timer(Duration(milliseconds: 30), () {
                                        scrollController.jumpTo(
                                          scrollController
                                              .position
                                              .maxScrollExtent,
                                        );
                                      });
                                      return LoadingIndecator();
                                    }
                                  },
                                ),
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ],
    );
  }
}

class _SectionCategory {
  final String categoryName;
  final List<OrderItemNew> items;

  _SectionCategory({required this.categoryName, required this.items});
}
