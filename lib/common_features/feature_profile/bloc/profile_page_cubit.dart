import 'package:ansarlogistics/Picker/presentation_layer/bloc_navigation/navigation_cubit.dart';
import 'package:ansarlogistics/common_features/feature_profile/bloc/profile_page_state.dart';
import 'package:ansarlogistics/services/service_locator.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:ansarlogistics/user_controller/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toastification/toastification.dart';

class ProfilePageCubit extends Cubit<ProfilePageState> {
  final ServiceLocator serviceLocator;
  // final PDApiGateway? pdApiGateway;
  BuildContext context;
  ProfilePageCubit({
    required this.serviceLocator,
    // this.pdApiGateway
    required this.context,
  }) : super(ProfilePageInitialState(profiledata: UserController().profile)) {
    BlocProvider.of<NavigationCubit>(context).adcontroller.stream.listen((
      event,
    ) {
      if (event.currIndex == 3) {
        getProfileData();
      }
    });
  }

  bool currentstat = false;

  Map<String, dynamic> profilelist = {};

  getProfileData() async {
    if (!isClosed) {
      // UserController.userController.profileData = profileResponse;
      // emit(ProfileInitial(profileData: profileResponse));

      profilelist = {
        "0": {
          "title": "User name",
          "value": UserController.userController.profile.name,
        },
        // "1": {"title": "My Order Status", "img": 'assets/checklist.png'},
        "1": {"title": "Emp ID", "value": UserController().profile.empId},
        "2": {"title": "OutStock Marked Items ", "value": ""},
      };

      currentstat =
          UserController().profile.availabilityStatus == "1" ? true : false;

      emit(ProfilePageInitialState(profiledata: UserController().profile));
    }
  }

  Future<bool> updateuserstat(int stat) async {
    try {
      final response = await serviceLocator.tradingApi.updateuserstat(
        user_id: int.parse(UserController().profile.id),
        status: stat,
      );

      if (response.statusCode == 200) {
        if (stat == 0) {
          currentstat = false;
        } else {
          currentstat = true;
        }

        toastification.show(
          backgroundColor: customColors().secretGarden,
          title: Text(
            "User Status Updated",
            style: customTextStyle(
              fontStyle: FontStyle.BodyL_Bold,
              color: FontColor.White,
            ),
          ),
          autoCloseDuration: const Duration(seconds: 5),
        );

        return true;
      } else {
        toastification.show(
          backgroundColor: customColors().warning,
          title: Text(
            "status update failed please try again...",
            style: customTextStyle(
              fontStyle: FontStyle.BodyL_Bold,
              color: FontColor.White,
            ),
          ),
          autoCloseDuration: const Duration(seconds: 5),
        );

        return false;
      }
    } catch (e) {
      toastification.show(
        backgroundColor: customColors().warning,
        title: Text(
          "status update failed please try again...",
          style: customTextStyle(
            fontStyle: FontStyle.BodyL_Bold,
            color: FontColor.White,
          ),
        ),
        autoCloseDuration: const Duration(seconds: 5),
      );

      return false;
    }
  }
}
