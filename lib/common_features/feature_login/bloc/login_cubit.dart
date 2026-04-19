import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:ansarlogistics/navigations/navigation.dart';
import 'package:ansarlogistics/services/crash_analytics.dart';
import 'package:ansarlogistics/services/service_locator.dart';
import 'package:ansarlogistics/user_controller/user_controller.dart';
import 'package:ansarlogistics/utils/preference_utils.dart';
import 'package:ansarlogistics/utils/user_settings.dart';
import 'package:ansarlogistics/utils/utils.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:picker_driver_api/responses/login_response.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;
part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final ServiceLocator serviceLocator;
  final BuildContext context;
  String misc3 = "";

  LoginCubit(this.context, {required this.serviceLocator})
    : super(LoginLoading()) {
    getUserCode();
  }

  getUserCode() async {
    if (await PreferenceUtils.preferenceHasKey("userCode")) {
      String id =
          UserController().userName =
              (await PreferenceUtils.getDataFromShared("userCode")) ?? "";
      String val = await PreferenceUtils.getDataFromShared("password") ?? "";
      String selectedRegion =
          await PreferenceUtils.getDataFromShared("selected_region") ?? "";

      if (id != "" && val != "") {
        // Validate the encrypted password

        String? profileJson = await PreferenceUtils.getDataFromShared(
          "user_profile",
        );

        if (profileJson != null) {
          UserController().profile = Profile.fromJson(jsonDecode(profileJson));

          swithcnavigate(context, UserController().profile.role);
        }

        // try {
        //   // String pass = decryptStringForUser(val, keyVal(id));
        //   if (val != "") {
        //     if (selectedRegion.toLowerCase() == "uae") {
        //       if (await sendLoginRequest(
        //         context: context,
        //         userId: id,
        //         password: val,
        //       )) {
        //         return;
        //       }
        //     } else {
        //       if (await sendLoginRequest(
        //         context: context,
        //         userId: id,
        //         password: val,
        //       )) {
        //         return;
        //       }
        //     }
        //   } else {
        //     // Handle invalid password
        //     // print("Decrypted password is empty");
        //     if (!isClosed) emit(LoginInitial());
        //   }
        // } catch (e) {
        //   // Handle decryption errors
        //   // print("Decryption failed: $e");
        //   if (!isClosed) emit(LoginInitial());
        // }
      } else {
        // Handle empty or invalid data
        // print("Invalid or empty userCode or password");
        if (!isClosed) emit(LoginInitial());
      }
    } else {
      if (!isClosed) emit(LoginInitial());
    }
    // }
    // if (!isClosed) emit(LoginInitial());
  }

  Future<bool> sendLoginRequest({
    required context,
    required String userId,
    required String password,
  }) async {
    UserController().userName = userId;
    UserController().passWord = password;
    if (!isClosed) {
      if (state is LoginInitial) {
        emit((state as LoginInitial).copyWith(loading: true));
      }
    }

    try {
      DateTime requestTime = DateTime.now();

      await FirebaseMessaging.instance.getToken().then((value) async {
        UserController.userController.devicetoken = value!;
        log("devicetoken = $value");
        DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        // print('Running on ${androidInfo.model}');
        // print("Running on ${androidInfo.id}");
        // print("Running on ${androidInfo.device}");
        // print("Running on ${androidInfo.brand}");

        final info = await PackageInfo.fromPlatform();

        final String serverkey = await getAccessToken();
        log("ServerKey = $serverkey");

        await PreferenceUtils.storeDataToShared("devicetoken", value);

        // log("ServerKey = $serverkey");

        String? selectedRegion = await PreferenceUtils.getDataFromShared(
          "selected_region",
        );

        if (selectedRegion != null && selectedRegion.toLowerCase() == "uae") {
          final token = await serviceLocator.tradingApi.loginOtheregion(
            userId: userId,
            password: password,
          );

          if (token.body.isNotEmpty) {
            await PreferenceUtils.storeDataToShared("usertoken", token.body);

            updateUserController(
              sessionKey: "",
              userId: userId,
              username: userId,
              password: password,
            );

            swithcnavigate(context, "7");
            showSnackBar(
              context: context,
              snackBar: showSuccessDialogue(message: "Login Success....!"),
            );
            return true;
          } else {
            showSnackBar(
              context: context,
              snackBar: showErrorDialogue(errorMessage: "Login Failed"),
            );
            return false;
          }
        } else {
          Map<String, dynamic> data = {
            "deviceid": androidInfo.id,
            "device": androidInfo.device,
            "model": androidInfo.model,
          };

          LoginResponse loginResponse = await serviceLocator.tradingApi
              .loginRequest(
                userId: userId,
                password: password,
                token: value,
                bearertoken: "",
                appversion: info.version,
              );
          DateTime responseTime = DateTime.now();

          if (loginResponse.success == 1) {
            UserController.userController.profile = loginResponse.profile;

            await PreferenceUtils.storeDataToShared(
              "usertoken",
              loginResponse.token,
            );

            await PreferenceUtils.storeDataToShared(
              "userid",
              loginResponse.profile.id,
            );

            // Store complete profile data
            await PreferenceUtils.storeDataToShared(
              "user_profile",
              jsonEncode(loginResponse.profile.toJson()),
            );

            // // Encrypt the password
            // String encryptedHex = encryptStringForUser(password, key);

            await PreferenceUtils.storeDataToShared("password", password);

            updateUserController(
              sessionKey: "",
              userId: userId,
              username: userId,
              password: password,
            );

            swithcnavigate(context, loginResponse.profile.role);

            showSnackBar(
              context: context,
              snackBar: showSuccessDialogue(message: "Login Success....!"),
            );

            return true;
          } else {
            showSnackBar(
              context: context,
              snackBar: showErrorDialogue(errorMessage: "Login Failed"),
            );
            return false;
          }
        }
      });
    } on SocketException {
      if (state is LoginInitial) {
        emit(
          (state as LoginInitial).copyWith(error: "Network connectivity error"),
        );
      } else {
        emit(LoginInitial(errorMessage: "Network connectivity error"));
      }
      return false;
    } catch (e, trace) {
      fatalError(e.toString(), trace, "login processing failed");
      if (state is LoginInitial) {
        emit((state as LoginInitial).copyWith(error: e.toString()));
      } else {
        emit(LoginInitial(errorMessage: e.toString()));
      }
    }
    return false;
  }
}

