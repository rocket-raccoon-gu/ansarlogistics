import 'package:ansarlogistics/constants/methods.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:flutter/material.dart';

class AnimatedSwitch extends StatefulWidget {
  bool defaultval;
  Function() onTap;
  AnimatedSwitch({required this.defaultval, required this.onTap});
  @override
  _AnimatedSwitchState createState() => _AnimatedSwitchState();
}

class _AnimatedSwitchState extends State<AnimatedSwitch> {
  final animationDuration = Duration(milliseconds: 500);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        height: 30,
        width: 46,
        duration: animationDuration,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: HexColor('#AEAEAE'),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade400,
              spreadRadius: 0,
              blurRadius: 5,
            ),
          ],
        ),
        child: AnimatedAlign(
          duration: animationDuration,
          alignment:
              widget.defaultval ? Alignment.centerRight : Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 2),
            child: Container(
              width: 25,
              height: 25,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    widget.defaultval
                        ? HexColor("#C8E93D")
                        : customColors().backgroundPrimary,
                border: Border.all(
                  color: customColors().backgroundPrimary,
                  width: 2.8,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class loadingindecator extends StatelessWidget {
  const loadingindecator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(8.0),
      child: Center(
        child: CircularProgressIndicator(
          color: Color.fromRGBO(183, 214, 53, 1),
        ),
      ),
    );
  }
}
