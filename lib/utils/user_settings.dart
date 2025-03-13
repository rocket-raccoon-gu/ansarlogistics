import 'dart:convert';

import 'package:ansarlogistics/utils/order_settings.dart';
import 'package:ansarlogistics/utils/user_personal_settings.dart';

class UserSettings {
  static final UserSettings userSettings = UserSettings._privateConstructor();
  UserSettings._privateConstructor()
    : orderSettings = OrderSettings(
        deliveryfrom: DateTime.now(),
        deliveryto: DateTime.now(),
        items: [],
      ),
      // orderPreference = OrderPreference(),
      // notificationSettings = NotificationSettings(),
      // otherSettings = OtherSettings(),
      userPersonalSettings = UserPersonalSettings();

  factory UserSettings() {
    return userSettings;
  }

  String version = "";
  String currentTheme = "Light";
  OrderSettings orderSettings;
  UserPersonalSettings userPersonalSettings;

  Map<String, dynamic> toJson() => {
    "currentTheme": currentTheme,
    "orderSettings": orderSettings,
    "userPersonalSettings": userPersonalSettings,
    "Version": version,
  };

  UserSettings fromJson(Map<String, dynamic> json) {
    UserSettings.userSettings.currentTheme = json["currentTheme"] ?? "Light";
    UserSettings.userSettings.orderSettings = OrderSettings.fromJson(
      json['orderSettings'] ??
          OrderSettings(
            deliveryfrom: DateTime.now(),
            deliveryto: DateTime.now(),
            items: [],
          ).toJson(),
    );
    UserSettings
        .userSettings
        .userPersonalSettings = UserPersonalSettings.fromJson(
      json["userPersonalSettings"] ?? UserPersonalSettings().toJson(),
    );
    UserSettings.userSettings.version = json["Version"] ?? "";
    return UserSettings.userSettings;
  }

  UserSettings fromJsonString(String str) {
    return str.isEmpty ? UserSettings() : fromJson(json.decode(str));
  }

  String toJsonString() => json.encode(userSettings.toJson());
}
