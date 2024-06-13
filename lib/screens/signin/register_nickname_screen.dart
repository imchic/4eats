import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import '../../model/user_model.dart';
import '../../utils/app_routes.dart';
import '../../utils/colors.dart';
import '../../utils/toast_controller.dart';
import '../../utils/logger.dart';
import '../../widget/base_appbar.dart';
import '../login/user_store.dart';
import 'sign_controller.dart';

class RegisterNicknameScreen extends GetView<SignController> {
  const RegisterNicknameScreen({super.key});

  @override
  Widget build(BuildContext context) {

    Get.put(SignController());

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: BaseAppBar(
        title: '회원가입',
        leading: true,
        callback: () {
          UserStore.to.user.value = UserModel();
          Get.back();
        },
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
                            width: 350.w * 0.15,
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
                            '닉네임을 입력해주세요.',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                              height: 1.5,
                            ),
                          ),
                          SizedBox(height: 2.5.h),
                          Text(
                            '${AppRoutes.baseAppName}에서 사용할 이름이에요. \n다른 사람들에게 보여질 이름이니 신중하게 선택해주세요.\n7자 이상인 경우 잘려 보일 수 있어요.',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w400,
                              color: gray600,
                              height: 1.5,
                            ),
                          ),
                          // round shape decoration textfield
                          SizedBox(height: 20.h),
                          // textfield set height
                          Container(
                            child: TextField(
                              controller: controller.nicknameController,
                              onChanged: (value) {
                                controller.nickname.value = controller.nicknameController.text;
                              },
                              decoration: InputDecoration(
                                hintText: '닉네임 입력',
                                hintStyle: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  color: gray600,
                                ),
                                suffix: GestureDetector(
                                  onTap: () {
                                    controller.nicknameController.clear();
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
                              maxLength: 20,
                            ),
                          ),
                          //_buildErrorText(_validateId(_idController.text)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () async {
                  // 3자 이상 입력되도록 제한
                  if (controller.nicknameController.text.length < 3) {
                    ToastController.to.showToast('닉네임은 3자 이상 입력해주세요.');
                    return;
                  } else if (controller.validateNickname(controller.nicknameController.text).isNotEmpty) {
                    // 한글만 입력되도록 제한
                    ToastController.to.showToast('닉네임은 한글만 입력 가능합니다.');
                  }
                  else {
                    UserStore.to.user.value.nickname = controller.nicknameController.text;
                    AppLog.to.i('nickname: ${UserStore.to.user.value.nickname}');

                    await controller.checkNickname(controller.nicknameController.text);

                    //Get.toNamed(AppRoutes.registerId);
                  }
                },
                child: Container(
                  width: 350.w,
                  height: 50.h,
                  margin: EdgeInsets.only(bottom: 34.h, top: 20.h, left: 20.w, right: 20.w),
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
