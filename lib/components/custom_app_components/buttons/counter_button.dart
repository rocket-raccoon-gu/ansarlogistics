import 'package:ansarlogistics/themes/style.dart';
import 'package:flutter/material.dart';

class CounterDropdown extends StatefulWidget {
  final int initNumber;
  final Function(int) counterCallback;
  final int minNumber;
  final int maxNumber; // Define a max limit
  final bool showLabel;

  CounterDropdown({
    required this.initNumber,
    required this.counterCallback,
    required this.minNumber,
    required this.maxNumber,
    this.showLabel = true,
  });

  @override
  State<CounterDropdown> createState() => _CounterDropdownState();
}

class _CounterDropdownState extends State<CounterDropdown> {
  late int _currentCount;

  @override
  void initState() {
    _currentCount = widget.initNumber;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget dropdownBox = Container(
      decoration: BoxDecoration(
        border: Border.all(color: customColors().fontTertiary),
        borderRadius: BorderRadius.circular(widget.showLabel ? 5.0 : 8.0),
        color: Colors.white,
      ),
      height: widget.showLabel ? null : 44,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: widget.showLabel ? 14.0 : 12.0,
        ),
        child: DropdownButton<int>(
          value: _currentCount,
          underline: widget.showLabel ? null : SizedBox.shrink(),
          isDense: !widget.showLabel,
          items:
              List.generate(
                widget.maxNumber - widget.minNumber + 1,
                (index) => widget.minNumber + index,
              ).map((number) {
                return DropdownMenuItem<int>(
                  value: number,
                  child: Text(number.toString()),
                );
              }).toList(),
          onChanged: (int? newValue) {
            if (newValue != null) {
              setState(() {
                _currentCount = newValue;
                widget.counterCallback(_currentCount);
              });
            }
          },
        ),
      ),
    );

    if (!widget.showLabel) {
      return dropdownBox;
    }

    return Container(
      padding: EdgeInsets.zero,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Confirm Qty",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          dropdownBox,
        ],
      ),
    );
  }
}
