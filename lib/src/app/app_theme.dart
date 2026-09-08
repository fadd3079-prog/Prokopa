import 'package:flutter/material.dart';
import 'package:prokopa/src/core/constants/brand_constants.dart';

abstract final class AppTheme {
  static final light = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: BrandConstants.primaryColor,
      primary: BrandConstants.primaryColor,
    ),
    useMaterial3: true,
  );

  static final dark = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: BrandConstants.primaryColor,
      brightness: Brightness.dark,
    ),
    useMaterial3: true,
  );
}
