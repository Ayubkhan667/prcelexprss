import 'package:flutter/material.dart';

class AppColors {
  // Primary Blue Palette
  static const Color primary = Color(0xFF1565C0);
  static const Color primaryDark = Color(0xFF0D47A1);
  static const Color primaryLight = Color(0xFF1E88E5);
  static const Color primarySurface = Color(0xFFE3F2FD);

  // Accent Orange Palette
  static const Color accent = Color(0xFFFF6B35);
  static const Color accentDark = Color(0xFFE64A19);
  static const Color accentLight = Color(0xFFFF8A65);
  static const Color accentSurface = Color(0xFFFFF3E0);

  // Neutral
  static const Color background = Color(0xFFF5F7FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color divider = Color(0xFFE8ECF0);

  // Text
  static const Color textPrimary = Color(0xFF1A2332);
  static const Color textSecondary = Color(0xFF6B7A8D);
  static const Color textHint = Color(0xFFADB5BD);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnAccent = Color(0xFFFFFFFF);

  // Status Colors
  static const Color success = Color(0xFF2E7D32);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color warning = Color(0xFFF57F17);
  static const Color warningLight = Color(0xFFFFFDE7);
  static const Color error = Color(0xFFC62828);
  static const Color errorLight = Color(0xFFFFEBEE);
  static const Color info = Color(0xFF0277BD);
  static const Color infoLight = Color(0xFFE1F5FE);

  // Attendance Status
  static const Color present = Color(0xFF2E7D32);
  static const Color absent = Color(0xFFC62828);
  static const Color late = Color(0xFFF57F17);
  static const Color onLeave = Color(0xFF6A1B9A);
  static const Color overtime = Color(0xFF1565C0);
  static const Color earlyOut = Color(0xFFE65100);
  static const Color missingCheckout = Color(0xFF37474F);

  // Chart Colors
  static const List<Color> chartColors = [
    Color(0xFF2E7D32),
    Color(0xFFC62828),
    Color(0xFFF57F17),
    Color(0xFF6A1B9A),
    Color(0xFF1565C0),
  ];

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1565C0), Color(0xFF1E88E5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFFF6B35), Color(0xFFFF8A65)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient dashboardGradient = LinearGradient(
    colors: [Color(0xFF0D47A1), Color(0xFF1565C0)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
