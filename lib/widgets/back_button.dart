import 'package:flutter/material.dart';
import '../constants/colors.dart';

class WasteLessBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color? iconColor;

  const WasteLessBackButton({super.key, this.onPressed, this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.9),
      shape: const CircleBorder(),
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.2),
      child: IconButton(
        icon: Icon(
          Icons.arrow_back_rounded,
          color: iconColor ?? AppColors.primary,
        ),
        onPressed: onPressed ?? () => Navigator.pop(context),
        tooltip: 'Back',
      ),
    );
  }
}
