import 'package:flutter/material.dart';

/// Design Tokens — لوحة ألوان التطبيق (نهاري ورقي + ليلي OLED حقيقي)
class AppColors {
  AppColors._();

  static const paper = Color(0xFFF7F3E8);
  static const paperCard = Color(0xFFFDFCF7);
  static const ink = Color(0xFF1A1A18);
  static const muted = Color(0xFF8A8578);
  static const emerald = Color(0xFF0E6B5C);
  static const gold = Color(0xFFB98A2E);
  static const danger = Color(0xFFC0392B);

  static const oledBlack = Color(0xFF000000);
  static const darkCard = Color(0xFF121212);
  static const darkInk = Color(0xFFE8E4D8);
  static const darkMuted = Color(0xFF9A958A);
  static const darkEmerald = Color(0xFF3AC9A0); // زمردي شاشة البداية
  static const darkGold = Color(0xFFD4A84E);

  /// ألوان التمييز الخمسة
  static const highlightColors = [
    Color(0xFFF5D76E), // أصفر
    Color(0xFF9FD5A5), // أخضر
    Color(0xFFF2A7B8), // وردي
    Color(0xFFA7C7F2), // أزرق
    Color(0xFFE3C4F0), // بنفسجي
  ];
}
