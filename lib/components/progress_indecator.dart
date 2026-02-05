import 'package:ansarlogistics/themes/style.dart';
import 'package:flutter/material.dart';

class CustomProgressIndicator extends StatefulWidget {
  final Duration duration;
  const CustomProgressIndicator({
    super.key,
    this.duration = const Duration(seconds: 5),
  });

  @override
  State<CustomProgressIndicator> createState() =>
      _CustomProgressIndicatorState();
}

class _CustomProgressIndicatorState extends State<CustomProgressIndicator>
    with TickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    controller = AnimationController(vsync: this, duration: widget.duration)
      ..addListener(() {
        setState(() {});
      });
    controller.repeat(period: widget.duration);
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
      value: controller.value,
      color: customColors().primary,
    );
  }
}
