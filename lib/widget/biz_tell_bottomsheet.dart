import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../screens/biz/biz_controller.dart';
import '../utils/colors.dart';
import '../utils/text_style.dart';

class BizTellBottomSheet extends GetWidget {

  BizTellBottomSheet({super.key});
  
  final TextEditingController tellNumberController = TextEditingController();
  final TextEditingController verifyCodeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(
          top: 20.h,
          left: 20.w,
          right: 20.w,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20.h,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '전화번호 입력',
              style: TextStyleUtils.titleTextStyle(
                  fontSize: 18.sp
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              '번호 확인을 위해 일회용 인증번호를 발송해요 😁',
              style: TextStyleUtils.subTitleTextStyle(
                fontSize: 10.sp,
                color: gray600,
              ),
            ),
            SizedBox(height: 10.h),
            TextField(
              controller: tellNumberController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                // 8자리
                LengthLimitingTextInputFormatter(11),
              ],
              decoration: InputDecoration(
                hintText: '전화번호를 입력해주세요',
                hintStyle: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.grey,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            ),
            SizedBox(height: 20.h),
            ElevatedButton(
              onPressed: () {
                BizController.to.verifyPhoneNumber(tellNumberController.text);
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              child: Container(
                width: Get.width,
                height: 50.h,
                alignment: Alignment.center,
                child: Text(
                  '인증번호 발송',
                  style: TextStyleUtils.whiteTextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600
                  )
                ),
              ),
            ),
            Obx(() {
              return Visibility(
                visible: BizController.to.isVerify.value,
                child: Column(
                  children: [
                    SizedBox(height: 20.h),
                    TextField(
                      controller: verifyCodeController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                        // 8자리
                        LengthLimitingTextInputFormatter(6),
                      ],
                      decoration: InputDecoration(
                        hintText: '인증번호를 입력해주세요',
                        hintStyle: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.grey,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    ElevatedButton(
                      onPressed: () {
                        // 인증번호 확인
                        BizController.to.verifyCode(verifyCodeController.text);
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                      child: Container(
                        width: Get.width,
                        height: 50.h,
                        alignment: Alignment.center,
                        child: Text(
                          '인증번호 확인',
                          style: TextStyleUtils.whiteTextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600
                          )
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}