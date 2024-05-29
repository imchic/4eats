import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:logger/logger.dart';
import '../../utils/app_routes.dart';
import '../../utils/colors.dart';
import '../../utils/global_toast_controller.dart';
import '../../utils/logger.dart';
import '../../widget/base_appbar.dart';
import '../login/login_controller.dart';
import '../login/user_store.dart';

class RegisterBirthScreen extends StatefulWidget {
  const RegisterBirthScreen({super.key});

  @override
  State<RegisterBirthScreen> createState() => _RegisterBirthScreen();
}

class _RegisterBirthScreen extends State<RegisterBirthScreen> {

  late final TextEditingController _birthController = TextEditingController();

  final RxBool _isBirthDuplicated = false.obs;
  final RxString _calculateAgeString = ''.obs;

  @override
  Widget build(BuildContext context) {

    Get.put(GlobalToastController());

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
                            _calculateAgeString.value = '${_calculateAge(_birthController.text)}';
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
                                    text: '${_calculateAgeString.value}',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context).colorScheme.secondary,
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
                              controller: _birthController,
                              onChanged: (value) {
                                _validateBirthday(value);
                                _calculateAgeString.value = '만 ${_calculateAge(value)}세';
                              },
                              decoration: InputDecoration(
                                hintText: '생년월일 입력 (예: 19900101)',
                                hintStyle: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  color: gray600,
                                ),
                                suffix: GestureDetector(
                                  onTap: () {
                                    _birthController.clear();
                                    setState(() {
                                      _birthController.text = '';
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
                              maxLength: 8,
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
                  if (_isBirthDuplicated.value) {
                    // 생년월일 저장
                    // LoginController.to.userModel.value.birthdate = _birthController.text;
                    // 만나이 저장
                    // LoginController.to.userModel.value.calculateBirthdate = _calculateAgeString.value;
                    // _logger.d('생년월일: ${LoginController.to.userModel.toString()}');
                    // Get.toNamed(AppRoutes.registerGender);

                    UserStore.to.user.value.birthdate = _birthController.text;
                    UserStore.to.user.value.calculateBirthdate = _calculateAgeString.value;
                    AppLog.to.d('생년월일: ${UserStore.to.user.value.birthdate}');
                    Get.toNamed(AppRoutes.registerGender);

                  } else {
                    GlobalToastController.to.showToast('생년월일을 입력해주세요.(숫자만 입력 가능)');
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

  // 숫자만 입력되도록 제한
  _validateBirthday(String value) {
    // 숫자만 입력되도록 제한
    if (value.isNotEmpty) {
      if (int.tryParse(value) == null) {
        _isBirthDuplicated.value = false;
      } else {
        _isBirthDuplicated.value = true;
      }
    }
  }

  // 만나이 계산
  int _calculateAge(String birth) {
    if (birth.length != 8) {
      return 0;
    }
    int year = int.parse(birth.substring(0, 4));
    int month = int.parse(birth.substring(4, 6));
    int day = int.parse(birth.substring(6, 8));
    DateTime now = DateTime.now();
    int age = now.year - year;
    if (now.month < month || (now.month == month && now.day < day)) {
      age--;
    }
    AppLog.to.d('만 나이: $age');
    return age;
  }

}
