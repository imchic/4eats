import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foreats/screens/login/user_store.dart';
import 'package:foreats/utils/dialog_util.dart';
import 'package:get/get.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart' as kakao;
import 'package:logger/logger.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lottie/lottie.dart';

import '../../home/home_controller.dart';
import '../../model/user_model.dart';
import '../../utils/app_routes.dart';
import '../../utils/colors.dart';
import '../../utils/global_alert_dialog.dart';
import '../../utils/logger.dart';

class LoginController extends GetxController {
  
  static LoginController get to => Get.find();

  final RxBool _isLogin = false.obs;
  bool get isLogin => _isLogin.value;

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

  Rx<UserModel> userModel = UserModel().obs;

  get user => userModel.value;
  var auth = FirebaseAuth.instance;

  @override
  void onInit() {
    super.onInit();
    checkLogin();
  }

  /// 사용자 로그인 체크 여부
  Future<void> checkLogin() async {
    try {
      final User? user = auth.currentUser;

      if (user != null) {
        AppLog.to.i('사용자 로그인 여부: ${user.email}');
        // UserStore.to.removeSharedPref();
        // UserStore.to.setLoginStatus(false);
      }

    } catch (e) {
      AppLog.to.e('사용자 로그인 여부: $e');
      UserStore.to.removeSharedPref();
      UserStore.to.setLoginStatus(false);
      UserStore.to.setLoginType('');
    }
  }

  /// 구글 로그인
  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser!.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 파이어베이스 로그인
      final UserCredential userCredential =
          await auth.signInWithCredential(credential);

      // birthdate
      final User? user = userCredential.user;

      var phoneNumber = user!.phoneNumber;
      var email = user.email;
      var displayName = user.displayName;
      var photoURL = user.photoURL;
      var uid = user.uid;
      var birthdate = user.metadata.creationTime;

      AppLog.to.i('phoneNumber: $phoneNumber');
      AppLog.to.i('email: $email');
      AppLog.to.i('displayName: $displayName');
      AppLog.to.i('photoURL: $photoURL');
      AppLog.to.i('uid: $uid');

      final fcmToken = await FirebaseMessaging.instance.getToken();
      AppLog.to.i('fcmToken: $fcmToken');

      userModel.value = UserModel(
        uid: user.uid,
        id: '',
        displayName: user.displayName,
        email: user.email,
        point: '0',
        accessToken: googleAuth.accessToken,
        refreshToken: googleAuth.idToken,
        fcmToken: fcmToken,
        photoUrl: user.photoURL,
        loginType: 'google',
        createdAt: Timestamp.now().toDate(),
        updatedAt: Timestamp.now().toDate(),
      );

      AppLog.to.i(
          'signInWithGoogle: ${user.displayName} ${user.email} ${user.photoURL}, ${googleAuth.accessToken}');

      // 회원정보가 존재하는지 여부 확인
      await UserStore.to.checkUserExist(userModel.value.email!);

      _clickType.value = 'google';

      await checkLoginRedirect();

    } catch (e) {
      AppLog.to.e('signInWithGoogle error: $e');
    }
  }

  /// 로그인 리다이렉트
  Future<void> checkLoginRedirect() async {
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

      await auth.signInWithCredential(credential);

      if (auth.currentUser != null) {
        AppLog.to.i('카카오톡 로그인 성공');
      } else {
        AppLog.to.e('카카오톡 로그인 실패');
      }

      var currentUser = auth.currentUser;
      userModel.value = UserModel(
        uid: currentUser!.uid,
        displayName: currentUser.displayName,
        email: currentUser.email,
        point: '0',
        accessToken: token.accessToken,
        refreshToken: token.refreshToken,
        fcmToken: await FirebaseMessaging.instance.getToken(),
        photoUrl: currentUser.photoURL,
        loginType: 'kakao',
        createdAt: Timestamp.now().toDate(),
        updatedAt: Timestamp.now().toDate(),
      );


      // await UserStore.to.checkUserExist(userModel.email!);
      _clickType.value = 'kakao';

      // 로그인 리다이렉트
      await checkLoginRedirect();
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

  /// 로그아웃
  Future<void> logout() async {
    try {
      AppLog.to.i('loginController > ${UserStore.to.userProfile.toJson()}');

      if (UserStore.to.userProfile.loginType == 'google') {
        await auth.signOut();
        await GoogleSignIn().signOut();
        UserStore.to.removeSharedPref();
        UserStore.to.setLoginStatus(false);

        HomeController.to.moveToPage(0);
        await Get.offAllNamed(AppRoutes.home);

      } else {
        // 카카오 로그아웃
        var logout = await kakao.UserApi.instance.logout();
        AppLog.to.i('logout ::: $logout');
        // await kakao.UserApi.instance.unlink();

        UserStore.to.removeSharedPref();
        UserStore.to.setLoginStatus(false);
        UserStore.to.setLoginType('');

        HomeController.to.moveToPage(0);
        await Get.offAllNamed(AppRoutes.home);

      }

    } catch (e) {
      AppLog.to.e('signOut error: $e');
    }
  }

  Future<void> temp() async {
    try {
      var type = await UserStore.to.getLoginType();
      AppLog.to.e(type);
    } catch (e) {
      AppLog.to.e('signOut error: $e');
    }
  }

  // 회원탈퇴
  Future<void> withdrawal() async {
    try {

      await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: UserStore.to.userProfile.email).get().then((QuerySnapshot<Map<String, dynamic>> snapshot) {
        snapshot.docs.forEach((doc) {
          userModel.value = UserModel.fromJson(doc.data());
          AppLog.to.w('userModel: ${userModel.value.toString()}');

          GlobalAlertDialog.confirmDialog(Get.context!, '회원탈퇴', '정말로 탈퇴하시겠습니까?', () async {

            await FirebaseFirestore.instance.collection('users').where('email', isEqualTo: userModel.value.email).get().then((value) {
              value.docs.forEach((element) async {
                await element.reference.delete();
                await auth.currentUser!.delete();
                await GoogleSignIn().signOut();
                UserStore.to.removeSharedPref();
                UserStore.to.setLoginStatus(false);
                UserStore.to.setLoginType('');
                Get.offAllNamed(AppRoutes.home);
              });
            });

          //   // 구글 사용자 탈퇴
          //   if (UserStore.to.loginType == 'google') {
          //     await auth.currentUser!.delete();
          //     await GoogleSignIn().signOut();
          //     await FirebaseFirestore.instance.collection('users').doc(userModel.value.uid).get().then((doc) {
          //       AppLog.to.i('doc: ${doc.data()}');
          //       doc.reference.delete();
          //     });
          //     UserStore.to.removeSharedPref();
          //     UserStore.to.setLoginStatus(false);
          //     UserStore.to.setLoginType('');
          //     Get.offAllNamed(AppRoutes.home);
          //   } else {
          //     // 카카오 사용자 탈퇴
          //     await kakao.UserApi.instance.unlink();
          //     await FirebaseFirestore.instance.collection('users').doc(userModel.value.uid).get().then((doc) {
          //       doc.reference.delete();
          //     });
          //     UserStore.to.removeSharedPref();
          //     UserStore.to.setLoginStatus(false);
          //     UserStore.to.setLoginType('');
          //     Get.offAllNamed(AppRoutes.home);
          //   }

          });

      });
    });

    } catch (e) {
      AppLog.to.e('withdrawal error: $e');
    }
  }

}