Future<String> getAccessToken() async {
  final serviceAccountJson = {
    "type": "service_account",
    "project_id": "ah-market-5ab28",
    "private_key_id": "4b0826e3443fc8f9f462a16ad9c04a44c910e758",
    "private_key":
        "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDBZKXHg12k8Uov\nqNCnnlzXPlScCalS2OpUxKTAcsfY9mx9MrxcpEn8slKk2stpiZB8DcuGzekkQLjp\nJCfUrVoQcP7RrP+FKeKo0HWDU8jaXA/gMi5pbiqJOYB8JJzEgbEYq3yCvIAC+jTA\njAeRDOH0/OtNi5EYlDDNjsswESX0fNz33bkzZY11lxuV3FMfzwcu9J7g86rt8TMK\n/jIrEJ4uYHsQ2lPcgkJMG4Yhij2IlZtG88k7qRJ+wAmbU2VNYDtQohJnHna9L4o7\nGWqb9bcAqJHXPcm7ptOqsmUvkiyAOxphPot4ZfYS0p7sVWB6USwWZj1gwqjUTNCT\nhnXSnxMNAgMBAAECggEARFuMEYqIhi3XuCLmpejfDiH1DDaKCEOuCIp9ZZzssO7h\niBtv4xsbH9v0RFsl/UbnsEG8CAkueGb8NURXY+BmbltSZtDMfMhCWsNcVjA+VZim\n7+ss5o1PMbQGi1rxoq/o5jxvRVLVuLex/8E/R3ETSWJA1ecYQWTYH0By56mYDeOa\n7iak8Yz4BusYRt3T+d3TP6YrCiWE87TpNm4jZBxMD5VvqnLf6qolXG5qeHa6+5aq\nV8i1HBYUefDeELpmgSSVVHKFdb/iOqBZNstHZNYx17+ZfPrL+beLQuLp1X9mhLiq\n/4/JwWYj3ufGN/mpOznzb8+QOgXUUAjmggIYyhFkjQKBgQDxoi27KrOdeobXsPsa\nuZ/oUMUYlwL9WyYpZJoJSQuMSDOGkiHMkBHPp0loRr1jzs7lz9G0yFDUnMj4+Tow\n3vHof5Fh1dOOVO5zkS70jboVGZYQDDN076lSeXBWBcqvqmq4qTH5WVnCklgonuIu\n3riiT8x4FGheAZOfvHK3oG/n+wKBgQDM5DgKw0L6OfRNuuJcPc4q4uZejnN9TKn8\nDaNoTX7oMYF+XtfjPP0x7tUzczGCsb7zolqHxYqErRey71dD+W5wmWQggG+Qk/0D\n4uEN9qeBnJ2jb/9vb3yBOIccJM27OosPmGPQ7xkM+h9SZm1KSUjrGEpx8ae/AWPb\n25ch4v1alwKBgHGy9H3bzATQAN9BggbDTcFNMFEvzdJVr5FOq0SvQGXUG5q47HqL\nWDYz61DL6JYsXCK7NVwx3gcNd2vgKkeQwJe8XzaAHToeMM3khQnCHsuK7JfEhfoC\nQ9RxHDD+LK+YKvuVcdR4/MmXfzAuAxQ27P5DOl1OjQWfDE3fqMNLFR09AoGBAKgM\nJsrtC+ofznhSZ4YwSwBxyXCUdbS3RFQu+2944DWhJQx4zajbRO/Ha6YfPORs1KkO\n6CGjq9DWBzIDjBd8ZVCE/tKJhPeX6VVeqCfDve9YfRKnsWG8lumFa4txxCtkANpx\nqqya7njuTPJQgCMFqIDqE2URRvwqL7ULjhGFEzdRAoGAWwEcpY/OU6STMCI5W/h/\n+thpxviYqpcyiEQGGBjz9PVt7/8zO6o9JayjSpmFJmRym3tNro31/pBtV+5aqy4S\nk9jen/GKBWFe43zmNpWOU9VPJUdwWpBzHoxlneFa1TzrAVDpRk2du1gRQb8pELSc\nscCSMvNe284Sq7syegYVr80=\n-----END PRIVATE KEY-----\n",
    "client_email":
        "firebase-adminsdk-a6zp5@ah-market-5ab28.iam.gserviceaccount.com",
    "client_id": "107685861698938940303",
    "auth_uri": "https://accounts.google.com/o/oauth2/auth",
    "token_uri": "https://oauth2.googleapis.com/token",
    "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
    "client_x509_cert_url":
        "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-a6zp5%40ah-market-5ab28.iam.gserviceaccount.com",
    "universe_domain": "googleapis.com",
  };

  List<String> scopes = [
    "https://www.googleapis.com/auth/userinfo.email",
    "https://www.googleapis.com/auth/firebase.messaging",
    "https://www.googleapis.com/auth/firebase.database",
  ];

  http.Client client = await auth.clientViaServiceAccount(
    auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
    scopes,
  );

  auth.AccessCredentials credentials = await auth
      .obtainAccessCredentialsViaServiceAccount(
        auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
        scopes,
        client,
      );

  client.close();

  return credentials.accessToken.data;
}

