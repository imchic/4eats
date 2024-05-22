import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'colors.dart';

class TextStyleUtils {

  /// 제목
  TextStyle titleTextStyle() {
    return TextStyle(
      color: Colors.black,
      fontSize: 16.sp,
      fontWeight: FontWeight.bold,
    );
  }

  /// 부제목
  TextStyle subTitleTextStyle() {
    return TextStyle(
      color: Colors.black,
      fontSize: 14.sp,
      fontWeight: FontWeight.bold,
    );
  }

  /// 본문
  TextStyle bodyTextStyle() {
    return TextStyle(
      color: Colors.black,
      fontSize: 12.sp,
      fontWeight: FontWeight.w400,
    );
  }

  // 흰색
  TextStyle whiteTextStyle() {
    return TextStyle(
      color: Colors.white,
      fontSize: 12.sp,
      fontWeight: FontWeight.w400,
    );
  }

  /// 댓글 작성자
  TextStyle commentTitleTextStyle() {
    return  TextStyle(
      color: Colors.black,
      fontSize: 12.sp,
      fontWeight: FontWeight.bold,
    );
  }

  /// 댓글 멘션
  TextStyle commentMentionTextStyle(Color secondary) {
    return TextStyle(
      color: secondary,
      fontSize: 12.sp,
      fontWeight: FontWeight.bold,
    );
  }

  // 댓글 내용
  TextStyle? commentContentTextStyle() {
    return TextStyle(
      color: gray600,
      fontSize: 11.sp,
      fontWeight: FontWeight.w400,
    );
  }

  TextStyle? commentContentSetColorTextStyle(Color color) {
    return TextStyle(
      color: color,
      fontSize: 12.sp,
      fontWeight: FontWeight.bold,
    );
  }

}