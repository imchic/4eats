import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foreats/screens/setting/setting_controller.dart';
import 'package:get/get.dart';

import '../../utils/colors.dart';
import '../../widget/base_appbar.dart';
import '../login/login_controller.dart';
import '../login/user_store.dart';

class SettingScreen extends GetView<SettingController> {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: BaseAppBar(
        title: '환경설정',
        leading: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _profileBody(context),
          ],
        ),
      ),
    );
  }

  Widget _profileBody(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          userInfo(context),
          group1(context),
          SizedBox(height: 10.h),
          group2(context),
          SizedBox(height: 10.h),
          group3(context),

          // 최하단
          SizedBox(height: 10.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  child: TextButton(
                    onPressed: () {
                      //_logger.d('앱정보');
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            //tr('my_page_app_info'),
                            '앱 정보',
                            style: TextStyle(
                              color: Get.isDarkMode ? Colors.white : Colors.black,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              height: 0,
                            ),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Text(
                          'v1.0.0',
                          style: TextStyle(
                            color: textUnselected,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400,
                            height: 0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 앱 로고
          Container(
            width: 1.sw,
            height: Get.height * 0.3,
            padding: EdgeInsets.symmetric(vertical: 10.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/ic_foreat_logo.png',
                  width: 40.w,
                  height: 40.h,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 사용자 정보
  Widget userInfo(BuildContext context) {
    return Container(
      width: 390.w,
      padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 16.h, bottom: 16.h),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CachedNetworkImage(
            imageUrl: UserStore.to.user.value.profileImage ?? '',
            imageBuilder: (context, imageProvider) => Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            placeholder: (context, url) => Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[200],
              ),
            ),
            errorWidget: (context, url, error) => Container(
              width: 44.w,
              height: 44.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[200],
              ),
              child: Icon(
                Icons.error,
                color: Colors.red,
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  UserStore.to.user.value.nickname ?? '',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onBackground,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    height: 0,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  '@${UserStore.to.user.value.id}',
                  style: TextStyle(
                    color: textUnselected,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    height: 0,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 14.w),
          Container(
            width: 20.w,
            height: 20.h,
            padding: EdgeInsets.symmetric(vertical: 5.h),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.arrow_forward_ios,
                  color: textUnselected,
                  size: 14.sp,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget group1(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(width: 0.3, color: gray300),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            child: TextButton(
              onPressed: () {},
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      '프로필',
                      style: TextStyle(
                        color: Get.isDarkMode ? Colors.white : Colors.black,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        height: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          /*SizedBox(
            width: 390.w,
            height: 56.h,
            child: TextButton(
              onPressed: () {
                //Get.toNamed(AppRoute.changePassword);
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      //tr('my_page_account_password_change'),
                      '비밀번호 변경',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onBackground,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        height: 0,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: textUnselected,
                    size: 14.sp,
                  ),
                ],
              ),
            ),
          ),*/
          SizedBox(
            child: TextButton(
              onPressed: () {
                Get.dialog(
                  AlertDialog(
                    title: Text('로그아웃'),
                    content: Text('로그아웃 하시겠습니까?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Get.back();
                        },
                        child: Text('취소'),
                      ),
                      TextButton(
                        onPressed: () {
                          LoginController.to.logout();
                          //Get.back();
                        },
                        child: Text('확인'),
                      ),
                    ],
                  ),
                );
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      //tr('my_page_account_logout'),
                      '로그아웃',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onBackground,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        height: 0,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: textUnselected,
                    size: 14.sp,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            child: TextButton(
              onPressed: () {
                //_logger.d('회원탈퇴');
                //Get.toNamed(AppRoutes.deleteAccount);
                //LoginController.to.withdrawal();
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      //tr('my_page_account_delete'),
                      '회원탈퇴',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onBackground,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        height: 0,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: textUnselected,
                    size: 14.sp,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget group2(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(width: 0.3, color: gray300),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            child: TextButton(
              onPressed: () {
                //_logger.d('앱정보');
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      //tr('my_page_app_info'),
                      '앱 정보',
                      style: TextStyle(
                        color: Get.isDarkMode ? Colors.white : Colors.black,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        height: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          /*SizedBox(
            width: 390.w,
            height: 56.h,
            child: TextButton(
              onPressed: () {
                //_logger.d('공지사항');
                //Get.toNamed(AppRoute.notice);
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      //tr('my_page_app_notice'),
                      '공지사항',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onBackground,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        height: 0,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: textUnselected,
                    size: 14.sp,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: 390.w,
            height: 56.h,
            child: TextButton(
              onPressed: () {
                //_logger.d('고객센터');
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      //tr('my_page_app_customer_center'),
                      '고객센터',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onBackground,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        height: 0,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: textUnselected,
                    size: 14.sp,
                  ),
                ],
              ),
            ),
          ),*/
          SizedBox(
            child: TextButton(
              onPressed: () {
                //_logger.d('이용약관');
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      //tr('my_page_app_user_agreement'),
                      '이용약관',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onBackground,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        height: 0,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: textUnselected,
                    size: 14.sp,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            child: TextButton(
              onPressed: () {
                //_logger.d('개인정보처리방침');
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      //tr('my_page_app_privacy_policy'),
                      '개인정보처리방침',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onBackground,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        height: 0,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: textUnselected,
                    size: 14.sp,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget group3(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            child: TextButton(
              onPressed: () {
                //_logger.d('설정');
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      //tr('my_page_setting'),
                      '설정',
                      style: TextStyle(
                        color: Get.isDarkMode ? Colors.white : Colors.black,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        height: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            child: TextButton(
              onPressed: () async {
                //_logger.d('앱 설정');
                // 언어 변경 bottom sheet
                /*Get.bottomSheet(
                  Container(
                    height: 120.h,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.background,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                'assets/images/ic_korean.svg',
                                width: 20.w,
                                height: 20.h,
                              ),
                              SizedBox(width: 10.w),
                              Text('한국어',
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onBackground,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                    height: 0,
                                  )),
                            ],
                          ),
                          onTap: () async {
                            // if (ConfigStore.to.locale.languageCode != 'ko') {
                            //   ConfigStore.to.setLocale(Locale('ko', 'KR'));
                            //   await context.setLocale(Locale('ko', 'KR'));
                            //   await EasyLocalization.ensureInitialized();
                            //   Phoenix.rebirth(context);
                            // } else {
                            //   Get.snackbar('알림', '이미 선택된 언어입니다.', duration: Duration(microseconds: 300));
                            // }
                            // ConfigStore.to.setLocale(Locale('ko', 'KR'));
                            // await context.setLocale(Locale('ko', 'KR'));
                            // await EasyLocalization.ensureInitialized();
                            // Phoenix.rebirth(context);
                          },
                        ),
                        ListTile(
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                'assets/images/ic_japan.svg',
                                width: 20.w,
                                height: 20.h,
                              ),
                              SizedBox(width: 10.w),
                              Text('日本語',
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onBackground,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                    height: 0,
                                  )),
                            ],
                          ),
                          onTap: () async {
                            // if (ConfigStore.to.locale.languageCode != 'ja') {
                            //   ConfigStore.to.setLocale(Locale('ja', 'JP'));
                            //   await context.setLocale(Locale('ja', 'JP'));
                            //   await EasyLocalization.ensureInitialized();
                            //   Phoenix.rebirth(context);
                            // } else {
                            //   Get.snackbar('알림', '이미 선택된 언어입니다.', duration: Duration(microseconds: 300));
                            // }
                            // ConfigStore.to.setLocale(Locale('ja', 'JP'));
                            // await context.setLocale(Locale('ja', 'JP'));
                            // await EasyLocalization.ensureInitialized();
                            // Phoenix.rebirth(context);
                          },
                        ),
                      ],
                    ),
                  ),
                );*/
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      //tr('my_page_setting_app_setting'),
                      '앱 설정',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onBackground,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        height: 0,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: textUnselected,
                    size: 14.sp,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
