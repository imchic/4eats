import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foreats/screens/login/user_store.dart';
import 'package:foreats/utils/logger.dart';

import 'package:get/get.dart';
import '../../model/user_model.dart';
import '../../utils/app_routes.dart';
import '../../utils/colors.dart';
import '../../utils/global_toast_controller.dart';
import '../../widget/base_appbar.dart';

class RegisterNicknameScreen extends StatefulWidget {
  const RegisterNicknameScreen({super.key});

  @override
  State<RegisterNicknameScreen> createState() => _RegisterNicknameScreen();
}

class _RegisterNicknameScreen extends State<RegisterNicknameScreen> {

  late final TextEditingController _nickNameController = TextEditingController();
  final _nickName = ''.obs;

  @override
  void initState() {
    super.initState();

    Get.put(GlobalToastController());

    var args = Get.arguments;
    if (args != null) {
      UserStore.to.user.value = args;
    }

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
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
                              color: Theme.of(context).colorScheme.secondary,
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
                              controller: _nickNameController,
                              onChanged: (value) {
                                _nickName.value = _nickNameController.text;
                              },
                              decoration: InputDecoration(
                                hintText: '닉네임 입력',
                                hintStyle: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  color: gray600,
                                ),
                                suffix: GestureDetector(
                                  onTap: () {
                                    _nickNameController.clear();
                                    setState(() {
                                      _nickNameController.text = '';
                                    });
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
                  if (_nickNameController.text.length < 3) {
                    GlobalToastController.to.showToast('닉네임은 3자 이상 입력해주세요.');
                    return;
                  } else if (_validateNickname(_nickNameController.text).isNotEmpty) {
                    // 한글만 입력되도록 제한
                    GlobalToastController.to.showToast('닉네임은 한글만 입력 가능합니다.');
                  }
                  else {
                    UserStore.to.user.value.nickname = _nickNameController.text;
                    AppLog.to.i('nickname: ${UserStore.to.user.value.nickname}');
                    Get.toNamed(AppRoutes.registerId);
                  }
                },
                child: Container(
                  width: 350.w,
                  height: 50.h,
                  margin: EdgeInsets.only(
                      bottom: 34.h, top: 20.h, left: 20.w, right: 20.w),
                  padding: EdgeInsets.all(15.r),
                  decoration: ShapeDecoration(
                    color: Theme.of(context).colorScheme.primary,
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

  // 한글만 입력되도록 제한
  String _validateNickname(String value) {
    if (value.isEmpty) {
      return '닉네임을 입력해주세요.';
    }
    // 특수문자 제한
    if (RegExp(r'[!@#<>?":_`~;[\]\\|=+)(*&^%0-9-]').hasMatch(value)) {
      return '닉네임은 한글만 입력 가능합니다.';
    }
    // 공백
    if (RegExp(r'\s').hasMatch(value)) {
      return '닉네임에 공백은 사용할 수 없습니다.';
    }
    // 3자 이상 입력
    if (value.length < 3) {
      return '닉네임은 3자 이상 입력해주세요.';
    }
    // 20자 이하 입력
    if (value.length > 20) {
      return '닉네임은 20자 이하로 입력해주세요.';
    }
    return '';
  }

}
