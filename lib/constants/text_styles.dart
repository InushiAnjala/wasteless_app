import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

class AppTextStyles {
  static TextStyle heading = GoogleFonts.poppins(
    fontSize: 26,
    fontWeight: FontWeight.bold,
    color: AppColors.darkText,
  );

  static TextStyle subHeading = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.lightText,
  );
}
