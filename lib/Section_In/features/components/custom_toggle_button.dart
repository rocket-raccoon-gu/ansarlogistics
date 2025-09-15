import 'package:flutter/material.dart';

class CustomToggleButton1 extends StatelessWidget {
  final int isSelected;
  final ValueChanged<int> onChanged;

  CustomToggleButton1({required this.isSelected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onChanged(isSelected == 1 ? 0 : 1);
      },
      child: Container(
        width: 60.0,
        height: 30.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.0),
          color: isSelected == 1 ? Colors.green : Colors.grey,
        ),
        child: Stack(
          children: [
            AnimatedAlign(
              duration: Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              alignment: isSelected == 1
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: Container(
                width: 28.0,
                height: 28.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
