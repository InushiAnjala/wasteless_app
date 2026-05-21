import 'package:flutter/material.dart';

/// Modern gradient definitions for WasteLess app
class AppGradients {
  // Primary gradient - Emerald to Teal
  static const LinearGradient primary = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF14B8A6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Secondary gradient - Deep emerald variation
  static const LinearGradient secondary = LinearGradient(
    colors: [Color(0xFF059669), Color(0xFF0D9488)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Accent gradient - Vibrant teal to cyan
  static const LinearGradient accent = LinearGradient(
    colors: [Color(0xFF14B8A6), Color(0xFF06B6D4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Background gradient - Soft emerald wash
  static const LinearGradient background = LinearGradient(
    colors: [Color(0xFFF0FDF4), Color(0xFFECFDF5)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Dark background gradient for premium sections
  static const LinearGradient darkBackground = LinearGradient(
    colors: [Color(0xFF064E3B), Color(0xFF134E4A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Glass effect overlay
  static const LinearGradient glass = LinearGradient(
    colors: [Color(0x40FFFFFF), Color(0x20FFFFFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Warning gradient - Amber to orange
  static const LinearGradient warning = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFF97316)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Error gradient - Red to pink
  static const LinearGradient error = LinearGradient(
    colors: [Color(0xFFEF4444), Color(0xFFEC4899)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Success gradient - Green variation
  static const LinearGradient success = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF22C55E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Shimmer gradient for loading states
  static const LinearGradient shimmer = LinearGradient(
    colors: [Color(0xFFE5E7EB), Color(0xFFF3F4F6), Color(0xFFE5E7EB)],
    begin: Alignment(-1.0, 0.0),
    end: Alignment(1.0, 0.0),
  );
}

/// Glassmorphism decoration presets
class GlassDecorations {
  // Standard glass card
  static BoxDecoration card({
    Color? color,
    double borderRadius = 20,
    bool hasBorder = true,
  }) {
    return BoxDecoration(
      color: color ?? const Color(0x30FFFFFF),
      borderRadius: BorderRadius.circular(borderRadius),
      border: hasBorder
          ? Border.all(color: const Color(0x40FFFFFF), width: 1.5)
          : null,
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF000000).withValues(alpha: 0.1),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }

  // Premium glass card with stronger effect
  static BoxDecoration premiumCard({double borderRadius = 24}) {
    return BoxDecoration(
      gradient: AppGradients.glass,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: const Color(0x50FFFFFF), width: 2),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF000000).withValues(alpha: 0.15),
          blurRadius: 30,
          offset: const Offset(0, 15),
        ),
        BoxShadow(
          color: const Color(0xFFFFFFFF).withValues(alpha: 0.1),
          blurRadius: 10,
          offset: const Offset(-5, -5),
        ),
      ],
    );
  }

  // Elevated card with gradient
  static BoxDecoration elevatedGradient({
    required Gradient gradient,
    double borderRadius = 20,
  }) {
    return BoxDecoration(
      gradient: gradient,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF10B981).withValues(alpha: 0.3),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }
}
