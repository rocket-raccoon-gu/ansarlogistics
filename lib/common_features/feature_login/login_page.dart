import 'dart:io';

import 'package:ansarlogistics/common_features/feature_login/bloc/login_cubit.dart';
import 'package:ansarlogistics/components/custom_app_components/buttons/basket_button.dart';
import 'package:ansarlogistics/components/custom_app_components/scrollable_bottomsheet/order_warning_bottomsheet.dart';
import 'package:ansarlogistics/components/custom_app_components/scrollable_bottomsheet/scrollable_bottomsheet.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:ansarlogistics/user_controller/user_controller.dart';
import 'package:ansarlogistics/utils/network/network_service_status.dart';
import 'package:ansarlogistics/utils/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../../components/custom_app_components/textfields/custom_text_form_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late GlobalKey<FormState> idFormKey = GlobalKey<FormState>();
  late GlobalKey<FormState> passFormKey = GlobalKey<FormState>();

  Key idKey = UniqueKey();
  Key passKey = UniqueKey();
  TextEditingController idcontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();
  final focus1 = FocusNode();
  final focus2 = FocusNode();

  final Stream<NetworkStatus> _stream =
      NetworkStatusService.networkStatusController.stream;
  var scrollcontroller = ScrollController();
  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
    buildSignature: 'Unknown',
  );

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _stream.listen((NetworkStatus status) {
      if (status == NetworkStatus.Online) {
        ScaffoldMessenger.of(context).showSnackBar(
          showSuccessDialogue(message: "Inernet connection restored"),
        );
      } else if (status == NetworkStatus.Offline) {
        ScaffoldMessenger.of(context).showSnackBar(
          showErrorDialogue(errorMessage: "Inernet connection lost"),
        );
      }
    });

    checkInternetConnection(context);
    _initPackageInfo();
  }

  @override
  dispose() {
    super.dispose();
  }

  checkInternetConnection(BuildContext context) async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) return;
    } on SocketException catch (_) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(showErrorDialogue(errorMessage: "No internet connection"));
    }
  }

  Widget userNameAndTradeCode(String username, String password) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.only(top: 35.0, right: 16.0, left: 16.0),
      child: Column(
        children: [
          Text(
            username,
            textAlign: TextAlign.center,
            style: customTextStyle(
              fontStyle: FontStyle.HeaderS_SemiBold,
              color: FontColor.FontPrimary,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            password,
            style: customTextStyle(
              fontStyle: FontStyle.BodyM_Regular,
              color: FontColor.FontSecondary,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double mheight = MediaQuery.of(context).size.height * 1.22;

    return SafeArea(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(0.0),
          child: AppBar(
            elevation: 0,
            backgroundColor: customColors().backgroundPrimary,
          ),
        ),
        backgroundColor: customColors().backgroundPrimary,
        resizeToAvoidBottomInset: true,
        body: BlocConsumer<LoginCubit, LoginState>(
          builder: (context, state) {
            if (state is LoginInitial) {
              return GestureDetector(
                onTap: () {
                  FocusScope.of(context).requestFocus(FocusNode());
                },
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (state.loading)
                        LinearProgressIndicator(
                          minHeight: 6.0,
                          color: customColors().primary.withOpacity(0.8),
                          backgroundColor: customColors().primary.withOpacity(
                            0.2,
                          ),
                          // value: controller.value,
                        ),
                      if (!state.loading) const SizedBox(height: 6),
                      ConstrainedBox(
                        constraints: const BoxConstraints(),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 70),
                              child: SizedBox(
                                height: 150,
                                width: 250,
                                child: Image.asset(
                                  "assets/ansar-logistics.png",
                                ),
                              ),
                            ),
                            if (UserController().userName != "")
                              userNameAndTradeCode(
                                UserController().userName,
                                UserController().userName,
                              ),
                            Form(
                              key: idFormKey,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 5.0),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        top: 10.0,
                                        left: 16.0,
                                        right: 16.0,
                                      ),
                                      child: CustomTextFormField(
                                        context: context,
                                        controller: idcontroller,
                                        fieldName: "User Id",
                                        hintText: " Enter User ID/Emp ID",
                                        validator: Validator.account,
                                        autoFocus: true,
                                        focusNode: focus1,
                                        textCapitalization:
                                            TextCapitalization.sentences,
                                        onChange: (val) {
                                          if (val.isNotEmpty) {
                                            idFormKey.currentState!.validate();
                                          }
                                          if (state.errorMessage != "") {
                                            state.errorMessage = "";
                                            setState(() {});
                                          }
                                        },
                                        bordercolor:
                                            customColors().backgroundTertiary,
                                        inputFormatter: [
                                          LengthLimitingTextInputFormatter(15),
                                          // UpperCaseFormatter(),
                                          // FilteringTextInputFormatter.allow(
                                          //   RegExp("[0-9a-zA-Z]"),
                                          // ),
                                        ],
                                        onFieldSubmit: (value) async {
                                          // if (idFormKey
                                          //         .currentState!
                                          //         .validate() &&
                                          //     passwordcontroller
                                          //         .text.isNotEmpty &&
                                          //     (!state.needOtp ||
                                          //         (state.needOtp &&
                                          //             otpcontroller
                                          //                 .text.isNotEmpty))) {
                                          //   BlocProvider.of<LoginCubit>(context)
                                          //       .sendLoginRequest(
                                          //           context: context,
                                          //           userId: idcontroller
                                          //                   .text.isEmpty
                                          //               ? UserController().userId
                                          //               : idcontroller.text,
                                          //           password:
                                          //               passwordcontroller.text,
                                          //           otp: otpcontroller.text != ""
                                          //               ? otpcontroller.text
                                          //               : "");
                                          // } else if (idcontroller
                                          //     .text.isNotEmpty) {
                                          //   if (state.needOtp) {
                                          //     focus3.requestFocus();
                                          //   } else {
                                          //     focus2.requestFocus();
                                          //   }
                                          // } else {
                                          //   focus1.requestFocus();
                                          // }
                                        },
                                        keyboardAction: () async {
                                          // if (idFormKey
                                          //         .currentState!
                                          //         .validate() &&
                                          //     passwordcontroller
                                          //         .text.isNotEmpty &&
                                          //     (!state.needOtp ||
                                          //         (state.needOtp &&
                                          //             otpcontroller
                                          //                 .text.isNotEmpty))) {
                                          //   BlocProvider.of<LoginCubit>(context)
                                          //       .sendLoginRequest(
                                          //           context: context,
                                          //           userId: idcontroller
                                          //                   .text.isEmpty
                                          //               ? UserController().userId
                                          //               : idcontroller.text,
                                          //           password:
                                          //               passwordcontroller.text,
                                          //           otp: otpcontroller.text != ""
                                          //               ? otpcontroller.text
                                          //               : "");
                                          // } else if (idcontroller
                                          //     .text.isNotEmpty) {
                                          //   if (state.needOtp) {
                                          //     focus3.requestFocus();
                                          //   } else {
                                          //     focus2.requestFocus();
                                          //   }
                                          // } else {
                                          //   focus1.requestFocus();
                                          // }
                                        },
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        top: 10,
                                        left: 16.0,
                                        right: 16.0,
                                      ),
                                      child: CustomTextFormField(
                                        context: context,
                                        controller: passwordcontroller,
                                        fieldName: "Password",
                                        hintText: " Enter Password",
                                        validator: Validator.password,
                                        autoFocus: true,
                                        focusNode: focus2,
                                        obscureTextStatus: true,
                                        obscureIcon: true,
                                        inputFormatter: [
                                          LengthLimitingTextInputFormatter(30),
                                        ],
                                        onChange: (val) {
                                          if (val.isNotEmpty) {
                                            // passFormKey.currentState!.validate();
                                          }
                                          if (state.errorMessage != "") {
                                            state.errorMessage = "";
                                            setState(() {});
                                          }
                                        },
                                        onFieldSubmit: (value) async {
                                          if (idFormKey.currentState != null) {
                                            if (!idFormKey.currentState!
                                                .validate())
                                              return;
                                          }
                                          if ((UserController()
                                                      .userName
                                                      .isNotEmpty ||
                                                  idcontroller
                                                      .text
                                                      .isNotEmpty) &&
                                              !state.loading) {
                                            BlocProvider.of<LoginCubit>(
                                              context,
                                            ).sendLoginRequest(
                                              context: context,
                                              userId:
                                                  idcontroller.text.isEmpty
                                                      ? UserController()
                                                          .userName
                                                      : idcontroller.text,
                                              password: passwordcontroller.text,
                                            );
                                          } else if (idcontroller
                                              .text
                                              .isEmpty) {
                                            focus1.requestFocus();
                                          } else {
                                            focus2.requestFocus();
                                          }
                                        },
                                        keyboardAction: () async {
                                          if (idFormKey.currentState != null) {
                                            if (!idFormKey.currentState!
                                                .validate())
                                              return;
                                          }

                                          if ((UserController()
                                                      .userName
                                                      .isNotEmpty ||
                                                  idcontroller
                                                      .text
                                                      .isNotEmpty) &&
                                              passFormKey.currentState!
                                                  .validate() &&
                                              !state.loading) {
                                            BlocProvider.of<LoginCubit>(
                                              context,
                                            ).sendLoginRequest(
                                              context: context,
                                              userId:
                                                  idcontroller.text.isEmpty
                                                      ? UserController()
                                                          .userName
                                                      : idcontroller.text,
                                              password: passwordcontroller.text,
                                            );
                                          } else if (idcontroller
                                              .text
                                              .isEmpty) {
                                            focus1.requestFocus();
                                          }
                                          {
                                            focus2.requestFocus();
                                          }
                                        },
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                        top: mheight * .040,
                                        left: 16.0,
                                        right: 16.0,
                                      ),
                                      child: BasketButton(
                                        bgcolor:
                                            state.loading
                                                ? customColors().primary
                                                    .withOpacity(0.4)
                                                : customColors().primary,
                                        text: "Log In",
                                        enabled: !state.loading,
                                        textStyle: customTextStyle(
                                          fontStyle: FontStyle.BodyL_Bold,
                                          color: FontColor.White,
                                        ),
                                        onpress: () async {
                                          if (idFormKey.currentState != null) {
                                            if (!idFormKey.currentState!
                                                .validate())
                                              return;
                                          }
                                          if ((UserController()
                                                      .userName
                                                      .isNotEmpty ||
                                                  idcontroller
                                                      .text
                                                      .isNotEmpty) &&
                                              !state.loading) {
                                            FocusManager.instance.primaryFocus
                                                ?.unfocus();
                                            BlocProvider.of<LoginCubit>(
                                              context,
                                            ).sendLoginRequest(
                                              context: context,
                                              userId:
                                                  idcontroller.text.isEmpty
                                                      ? UserController()
                                                          .userName
                                                      : idcontroller.text,
                                              password: passwordcontroller.text,
                                            );
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            if (state is LoginLoading) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 150,
                      width: 250,
                      child: Image.asset("assets/ansar-logistics.png"),
                    ),
                    const SizedBox(height: 12.0),
                    const SizedBox(
                      width: 100,
                      child: ProgressIndicator(duration: Duration(seconds: 3)),
                    ),
                  ],
                ),
              );
            }
            return Container();
          },
          listener: (context, state) {
            if (state is LoginInitial) {
              idcontroller.text = UserController().userName;
              if (state.loading) return;
              if (UserController().userName != "") {
                focus2.requestFocus();
              } else {
                FocusScope.of(context).requestFocus(FocusNode());
              }
              if (state.errorMessage.length > 1) {
                customShowModalBottomSheet(
                  context: context,
                  inputWidget: OrderWarningBottomSheet(
                    heading: "Login Failed",
                    errorMsg: "Please Check Your Credentials or Contact Admin",
                  ),
                ).then((value) {
                  focus1.requestFocus();
                });
              }
            }
          },
        ),
      ),
    );
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
    // String data = await PlatformRepository.changeColor("RED");
    // showSnackBar(
    //     context: context,
    //     snackBar: showErrorDialogue(
    //         errorMessage: "compleated native methord and value is $data"));
  }
}

class ProgressIndicator extends StatefulWidget {
  final Duration duration;
  const ProgressIndicator({
    Key? key,
    this.duration = const Duration(seconds: 5),
  }) : super(key: key);

  @override
  State<ProgressIndicator> createState() => _ProgressIndicatorState();
}

class _ProgressIndicatorState extends State<ProgressIndicator>
    with TickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    controller = AnimationController(vsync: this, duration: widget.duration)
      ..addListener(() {
        setState(() {});
      });
    controller.repeat(period: widget.duration);
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
      value: controller.value,
      color: customColors().primary,
    );
  }
}
