import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foreats/screens/signin/sign_controller.dart';
import 'package:get/get.dart';
import '../../utils/colors.dart';
import '../../utils/logger.dart';
import '../../utils/toast_controller.dart';
import '../../widget/base_appbar.dart';
import '../login/login_controller.dart';
import '../login/user_store.dart';

class RegisterGenderScreen extends GetView<SignController> {
  @override
  Widget build(BuildContext context) {
    Get.put(ToastController());

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
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
                            width: 350.w * 1,
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
                            '성별을 선택해주세요.',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                              height: 1.5,
                            ),
                          ),
                          SizedBox(height: 2.5.h),
                          Text(
                            '성별은 나중에 변경할 수 없습니다. \n데이터 분석 및 서비스 제공을 위해 사용됩니다.',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w400,
                              color: gray600,
                              height: 1.5,
                            ),
                          ),
                          // round shape decoration textfield
                          SizedBox(height: 20.h),

                          // 성별 선택
                          Obx(
                                () => Container(
                              width: Get.width,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 4.w, vertical: 10.h),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // 남성
                                  GestureDetector(
                                    onTap: () {
                                      // 남성 선택
                                      AppLog.to.d('남성 선택');
                                      //controller.genderSelected.value = '남성';
                                      controller.genderSelected.value = '남성';
                                    },
                                    child: SizedBox(
                                      width: 150.w,
                                      child: Card(
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(10.r),
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                          MainAxisAlignment.center,
                                          crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              padding: EdgeInsets.all(4.r),
                                              child: Image.asset(
                                                'assets/images/ic_eating_man.png',
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            SizedBox(height: 10.h),
                                            Container(
                                              width: 40.w,
                                              padding: EdgeInsets.all(4.r),
                                              // border color
                                              decoration: ShapeDecoration(
                                                // color: controller.genderSelected.value ==
                                                //     '남성'
                                                //     ? Theme.of(context)
                                                //     .colorScheme
                                                //     .primary
                                                //     : Colors.white,
                                                color: controller.genderSelected.value ==
                                                    '남성'
                                                    ? Theme.of(Get.context!)
                                                    .colorScheme
                                                    .primary
                                                    : Colors.white,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                  BorderRadius.circular(
                                                      10.r),
                                                  side: BorderSide(
                                                    color:
                                                    // controller.genderSelected.value ==
                                                    //     '남성'
                                                    //     ? Colors.white
                                                    //     : Theme.of(context)
                                                    //     .colorScheme
                                                    //     .primary,
                                                    controller.genderSelected.value ==
                                                        '남성'
                                                        ? Colors.white
                                                        : Theme.of(Get.context!)
                                                        .colorScheme
                                                        .primary,
                                                    width: 1,
                                                  ),
                                                ),
                                              ),
                                              child: Text(
                                                '남성',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color:
                                                  // controller.genderSelected.value ==
                                                  //     '남성'
                                                  //     ? Colors.white
                                                  //     : gray500,
                                                  // fontSize: 12.sp,
                                                  // fontWeight: FontWeight.w700,
                                                  // height: 0,
                                                  controller.genderSelected.value ==
                                                      '남성'
                                                      ? Colors.white
                                                      : gray500,
                                                  fontSize: 12.sp,
                                                  fontWeight: FontWeight.w700,
                                                  height: 0,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),

                                  SizedBox(width: 10.w),

                                  // 여성
                                  GestureDetector(
                                    onTap: () {
                                      // 여성 선택
                                      AppLog.to.d('여성 선택');
                                      //controller.genderSelected.value = '여성';
                                      controller.genderSelected.value = '여성';
                                    },
                                    child: SizedBox(
                                      width: 150.w,
                                      child: Card(
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(10.r),
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                          MainAxisAlignment.center,
                                          crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              padding: EdgeInsets.all(4.r),
                                              child: Image.asset(
                                                'assets/images/ic_eating_women.png',
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            SizedBox(height: 10.h),
                                            Container(
                                              width: 40.w,
                                              padding: EdgeInsets.all(4.r),
                                              decoration: ShapeDecoration(
                                                color:
                                                controller.genderSelected.value ==
                                                    '여성'
                                                    ? Theme.of(Get.context!)
                                                    .colorScheme
                                                    .primary
                                                    : Colors.white,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                  BorderRadius.circular(
                                                      10.r),
                                                  side: BorderSide(
                                                    color:
                                                    controller.genderSelected.value ==
                                                        '여성'
                                                        ? Colors.white
                                                        : Theme.of(Get.context!)
                                                        .colorScheme
                                                        .primary,
                                                    width: 1,
                                                  ),
                                                ),
                                              ),
                                              child: Text(
                                                '여성',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color:
                                                  controller.genderSelected.value ==
                                                      '여성'
                                                      ? Colors.white
                                                      : gray500,
                                                  fontSize: 12.sp,
                                                  fontWeight: FontWeight.w700,
                                                  height: 0,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
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
                  if (controller.genderSelected.value.isEmpty) {
                    ToastController.to.showToast('성별을 선택해주세요.');
                    return;
                  } else {
                    var genderValue = '';

                    if (controller.genderSelected.value == '남성') {
                      genderValue = 'M';
                    } else {
                      genderValue = 'F';
                    }

                    LoginController.to.userModel.value.gender = genderValue;
                    LoginController.to
                        .signIn(LoginController.to.userModel.value);
                  }
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
                        '완료',
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
