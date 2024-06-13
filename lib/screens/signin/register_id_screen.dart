import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foreats/screens/signin/sign_controller.dart';

import 'package:get/get.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:googleapis/admob/v1.dart';
import 'package:logger/logger.dart';

import '../../utils/app_routes.dart';
import '../../utils/colors.dart';
import '../../utils/toast_controller.dart';
import '../../utils/logger.dart';
import '../../widget/base_appbar.dart';
import '../login/login_controller.dart';
import '../login/user_store.dart';

class RegisterIdScreen extends GetView<SignController> {
  const RegisterIdScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(ToastController());
    return Scaffold(
      backgroundColor: Theme
          .of(context)
          .colorScheme
          .background,
      appBar: BaseAppBar(
        title: '회원가입',
        leading: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // 진행바
                    Container(
                      width: 350.w,
                      height: 10.h,
                      // round decoration
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.r),
                        color: Color(0xffE5E5E5),
                      ),
                      margin: EdgeInsets.only(bottom: 20.h),
                      child: Stack(
                        children: [
                          // progress
                          Container(
                            width: 350.w * 0.33,
                            height: 10.h,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.r),
                              color: Theme
                                  .of(Get.context!)
                                  .colorScheme
                                  .secondary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Container(
                      margin: EdgeInsets.only(bottom: 20.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '아이디를 입력해주세요.',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                              height: 1.5,
                            ),
                          ),
                          SizedBox(height: 2.5.h),
                          Text(
                            '${AppRoutes
                                .baseAppName}에서 사용할 고유 아이디를 입력해주세요. \n한번 설정한 아이디는 변경할 수 없어요!',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w400,
                              color: gray600,
                              height: 1.5,
                            ),
                          ),
                          // round shape decoration textfield
                          SizedBox(height: 10.h),
                          Container(
                            width: 350.w,
                            height: 50.h,
                            margin: EdgeInsets.only(bottom: 20.h),
                            decoration: ShapeDecoration(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: controller.idController,
                                    decoration: InputDecoration(
                                      prefixText: '@ ',
                                      prefixStyle: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w700,
                                        color: gray600,
                                      ),
                                      hintText: '아이디를 입력해주세요.',
                                      hintStyle: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w400,
                                        color: gray400,
                                      ),
                                      suffix: GestureDetector(
                                        onTap: () {
                                          controller.idController.clear();
                                        },
                                        child: Container(
                                          margin: EdgeInsets.only(right: 10.w),
                                          child: Icon(
                                            Icons.clear,
                                            color: gray600,
                                            size: 20.r,
                                          ),
                                        ),
                                      ),
                                    ),
                                    onChanged: (value) {
                                      //_validator(value);
                                      //controller.validateId(value);
                                      controller.id.value = controller.idController.text;
                                    },
                                    maxLength: 15,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () async {
                  controller.validateId(controller.idController.text);
                },
                child: Container(
                  width: 350.w,
                  height: 50.h,
                  margin: EdgeInsets.only(bottom: 34.h, top: 20.h, left: 20.w, right: 20.w),
                  padding: EdgeInsets.all(15.r),
                  decoration: ShapeDecoration(
                    color: Theme
                        .of(Get.context!)
                        .colorScheme
                        .primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '다음',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          height: 0,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  // _validator(String value) {
  //   // 영문 숫자 조합 및 인스타그램 정규식
  //   RegExp regExp = RegExp(r'^[a-zA-Z0-9_]*$');
  //   if (regExp.hasMatch(value)) {
  //     _isIdDuplicated.value = true;
  //   } else {
  //     _isIdDuplicated.value = false;
  //     AppLog.to.e('아이디 정규식 불일치: $value');
  //   }
  // }

}
