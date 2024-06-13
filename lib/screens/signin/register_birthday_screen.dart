import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foreats/screens/signin/sign_controller.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:logger/logger.dart';
import '../../utils/app_routes.dart';
import '../../utils/colors.dart';
import '../../utils/toast_controller.dart';
import '../../utils/logger.dart';
import '../../widget/base_appbar.dart';
import '../login/login_controller.dart';
import '../login/user_store.dart';

class RegisterBirthScreen extends GetView<SignController> {
  const RegisterBirthScreen({super.key});

  @override
  Widget build(BuildContext context) {

    Get.put(ToastController());

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
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
                            width: 350.w * 0.65,
                            height: 10.h,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.r),
                              color: Theme.of(Get.context!).colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Container(
                      width: 350.w,
                      margin: EdgeInsets.only(bottom: 20.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '생년월일을 입력해주세요.',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                              height: 1.5,
                            ),
                          ),
                          SizedBox(height: 2.5.h),
                          Text(
                            '${AppRoutes.baseAppName}에서 사용할 생년월일을 입력해주세요. \n데이터 분석 및 서비스 제공을 위해 사용됩니다.',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w400,
                              color: gray600,
                              height: 1.5,
                            ),
                          ),
                          // round shape decoration textfield
                          SizedBox(height: 20.h),
                          // 만나이 표출
                          Obx(() {
                            //_calculateAgeString.value = '${_calculateAge(_birthController.text)}';
                            controller.calculateAgeString.value = controller.calculateAge(controller.birthController.text);
                            return RichText(
                              text: TextSpan(
                                text: '만 ',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                  height: 1.5,
                                ),
                                children: <TextSpan>[
                                  TextSpan(
                                    //text: '${_calculateAgeString.value}',
                                    text: controller.calculateAgeString.value,
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(Get.context!).colorScheme.secondary,
                                      height: 1.5,
                                    ),
                                  ),
                                  TextSpan(
                                    text: '세',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                          // textfield set height
                          Container(
                            child: TextField(
                              controller: controller.birthController,
                              onChanged: (value) {
                                // _validateBirthday(value);
                                // _calculateAgeString.value = '만 ${_calculateAge(value)}세';
                                controller.calculateAgeString.value = '만 ${controller.calculateAge(value)}세';
                              },
                              decoration: InputDecoration(
                                hintText: '생년월일 입력 (예: 19900101)',
                                hintStyle: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  color: gray600,
                                ),
                                suffix: GestureDetector(
                                  onTap: () {
                                    controller.birthController.clear();
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
                                counterStyle: TextStyle(
                                  fontSize: 10.sp,
                                  color: gray600,
                                ),
                              ),
                              maxLength: 8,
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
                  controller.validateBirth(controller.birthController.text);
                },
                child: Container(
                  width: 350.w,
                  height: 50.h,
                  margin: EdgeInsets.only(
                      bottom: 34.h, top: 20.h, left: 20.w, right: 20.w),
                  padding: EdgeInsets.all(15.r),
                  decoration: ShapeDecoration(
                    color: Theme.of(Get.context!).colorScheme.primary,
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

}

