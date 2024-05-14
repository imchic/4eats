import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';

import 'login_controller.dart';

class LoginScreen extends GetView<LoginController> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _background(context),
          _headline(),
          _loginButton(),
        ],
      ),
    );
  }

  Widget _background(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: const Image(
        image: AssetImage('assets/images/bg_login.png'),
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _headline() {
    return Container(
      width: 229.w,
      height: 120.h,
      margin: EdgeInsets.only(top: 120.h, left: 37.w, right: 124.w, bottom: 604.h),
      child: Text(
        '달달한 기분전환!\n브릭스에 오신것을\n환영합니다!',
        style: TextStyle(
          color: Colors.white,
          fontSize: 32.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _loginButton() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: 315.w,
        height: 56.h,
        margin: EdgeInsets.only(bottom: 100.h),
        child: ElevatedButton(
          onPressed: () {
            //controller.login();
          },
          style: ElevatedButton.styleFrom(
            //primary: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
          child: Text(
            '로그인',
            style: TextStyle(
              color: Colors.black,
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

}