updateUserController({
  required String sessionKey,
  required String userId,
  required String username,
  required String password,
}) {
  // UserController().sessionKey = sessionKey;
  UserController().userName = username;
  UserController.userController.userShortName =
      username
          .split(" ")
          .map((el) => el.substring(0, 1))
          .join("")
          .toUpperCase();
  UserController.userController.userShortName = UserController
      .userController
      .userShortName
      .substring(
        0,
        UserController.userController.userShortName.length > 1 ? 2 : 1,
      );
  UserController().userName = userId;
  updateUserData(username: username, userId: userId, password: password);
}

updateUserData({
  required String username,
  required String userId,
  required String password,
}) async {
  await PreferenceUtils.storeDataToShared("userCode", userId);
  await PreferenceUtils.storeDataToShared("password", password);
  if (!(await PreferenceUtils.preferenceHasKey(userId))) {
    UserSettings.userSettings.fromJson({});
    await PreferenceUtils.storeDataToShared(
      userId,
      UserSettings.userSettings.toJsonString(),
    );
  }
  String? userData = await PreferenceUtils.getDataFromShared(userId);
  UserSettings.userSettings.fromJsonString(userData!);
  UserSettings.userSettings.userPersonalSettings.username = username;
  UserSettings.userSettings.userPersonalSettings.username = userId;
  PreferenceUtils.storeDataToShared(
    userId,
    UserSettings.userSettings.toJsonString(),
  );
}
