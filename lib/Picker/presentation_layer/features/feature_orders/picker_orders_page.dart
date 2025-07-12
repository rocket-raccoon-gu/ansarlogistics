import 'dart:async';
import 'dart:developer';
import 'dart:io';

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
import 'package:ansarlogistics/constants/texts.dart';
import 'package:ansarlogistics/user_controller/user_controller.dart';
import 'package:ansarlogistics/utils/notifier.dart';
import 'package:ansarlogistics/utils/preference_utils.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:picker_driver_api/responses/order_response.dart';
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

  List<Order>? orderitems = [];

  bool isloading = false;

  String data = "Initial Data";

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

    eventBus.on<DataChangedEvent>().listen((event) {
      setState(() {
        data = event.newData;
      });
      BlocProvider.of<PickerOrdersCubit>(context).loadPosts(0, "");
    });
  }

  void onMessageRecieved(String title) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('orderlist');

    UserController.userController.notified = true;

    if (mounted) {
      BlocProvider.of<PickerOrdersCubit>(context).loadPosts(0, "");
    }
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
      children: [
        CustomAppBar(onpressfind: () async {}, ispicker: true),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: CustomSearchField(
            onSearch: (val) {
              BlocProvider.of<PickerOrdersCubit>(context).updatesearchorder(
                UserController().orderitems,
                val.toString().toUpperCase(),
              );
            },
            controller: _searchcontroller,
            searchFormKey: _ordersearchFormKey,
            keyboardType: TextInputType.text,
            onFilter: () {
              customShowModalBottomSheet(
                context: context,
                inputWidget: FilterByType(
                  onTapSubmit: (int indexed) {
                    BlocProvider.of<PickerOrdersCubit>(
                      context,
                    ).loadPosts(0, statuslist[indexed]['status']);

                    context.gNavigationService.back(context);
                  },
                  selectedindex: UserController().selectedindex,
                  statuslist: statuslist,
                ),
              );
            },
          ),
        ),
        BlocBuilder<PickerOrdersCubit, PickerOrdersState>(
          builder: (context, state) {
            if (state is PickerOrdersLoadingState) {
              orderitems = state.oldpost;
              isloading = true;
            } else if (state is PickerOrdersLoadedState) {
              orderitems = state.posts;
              // UserController.userController.orderitems = orderitems!;
              isloading = false;
            }
            if (state is PickerOrdersLoadingState && state.isFirstFetch) {
              return const Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [LoadingIndecator()],
                ),
              );
            } else if (state is PickerOrdersLoadingState && orderitems!.isEmpty)
              // ignore: curly_braces_in_flow_control_structures
              return const Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [LoadingIndecator()],
                ),
              );
            else {
              return Expanded(
                child: RefreshIndicator(
                  child: Container(
                    child: Stack(
                      children: [
                        Column(
                          children: [
                            if (orderitems!.isEmpty)
                              EmptyBox()
                            else
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12.0,
                                  ),
                                  child: ListView.builder(
                                    controller: scrollController,
                                    itemCount:
                                        orderitems!.length +
                                        (isloading ? 1 : 0),
                                    shrinkWrap: true,
                                    physics: AlwaysScrollableScrollPhysics(),
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
                      ],
                    ),
                  ),
                  onRefresh: () async {
                    BlocProvider.of<PickerOrdersCubit>(
                      context,
                    ).loadPosts(0, "");
                  },
                ),
              );
            }
          },
        ),
      ],
    );
  }
}
