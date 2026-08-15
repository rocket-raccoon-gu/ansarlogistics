import 'package:ansarlogistics/Picker/repository_layer/more_content.dart';
import 'package:ansarlogistics/components/custom_app_components/buttons/basket_button.dart';
import 'package:ansarlogistics/components/custom_app_components/scrollable_bottomsheet/scrollable_bottomsheet.dart';
import 'package:ansarlogistics/firebase_configs/init_notification.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:flutter/material.dart';

bool isSessionTimeoutNetworkEvent(String event) {
  final lower = event.toLowerCase();
  return lower.contains('session timeout') ||
      lower.contains('not authorized to access this route') ||
      lower.contains('please relogin');
}

bool _isPreLoginRoute(String? name) {
  if (name == null || name.isEmpty) return false;
  return name == '/login' ||
      name == '/splash' ||
      name == '/signup' ||
      name == '/selectregionspageroutename';
}

void presentSessionTimeoutSheet({BuildContext? context}) {
  final ctx = context ?? navigatorKey.currentContext;
  if (ctx == null || !ctx.mounted) return;

  String? routeName = ModalRoute.of(ctx)?.settings.name;
  if (routeName == null || routeName.isEmpty) {
    navigatorKey.currentState?.popUntil((route) {
      routeName = route.settings.name;
      return true;
    });
  }
  if (_isPreLoginRoute(routeName)) return;

  sessionTimeOutBottomSheet(
    context: ctx,
    inputWidget: SessionOutBottomSheet(
      onTap: () async {
        await logout(ctx);
      },
    ),
  );
}

class SessionOutBottomSheet extends StatelessWidget {
  VoidCallback? onTap;
  SessionOutBottomSheet({Key? key, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const SizedBox(height: 40),
        Image.asset("assets/failed.png"),
        const SizedBox(height: 16),
        Text(
          "Oh no! Session Timed Out",
          textAlign: TextAlign.center,
          style: customTextStyle(
            fontStyle: FontStyle.HeaderS_SemiBold,
            color: FontColor.FontPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          "Your session timed out, or you logged in from a diffrent location",
          textAlign: TextAlign.center,
          style: customTextStyle(
            fontStyle: FontStyle.BodyL_Regular,
            color: FontColor.FontSecondary,
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: BasketButton(
                  bgcolor: customColors().primary,
                  text: "Relogin",
                  textStyle: customTextStyle(
                    fontStyle: FontStyle.BodyL_SemiBold,
                    color: FontColor.White,
                  ),
                  onpress: onTap,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
