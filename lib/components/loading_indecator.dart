import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class LoadingIndecator extends StatelessWidget {
  const LoadingIndecator({super.key});

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
