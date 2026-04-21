import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OrganicButton extends StatelessWidget {
  final String text;
  final bool isPrimary;
  final VoidCallback onPressed;
  final IconData? icon;

  const OrganicButton({
    super.key,
    required this.text,
    this.isPrimary = true,
    required this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? const Color(0xFF3CB371) : Colors.white,
          foregroundColor: isPrimary ? Colors.white : const Color(0xFF3CB371),
          elevation: isPrimary ? 12 : 0,
          shadowColor: const Color(0xFF3CB371).withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: isPrimary 
                ? BorderSide.none 
                : const BorderSide(color: Color(0xFF3CB371), width: 2),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: GoogleFonts.rubik(
                textStyle: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            if (icon != null) ...[
              const SizedBox(width: 12),
              Icon(icon, size: 22),
            ],
          ],
        ),
      ),
    );
  }
}
