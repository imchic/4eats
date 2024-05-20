import 'dart:ui';

class TextStyleUtils {
  static TextStyle textStyle({
    required double fontSize,
    required Color color,
    FontWeight? fontWeight,
  }) {
    return TextStyle(
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
    );
  }

  static TextStyle textStyleWithDecoration({
    required double fontSize,
    required Color color,
    FontWeight? fontWeight,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
      decoration: decoration,
    );
  }

  static TextStyle textStyleWithDecorationAndHeight({
    required double fontSize,
    required Color color,
    FontWeight? fontWeight,
    TextDecoration? decoration,
    double? height,
  }) {
    return TextStyle(
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
      decoration: decoration,
      height: height,
    );
  }

  static TextStyle textStyleWithDecorationAndHeightAndLetterSpacing({
    required double fontSize,
    required Color color,
    FontWeight? fontWeight,
    TextDecoration? decoration,
    double? height,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
      decoration: decoration,
      height: height,
      letterSpacing: letterSpacing,
    );
  }



}