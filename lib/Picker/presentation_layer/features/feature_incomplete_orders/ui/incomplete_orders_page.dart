import 'package:ansarlogistics/constants/methods.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:flutter/material.dart';

class IncompleteOrdersPage extends StatefulWidget {
  const IncompleteOrdersPage({super.key});

  @override
  State<IncompleteOrdersPage> createState() => _IncompleteOrdersPageState();
}

class _IncompleteOrdersPageState extends State<IncompleteOrdersPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0.0),
        child: AppBar(elevation: 0, backgroundColor: HexColor('#F9FBFF')),
      ),
      backgroundColor: customColors().backgroundPrimary,
      body: const Center(child: Text("Incomplete Orders")),
    );
  }
}
