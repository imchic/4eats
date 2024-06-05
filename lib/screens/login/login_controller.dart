import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foreats/screens/login/user_store.dart';
import 'package:foreats/utils/dialog_util.dart';
import 'package:get/get.dart';
import 'package:googleapis/admob/v1.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart' as kakao;
import 'package:logger/logger.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../home/home_controller.dart';
import '../../model/user_model.dart';
import '../../utils/app_routes.dart';
import '../../utils/colors.dart';
import '../../utils/global_alert_dialog.dart';
import '../../utils/logger.dart';

class LoginController extends GetxController {
  
  static LoginController get to => Get.find();

  final RxString _clickType = ''.obs;
  final RxString _accessToken = ''.obs;
  final RxString _email = ''.obs;
  final RxString _id = ''.obs;
  final RxString _nickname = ''.obs;
  final RxString _profileImage = ''.obs;
  final RxInt _count = 0.obs;

  String get accessToken => _accessToken.value;
  String get email => _email.value;
  String get id => _id.value;
  String get nickname => _nickname.value;
  String get profileImage => _profileImage.value;
  int get count => _count.value;

  final _firebase = FirebaseAuth.instance;
  Rx<UserModel> userModel = UserModel().obs;

  get user => userModel.value;

  @override
  Future<void> onInit() async {
    super.onInit();
    await UserStore.to.init();
  }

  /// 구글 로그인
  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 파이어베이스 로그인
      final UserCredential userCredential =
          await _firebase.signInWithCredential(credential);

      // birthdate
      final User? user = userCredential.user;
      //final fcmToken = await FirebaseMessaging.instance.getToken();

      // android os일 경우
      //final fcmToken = await FirebaseMessaging.instance.getToken();

      // ios os일 경우
      //final iosToken = await FirebaseMessaging.instance.getAPNSToken();

      // 플랫폼 별 토큰 가져오기
      String? fcmToken = '';
      // if(defaultTargetPlatform == TargetPlatform.iOS) {
      //   fcmToken = await FirebaseMessaging.instance.getAPNSToken();
      // } else if(defaultTargetPlatform == TargetPlatform.android) {
        fcmToken = await FirebaseMessaging.instance.getToken();
      // }

      var currentUser = _firebase.currentUser;
      userModel.value = UserModel(
        uid: user?.uid ?? '',
        id: '',
        displayName: user?.displayName,
        email: user?.email,
        point: '0',
        accessToken: googleAuth.accessToken,
        refreshToken: googleAuth.idToken,
        fcmToken: fcmToken,
        profileImage: user?.photoURL,
        loginType: 'google',
        createdAt: Timestamp.now().toDate(),
        updatedAt: Timestamp.now().toDate(),
      );

      AppLog.to.i('userModel: ${userModel.toString()}');

