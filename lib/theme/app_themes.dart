import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stream_app/theme/theme.dart';


ThemeData appTheme() {
  return ThemeData(
    scaffoldBackgroundColor: AppColors.whiteColor,
    primaryColor: AppColors.primaryColor,
    dialogBackgroundColor: AppColors.whiteColor,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primaryColor,
      onPrimary: AppColors.whiteColor,
      secondary: AppColors.primaryColor,
      onSecondary: AppColors.textSubtitleColor,
      error: AppColors.errorColor,
      onError: AppColors.errorColor,
      surface: AppColors.backgroundColor,
      onSurface: AppColors.textTitleColor,
    ),
    dividerColor: AppColors.dividerColor,
    appBarTheme: appBarTheme(),
  );
}

AppBarTheme appBarTheme() {
  return const AppBarTheme(
    color: AppColors.primaryColor,
    elevation: 0,
    centerTitle: true,
    systemOverlayStyle: SystemUiOverlayStyle(
         statusBarColor: AppColors.primaryDarkColor, // Status bar
     ),
    iconTheme: IconThemeData(color: AppColors.textTitleColor),
    titleTextStyle: TextStyle(
      color: AppColors.textTitleColor,
      fontSize: 16,
      fontFamily: 'Inter',
      fontWeight: FontWeight.w600,
    ),
  );
}
