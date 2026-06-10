import 'package:flutter/material.dart';
import '_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static const String fontFamily = 'Junge';

  static TextStyle splashTitle(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final scale = width / 390;

    return TextStyle(
      fontFamily: fontFamily,
      fontWeight: FontWeight.w400,
      fontSize: 48 * scale,
      height: 1.0,
      letterSpacing: 0.24,
      color: AppColors.black,
    );
  }
}
