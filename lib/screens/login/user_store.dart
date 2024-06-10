import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:foreats/utils/logger.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../model/user_model.dart';
import '../../utils/app_routes.dart';

class UserStore extends GetxController {
  static UserStore get to => Get.find();

  final Rx<UserModel> user = UserModel().obs;
  final RxBool isLogin = false.obs;

  // 최초 인스톨 여부 확인
  final RxBool isFirstInstall = true.obs;

  // 로그인 여부 확인
  final RxBool isLoginCheck = false.obs;

  // 로그인 시도 여부 확인
  final RxBool isLoginTry = false.obs;

  // 로그인 시도 중 메시지
  final RxString loginTryMessage = ''.obs;

  Future<SharedPreferences> get prefs => SharedPreferences.getInstance();

  final _firebaseAuth = FirebaseAuth.instance;


  Future<void> init() async {

    AppLog.to.d('init UserStore');

    prefs.then((value) {
      if(value.getBool('isFirstInstall') == null) {
        isFirstInstall.value = true;
      } else {
        isFirstInstall.value = false;
      }
      if(value.getBool('isLoginCheck') == null) {
        isLoginCheck.value = false;
      } else {
        isLoginCheck.value = value.getBool('isLoginCheck') ?? false;
      }

      AppLog.to.d('isFirstInstall: ${isFirstInstall.value}');
      AppLog.to.d('isLoginCheck: ${isLoginCheck.value}');
    });

    // current user
    final user = _firebaseAuth.currentUser;
    if(user != null) {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if(userDoc.exists) {
        final userModel = UserModel.fromJson(userDoc.data() as Map<String, dynamic>);

        // fcm Token 업데이트
        final prefs = await SharedPreferences.getInstance();
        final fcmToken = prefs.getString('fcmToken') ?? '';
        if(userModel.fcmToken != fcmToken) {

          await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
            'fcmToken': fcmToken,
          });
          userModel.fcmToken = fcmToken;
        }

        this.user.value = userModel;
      }
      AppLog.to.d('user: ${user.toString()}');
    }
  }

  /// 로그인 상태 저장
  Future<void> setLoginStatus(bool status) async {
    prefs.then((value) {
      value.setBool('isLoginCheck', status);
    });
  }

  /// 로그인 상태 가져오기
  Future<bool> getLoginStatus() async {
    var prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoginCheck') ?? false;
  }

  Future<void> checkFirstInstall() async {
    AppLog.to.d('checkFirstInstall');
    isFirstInstall.value = false;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isFirstInstall', false);
    Get.offAndToNamed(AppRoutes.home);
  }

  Future<void> login(String email, String password) async {
    isLoginTry.value = true;
    loginTryMessage.value = '로그인 중...';
    try {
      // 로그인 처리
      // 로그인 성공 시
      isLogin.value = true;
      isLoginCheck.value = true;
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool('isLoginCheck', true);
      prefs.setBool('isLoginTry', false);
      prefs.setString('uid', user.value.uid ?? '');
      loginTryMessage.value = '';
      Get.offAllNamed(AppRoutes.home);
    } catch (e) {
      // 로그인 실패 시
      isLogin.value = false;
      isLoginCheck.value = false;
      isLoginTry.value = false;
      loginTryMessage.value = '로그인 실패';
    }
  }

  Future<void> logout() async {
    isLogin.value = false;
    isLoginCheck.value = false;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLoginCheck', false);
    prefs.setBool('isLoginTry', false);
    prefs.remove('uid');
    Get.offAllNamed(AppRoutes.login);
  }

  Future<void> signUp(String email, String password) async {
    isLoginTry.value = true;
    loginTryMessage.value = '회원가입 중...';
    try {
      // 회원가입 처리
      // 회원가입 성공 시
      isLogin.value = true;
      isLoginCheck.value = true;
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool('isLoginCheck', true);
      prefs.setBool('isLoginTry', false);
      prefs.setString('uid', user.value.uid ?? '');
      loginTryMessage.value = '';
      Get.offAllNamed(AppRoutes.home);
    } catch (e) {
      // 회원가입 실패 시
      isLogin.value = false;
      isLoginCheck.value = false;
      isLoginTry.value = false;
      loginTryMessage.value = '회원가입 실패';
    }
  }

  Future<void> checkLogin() async {
    isLoginCheck.value = true;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLoginCheck', true);
  }

  Future<void> updateProfile(UserModel userModel) async {
    user.value = userModel;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('uid', user.value.uid ?? '');
  }

  Future<void> deleteProfile() async {
    user.value = UserModel();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('uid');
  }

  Future<void> updateProfileImage(String imageUrl) async {
    user.update((val) {
      val!.profileImage = imageUrl;
    });
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('uid', user.value.uid ?? '');
  }

  Future<void> deleteProfileImage() async {
    user.update((val) {
      val!.profileImage = '';
    });
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('uid', user.value.uid ?? '');
  }
}
