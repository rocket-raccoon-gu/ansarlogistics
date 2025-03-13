class UserPersonalSettings {
  UserPersonalSettings({this.username = "", this.password = ""});
  String username;
  String password;
  factory UserPersonalSettings.fromJson(Map<String, dynamic> json) =>
      UserPersonalSettings(
        username: json["username"] ?? "",
      );
  Map<String, dynamic> toJson() => {"username": username};
}
