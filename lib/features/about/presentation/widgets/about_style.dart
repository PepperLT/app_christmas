import 'package:flutter/material.dart';

abstract final class AboutStyle {
  static const background = Color(0xFFF8F5F2);
  static const primary = Color(0xFF632333);
  static const secondary = Color(0xFF51454A);
  static const border = Color(0xFFF0DDD7);
  static const accent = Color(0xFFB4232B);
  static const heading = TextStyle(
    color: primary,
    fontSize: 24,
    fontWeight: FontWeight.w800,
    height: 1.25,
  );
  static const body = TextStyle(color: secondary, fontSize: 16, height: 1.6);
  static BoxDecoration get card => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(24),
    border: Border.all(color: border),
    boxShadow: const [
      BoxShadow(color: Color(0x08632333), blurRadius: 16, offset: Offset(0, 8)),
    ],
  );
}
