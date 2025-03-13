import 'package:ansarlogistics/themes/style.dart';
import 'package:flutter/material.dart';

class CounterContainer extends StatefulWidget {
  final int initNumber;
  final Function(int) counterCallback;
  final Function increaseCallback;
  final Function decreaseCallback;
  final int minNumber;
  CounterContainer({
    required this.initNumber,
    required this.counterCallback,
    required this.increaseCallback,
    required this.decreaseCallback,
    required this.minNumber,
  });

  @override
  State<CounterContainer> createState() => _CounterContainerState();
}

class _CounterContainerState extends State<CounterContainer> {
  int _currentCount = 1;

  @override
  void initState() {
    _currentCount = widget.initNumber;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.zero,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Quantity",
            style: customTextStyle(fontStyle: FontStyle.HeaderXS_Bold),
          ),
          Row(
            children: [
              InkWell(
                onTap: _dicrement,
                child:
                    _currentCount == 0
                        ? Container(
                          padding: EdgeInsets.symmetric(
                            vertical: 3.5,
                            horizontal: 3.5,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: customColors().fontTertiary.withOpacity(
                                0.2,
                              ),
                            ),
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.remove,
                              color: customColors().fontPrimary.withOpacity(
                                0.2,
                              ),
                            ),
                          ),
                        )
                        : Container(
                          padding: EdgeInsets.symmetric(
                            vertical: 3.5,
                            horizontal: 3.5,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: customColors().fontTertiary,
                            ),
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.remove,
                              color: customColors().fontPrimary,
                            ),
                          ),
                        ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Text(
                  _currentCount.toString(),
                  style: customTextStyle(
                    fontStyle: FontStyle.BodyL_Bold,
                    color: FontColor.FontPrimary,
                  ),
                ),
              ),
              InkWell(
                onTap: _increment,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 3.5, horizontal: 3.5),
                  decoration: BoxDecoration(
                    border: Border.all(color: customColors().fontTertiary),
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: Center(
                    child: Icon(Icons.add, color: customColors().fontPrimary),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _increment() {
    setState(() {
      _currentCount++;
      widget.counterCallback(_currentCount);
      widget.increaseCallback();
    });
  }

  void _dicrement() {
    setState(() {
      if (_currentCount > widget.minNumber) {
        _currentCount--;
        widget.counterCallback(_currentCount);
        widget.decreaseCallback();
      }
    });
  }
}
