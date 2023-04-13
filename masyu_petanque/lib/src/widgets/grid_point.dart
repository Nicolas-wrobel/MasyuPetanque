import 'package:flutter/material.dart';

class GridPoint extends StatelessWidget {
  final Color color;

  const GridPoint({Key? key, required this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}