      var userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser?.uid)
          .get();

      if (userSnapshot.exists) {
        AppLog.to.i('userSnapshot: ${userSnapshot.data()}');
        userModel.value = UserModel.fromJson(userSnapshot.data()!);
        signIn(userModel.value);
      } else {
        Get.toNamed(AppRoutes.registerNickname, arguments: userModel.value);
      }

    } catch (e) {
      AppLog.to.e('signInWithGoogle error: $e');
    }
  }

  /// 카카오 로그인
  Future<void> signInWithKakao() async {
    try {
      final isKakaoTalkInstalled = await kakao.isKakaoTalkInstalled();

      AppLog.to.i('카카오톡 설치여부 > $isKakaoTalkInstalled');

      kakao.OAuthToken token;

      if(isKakaoTalkInstalled) {
        token = await kakao.UserApi.instance.loginWithKakaoTalk();
      } else {
        token = await kakao.UserApi.instance.loginWithKakaoAccount();
      }

      var provider = OAuthProvider('oidc.eat');
      var credential = provider.credential(
          idToken: token.idToken,
          accessToken: token.accessToken
      );

      await _firebase.signInWithCredential(credential);

      if (_firebase.currentUser != null) {
        AppLog.to.i('카카오톡 로그인 성공');
      } else {
        AppLog.to.e('카카오톡 로그인 실패');
      }

      var currentUser = _firebase.currentUser;
      userModel.value = UserModel(
        uid: currentUser!.uid,
        displayName: currentUser.displayName,
        email: currentUser.email,
        point: '0',
        accessToken: token.accessToken,
        refreshToken: token.refreshToken,
        fcmToken: await FirebaseMessaging.instance.getToken(),
        profileImage: currentUser.photoURL,
        loginType: 'kakao',
        createdAt: Timestamp.now().toDate(),
        updatedAt: Timestamp.now().toDate(),
      );

      AppLog.to.i('userModel: ${userModel.toString()}');

      var userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (userSnapshot.exists) {
        AppLog.to.i('userSnapshot: ${userSnapshot.data()}');
        userModel.value = UserModel.fromJson(userSnapshot.data()!);
        // 기존 로그인
        signIn(userModel.value);
      } else {
        Get.toNamed(AppRoutes.registerNickname, arguments: userModel.value);
      }

    } catch (e) {
      AppLog.to.e('kakao login error $e');

      // account already exists
      if (e.toString().contains('account-exists-with-different-credential')) {

        // me
        final kakao.User kakaoUser = await kakao.UserApi.instance.me();
        // email
        final email = kakaoUser.kakaoAccount!.email;

        DialogUtil.accountExistsWithDifferentCredential(
          email: email ?? '',
          onConfirm: () {
            // 로그아웃
            Get.back();
          },
        );
      }

    }
  }

  /// 로그인 리다이렉트
  /*Future<void> checkLoginRedirect() async {
    if (UserStore.to.isExist.value) {

      AppLog.to.i('isExist: ${UserStore.to.isExist.value}');

      // snapshot
      await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: UserStore.to.userProfile.email)
          .get()
          .then((QuerySnapshot<Map<String, dynamic>> snapshot) {
        snapshot.docs.forEach((doc) {
          AppLog.to.i('doc: ${doc.data()}');
          userModel.value = UserModel.fromJson(doc.data());

          var clickType = _clickType.value;
          var getLoginType = doc.data()['loginType'];

          AppLog.to.i('clickType: $clickType');
          AppLog.to.i('getLoginType: $getLoginType');

        if(clickType != getLoginType){
          DialogUtil.accountExistsWithDifferentCredential(
            email: email ?? '',
            onConfirm: () {
              // 로그아웃
              Get.back();
            },
          );
          return;
          } else {
            // 구글 로그인
            var auth = FirebaseAuth.instance;
            auth.signInWithCredential(GoogleAuthProvider.credential(
              accessToken: userModel.value.accessToken,
              idToken: userModel.value.refreshToken,
            ));
            UserStore.to.setSharedPref(UserModel.fromJson(doc.data()));
            UserStore.to.setLoginStatus(true);
            Get.offAllNamed(AppRoutes.home);
          }
        });
      });
    } else {
      Get.toNamed(AppRoutes.registerNickname);
    }
  }*/

  /// 회원가입 정보 저장
  Future<void> signIn(UserModel value) async {
    try {

      // 파이어베이스 유저정보 저장
      await FirebaseFirestore.instance.collection('users').doc(value.uid).set(value.toJson());

      // 로그인 상태 변경
      UserStore.to.setLoginStatus(true);

      // 로그인 성공
      Get.offAllNamed(AppRoutes.home);


    } catch (e) {
      AppLog.to.e('signIn error: $e');
    }
  }

  /// 로그아웃
  Future<void> logout() async {
    try {

      // 로그아웃
      await _firebase.signOut();

      // 로그인 상태 변경
      UserStore.to.setLoginStatus(false);

      // 로그아웃 성공
      Get.offAllNamed(AppRoutes.home);
      HomeController.to.moveToPage(0);

    } catch (e) {
      AppLog.to.e('signOut error: $e');
    }
  }

  Future<void> temp() async {
    try {

    } catch (e) {
      AppLog.to.e('signOut error: $e');
    }
  }


}
