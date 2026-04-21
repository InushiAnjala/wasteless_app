import 'package:flutter/material.dart';

class OrganicShape extends StatelessWidget {
  final double width;
  final double height;
  final Color color;

  const OrganicShape({
    super.key,
    required this.width,
    required this.height,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.all(Radius.elliptical(width, height)),
      ),
    );
  }
}
