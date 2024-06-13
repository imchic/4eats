import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'colors.dart';

class TextStyleUtils {

  static TextStyle feedAddressTitle({
    Color color = Colors.white,
    double fontSize = 26,
    FontWeight fontWeight = FontWeight.w700,
  }) {
    return TextStyle(
      color: color,
      fontSize: fontSize.sp,
      fontWeight: fontWeight,
      fontFamily: 'Godob'
    );
  }

  /// 제목
  static TextStyle titleTextStyle({
    Color color = Colors.black,
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.bold,
  }) {
    return TextStyle(
      color: color,
      fontSize: fontSize.sp,
      fontWeight: fontWeight,
    );
  }

  /// 부제목
  static TextStyle subTitleTextStyle({
    Color color = Colors.black,
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w600,
  }) {
    return TextStyle(
      color: color,
      fontSize: fontSize.sp,
      fontWeight: fontWeight,
    );
  }

  /// 본문
  static TextStyle bodyTextStyle({
      Color color = Colors.black,
      double fontSize = 12,
      FontWeight fontWeight = FontWeight.w400,
      int height = 0
  }) {
    return TextStyle(
      color: color,
      fontSize: fontSize.sp,
      fontWeight: fontWeight,
      height: height.sp,
      fontFamily: 'Pretendard',
    );
  }

  // 흰색
  static TextStyle whiteTextStyle({
    double fontSize = 12,
    FontWeight fontWeight = FontWeight.w400
  }) {
    return TextStyle(
      color: Colors.white,
      fontSize: fontSize.sp,
      fontWeight: fontWeight,
      letterSpacing: 0.1,
    );
  }

  /// 댓글 작성자
  static TextStyle commentTitleTextStyle({
    Color color = Colors.black,
    double fontSize = 12,
    FontWeight fontWeight = FontWeight.bold,
  }) {
    return TextStyle(
      color: color,
      fontSize: fontSize.sp,
      fontWeight: fontWeight,
    );
  }

  /// 댓글 멘션
  static TextStyle commentMentionTextStyle({
    Color color = Colors.black,
    double fontSize = 12,
    FontWeight fontWeight = FontWeight.bold,
  }) {
    return TextStyle(
      color: color,
      fontSize: fontSize.sp,
      fontWeight: fontWeight,
    );
  }

  // 댓글 내용
  static TextStyle? commentContentTextStyle({
    Color color = Colors.black,
    double fontSize = 12,
    FontWeight fontWeight = FontWeight.w400,
  }) {
    return TextStyle(
      color: color,
      fontSize: fontSize.sp,
      fontWeight: fontWeight,
    );
  }

  static TextStyle? commentContentSetColorTextStyle({
    Color color = Colors.black,
    double fontSize = 12,
    FontWeight fontWeight = FontWeight.w400,
  }) {
    return TextStyle(
      color: color,
      fontSize: fontSize.sp,
      fontWeight: fontWeight,
    );
  }

  // 라운지 타이틀
  static TextStyle loungeTitleTextStyle({
    Color color = Colors.black,
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.bold,
  }) {
    return TextStyle(
      color: color,
      fontSize: fontSize.sp,
      fontWeight: fontWeight,
    );
  }

  // 라운지 서브 타이틀
  static TextStyle loungeSubTitleTextStyle({
    Color color = Colors.black,
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w600,
  }) {
    return TextStyle(
      color: color,
      fontSize: fontSize.sp,
      fontWeight: fontWeight,
    );
  }

}