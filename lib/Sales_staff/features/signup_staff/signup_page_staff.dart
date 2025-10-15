import 'dart:developer';

import 'package:ansarlogistics/Sales_staff/features/signup_staff/cubit/signup_page_staff_cubit.dart';
import 'package:ansarlogistics/Sales_staff/features/signup_staff/cubit/signup_page_staff_state.dart';
import 'package:ansarlogistics/app_page_injectable.dart';
import 'package:ansarlogistics/components/custom_app_components/buttons/basket_button.dart';
import 'package:ansarlogistics/components/custom_app_components/textfields/custom_text_form_field.dart';
import 'package:ansarlogistics/constants/methods.dart';
import 'package:ansarlogistics/constants/texts.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:ansarlogistics/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SignupPageStaff extends StatefulWidget {
  const SignupPageStaff({super.key});

  @override
  State<SignupPageStaff> createState() => _SignupPageStaffState();
}

class _SignupPageStaffState extends State<SignupPageStaff> {
  late GlobalKey<FormState> idFormKey = GlobalKey<FormState>();

  TextEditingController nameController = TextEditingController();

  TextEditingController employeeidController = TextEditingController();

  TextEditingController passwordController = TextEditingController();

  String? _selectedBranchCode;

  TextEditingController sectionNameController = TextEditingController();

  TextEditingController deviceidController = TextEditingController();

  String? selectedSection;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HexColor('#F9FBFF'),
      resizeToAvoidBottomInset: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0.0),
        child: AppBar(
          elevation: 0,
          backgroundColor: Color.fromRGBO(183, 214, 53, 1),
        ),
      ),
      body: BlocConsumer<SignupPageStaffCubit, SignupPageStaffState>(
        listener: (context, state) {
          if (state is SignupPageStaffSuccess) {
            // Prefill device ID once fetched if user hasn't typed anything yet
            // final id = context.read<SignupPageStaffCubit>().currentid;
            // if (deviceidController.text.isEmpty && id.isNotEmpty) {
            //   deviceidController.text = id;
            // }

            // showSnackBar(
            //   context: context,
            //   snackBar: showSuccessDialogue(message: "Device ID Prefilled"),
            // );
          }

          if (state is SignupPageStaffFailure) {
            showSnackBar(
              context: context,
              snackBar: showErrorDialogue(
                errorMessage: "Error: ${state.message}",
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is SignupPageStaffLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.symmetric(
                  vertical: 15.0,
                  horizontal: 10.0,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      width: 2.0,
                      color: customColors().backgroundTertiary,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () {
                        context.gNavigationService.back(context);

                        //
                      },
                      child: Icon(
                        Icons.arrow_back,
                        size: 23,
                        color: HexColor("#A3A3A3"),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          "Sales Staff Registration",
                          style: customTextStyle(
                            fontStyle: FontStyle.BodyL_Bold,
                            color: FontColor.FontPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22.0,
                  vertical: 6.0,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Please fill up the form below to complete signup.",
                        style: customTextStyle(
                          fontStyle: FontStyle.BodyL_Regular,
                          color: FontColor.FontPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22.0),
                  child: SingleChildScrollView(
                    child: Form(
                      key: idFormKey,
                      child: Column(
                        children: [
                          //
                          //
                          // enter your name
                          CustomTextFormField(
                            context: context,
                            controller: nameController,
                            fieldName: "Name",
                            hintText: "Enter your name here",
                            validator: Validator.defaultValidator,
                          ),

                          //
                          //
                          // enter your contact number
                          CustomTextFormField(
                            context: context,
                            controller: employeeidController,
                            fieldName: "Staff ID",
                            hintText: "Enter your staff ID here",
                            validator: Validator.defaultValidator,
                          ),

                          //
                          //
                          // enter device id
                          CustomTextFormField(
                            context: context,
                            controller: deviceidController,
                            fieldName: "Device ID",
                            hintText: "Enter your device ID here",
                            validator: Validator.defaultValidator,
                            // readonlyState:
                            //     context
                            //         .read<SignupPageStaffCubit>()
                            //         .currentid
                            //         .isNotEmpty,
                            // enabled:
                            //     context
                            //         .read<SignupPageStaffCubit>()
                            //         .currentid
                            //         .isEmpty,
                          ),

                          //
                          //
                          // enter your password
                          CustomTextFormField(
                            context: context,
                            controller: passwordController,
                            obscureIcon: true,
                            obscureTextStatus: true,
                            fieldName: "Password",
                            hintText: "Enter your password here",
                            validator: Validator.defaultValidator,
                          ),

                          //
                          //
                          // select branch
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 2,
                                  color: customColors().backgroundTertiary,
                                ),
                              ),
                              child: DropdownButtonFormField<String>(
                                value: _selectedBranchCode,
                                borderRadius: BorderRadius.circular(5),
                                hint: Text(
                                  "  Select branch",
                                  style: customTextStyle(
                                    fontStyle: FontStyle.BodyL_Regular,
                                    color: FontColor.FontPrimary,
                                  ),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedBranchCode = value;
                                  });
                                },
                                items:
                                    branches.entries.map((entry) {
                                      return DropdownMenuItem(
                                        value: entry.key,
                                        child: Text(entry.value),
                                      );
                                    }).toList(),
                                validator: (value) {
                                  if (value == null) {
                                    return 'Please select a branch';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                          //
                          //
                          //Dropdown Sections Data
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: DropdownButtonFormField<String>(
                              value: selectedSection,
                              hint: Text(
                                "  Select section",
                                style: customTextStyle(
                                  fontStyle: FontStyle.BodyL_Regular,
                                  color: FontColor.FontPrimary,
                                ),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  selectedSection = value;
                                });
                              },
                              items:
                                  context
                                      .read<SignupPageStaffCubit>()
                                      .sections
                                      .map(
                                        (s) => DropdownMenuItem(
                                          value: s,
                                          child: Text(s),
                                        ),
                                      )
                                      .toList(),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please select a section';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: SizedBox(
        child: Wrap(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 15.0,
                horizontal: 15,
              ),
              child: BasketButton(
                textStyle: customTextStyle(
                  fontStyle: FontStyle.BodyL_Regular,
                  color: FontColor.FontPrimary,
                ),
                bgcolor: customColors().crisps,
                onpress: () async {
                  if (idFormKey.currentState!.validate()) {
                    final info = await PackageInfo.fromPlatform();

                    Map<String, dynamic> data = {
                      "employee_id": employeeidController.text.toString(),
                      "name": nameController.text.toString(),
                      "password": passwordController.text.toString(),
                      "role": 7,
                      "branch_code": _selectedBranchCode,
                      "section_id": selectedSection,
                      "device_id": deviceidController.text.toString(),
                      "version": info.version,
                      "build": info.buildNumber,
                    };

                    log(data.toString());

                    context.read<SignupPageStaffCubit>().signup(data, context);
                  }
                },
                text: "Sign Up",
              ),
            ),
          ],
        ),
      ),
    );
  }
}
