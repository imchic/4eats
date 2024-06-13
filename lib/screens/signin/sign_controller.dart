import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:foreats/screens/login/login_controller.dart';
import 'package:get/get.dart';

import '../../utils/app_routes.dart';
import '../../utils/toast_controller.dart';
import '../login/user_store.dart';

class SignController extends GetxController {

  static SignController get to => Get.find();

  final _fireStore = FirebaseFirestore.instance;

  final TextEditingController nicknameController = TextEditingController();
  final TextEditingController idController = TextEditingController();
  final TextEditingController birthController = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxBool isIdChecked = false.obs;
  final RxBool isBirthDuplicated = false.obs;

  final RxString nickname = ''.obs;
  final RxString id = ''.obs;
  final RxString calculateAgeString = ''.obs;
  final RxString genderSelected = ''.obs;

  // void signIn() async {
  //   try {
  //     isLoading.value = true;
  //     // await authController.signIn(
  //     //   email: emailController.text,
  //     //   password: passwordController.text,
  //     // );
  //   } catch (e) {
  //     Get.snackbar(
  //       'Error',
  //       e.toString(),
  //       snackPosition: SnackPosition.BOTTOM,
  //     );
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }

  Future<void> checkNickname(String nickname) async {
    try {
      isLoading.value = true;
      _fireStore.collection('users').where('nickname', isEqualTo: nickname).get().then((value) {
        if (value.docs.isNotEmpty) {
         ToastController.to.showErrorToast('이미 사용중인 닉네임입니다.');
        } else {
          //ToastController.to.showToast('사용 가능한 닉네임입니다.');
          //LoginController.to.user.value.nickname = nickname;
          LoginController.to.userModel.value.nickname = nickname;
          Get.toNamed(AppRoutes.registerId);
        }
      });
    } catch (e) {
      ToastController.to.showErrorToast(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // checkId
  Future<void> checkId(String id) async {
    try {
      isLoading.value = true;
      _fireStore.collection('users').where('id', isEqualTo: id).get().then((value) {
        if (value.docs.isNotEmpty) {
          ToastController.to.showErrorToast('이미 사용중인 아이디입니다.');
        } else {
          //ToastController.to.showToast('사용 가능한 아이디입니다.');
          //UserStore.to.user.value.id = id;
          LoginController.to.userModel.value.id = id;
          isIdChecked.value = true;
          Get.toNamed(AppRoutes.registerBirth);
        }
      });
    } catch (e) {
      ToastController.to.showErrorToast(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // id validation
  Future<void> validateId(String id) async {
    try {
      isLoading.value = true;
      if (id.isEmpty) {
        ToastController.to.showErrorToast('아이디를 입력해주세요.');
      } else if (RegExp(r'[!@#<>?":_`~;[\]\\|=+)(*&^%0-9-]').hasMatch(id)) {
        ToastController.to.showErrorToast('아이디는 영문 또는 영문 숫자 조합만 가능합니다.');
      } else {
        checkId(id);
      }
    } catch (e) {
      ToastController.to.showErrorToast(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> validateBirth(String value ) async {
    if (value.isEmpty) {
      ToastController.to.showErrorToast('생년월일을 입력해주세요.');
    }
    if (value.length != 8) {
      ToastController.to.showErrorToast('생년월일은 8자리로 입력해주세요.');
    }
    if(int.tryParse(value.substring(0, 4)) == null) {
      ToastController.to.showErrorToast('생년월일은 숫자만 입력 가능합니다.');
    }
    if(int.tryParse(value.substring(4, 6)) == null) {
      ToastController.to.showErrorToast('생년월일은 숫자만 입력 가능합니다.');
    }
    if(int.tryParse(value.substring(6, 8)) == null) {
      ToastController.to.showErrorToast('생년월일은 숫자만 입력 가능합니다.');
    }
    if (value.length == 8) {
      int year = int.parse(value.substring(0, 4));
      int month = int.parse(value.substring(4, 6));
      int day = int.parse(value.substring(6, 8));
      DateTime now = DateTime.now();
      int age = now.year - year;
      if (now.month < month || (now.month == month && now.day < day)) {
        age--;
      }
      if (age < 14) {
        ToastController.to.showErrorToast('만 14세 이상 가입 가능합니다.');
      } else {
        //UserStore.to.user.value.birthdate = value;
        LoginController.to.userModel.value.birthdate = value;
        Get.toNamed(AppRoutes.registerGender);
      }
    }
  }

  // 한글만 입력되도록 제한
  String validateNickname(String value) {
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

  // 만 나이 계산
  String calculateAge(String value) {
    if (value.length == 8) {
      int year = int.parse(value.substring(0, 4));
      int month = int.parse(value.substring(4, 6));
      int day = int.parse(value.substring(6, 8));
      DateTime now = DateTime.now();
      int age = now.year - year;
      if (now.month < month || (now.month == month && now.day < day)) {
        age--;
      }
      return age.toString();
    }
    return '';
  }

}