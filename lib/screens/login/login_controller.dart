import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foreats/screens/login/user_store.dart';
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

class LoginController extends GetxController {
  static LoginController get to => Get.find();

  final Logger _logger = Logger(
    filter: null, // Use the default LogFilter (-> only log in debug mode)
    printer: PrettyPrinter(
      methodCount: 2,
      // number of method calls to be displayed
      errorMethodCount: 8,
      // number of method calls if stacktrace is provided
      lineLength: 120,
      // width of the output
      colors: true,
      // Colorful log messages
      printEmojis: true,
      // Print an emoji for each log message
      printTime: false, // Should each log print contain a timestamp
    ),
    output: null, // Use the default LogOutput (-> send everything to console)
  );

  //final dio.Dio _dio = dio.Dio();

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
        _logger.i('사용자 로그인 여부: ${user.email}');
        // UserStore.to.removeSharedPref();
        // UserStore.to.setLoginStatus(false);
      }

    } catch (e) {
      _logger.e('사용자 로그인 여부: $e');
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

      _logger.d('phoneNumber: $phoneNumber');
      _logger.d('email: $email');
      _logger.d('displayName: $displayName');
      _logger.d('photoURL: $photoURL');
      _logger.d('uid: $uid');

      final fcmToken = await FirebaseMessaging.instance.getToken();
      _logger.d('fcmToken: $fcmToken');

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

      _logger.i(
          'signInWithGoogle: ${user.displayName} ${user.email} ${user.photoURL}, ${googleAuth.accessToken}');

      // 회원정보가 존재하는지 여부 확인
      await UserStore.to.checkUserExist(userModel.value.email!);

      _clickType.value = 'google';

      await checkLoginRedirect();

    } catch (e) {
      _logger.e('signInWithGoogle error: $e');
    }
  }

  /// 로그인 리다이렉트
  Future<void> checkLoginRedirect() async {
    if (UserStore.to.isExist.value) {

      _logger.d('isExist: ${UserStore.to.isExist.value}');

      // snapshot
      await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: UserStore.to.userProfile.email)
          .get()
          .then((QuerySnapshot<Map<String, dynamic>> snapshot) {
        snapshot.docs.forEach((doc) {
          _logger.d('doc: ${doc.data()}');
          userModel.value = UserModel.fromJson(doc.data());

          var clickType = _clickType.value;
          var getLoginType = doc.data()['loginType'];

          _logger.d('clickType: $clickType');
          _logger.d('getLoginType: $getLoginType');

        if(clickType != getLoginType){
          Get.dialog(
            AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
              title: Text('중복된 로그인 정보', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp, color: Colors.black)),
              content:
              //Text('이미 가입된 이메일입니다 \n ${userModel.value.email} \n ${doc.data()['loginType']} 로 가입된 계정이 존재합니다.', style: TextStyle(fontSize: 14.sp, color: Colors.black)),
              Container(
                width: Get.width * 0.5,
                height: Get.height * 0.3,
                child: Column(
                  children: [
                    Lottie.asset('assets/lottie/id_already.json', width: 150.w, height: 150.h),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '이미 가입된 이메일입니다 \n',
                            style: TextStyle(fontSize: 14.sp, color: Colors.black),
                          ),
                          TextSpan(
                            text: maskEmail('${userModel.value.email} \n'),
                            style: TextStyle(fontSize: 14.sp, color: Theme.of(Get.context!).colorScheme.primary),
                          ),
                          TextSpan(
                              text: '${doc.data()['loginType']}로 가입된 계정이 존재합니다.',
                              style: TextStyle(fontSize: 12.sp, color: gray500)
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Get.back();
                    //Get.offAndToNamed(AppRoutes.home);
                  },
                  child: Text('확인', style: TextStyle(fontSize: 14.sp, color: Theme.of(Get.context!).colorScheme.primary)),
                ),
                TextButton(
                  onPressed: () {
                    Get.back();
                  },
                  child: Text('취소', style: TextStyle(fontSize: 14.sp, color: gray500)),
                ),
              ],
            ),
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

      _logger.d('카카오톡 설치여부 > $isKakaoTalkInstalled');

      final authCode = isKakaoTalkInstalled
          ? await kakao.UserApi.instance.loginWithKakaoTalk() //카카오 앱 로그인
          : await kakao.UserApi.instance.loginWithKakaoAccount(); //카카오 브라우저 로그인

      _logger.d('카카오톡 권한코드 > $authCode');

      var token = authCode.accessToken;

      kakao.User user = await kakao.UserApi.instance.me();
      _logger.d('카카오톡 유저정보 > $user');

      _accessToken.value = token;
      _email.value = user.kakaoAccount!.email!;
      _nickname.value = user.kakaoAccount!.profile!.nickname!;
      _profileImage.value = user.kakaoAccount!.profile!.profileImageUrl!;

      // userModel.value = UserModel(
      //   displayName: user.kakaoAccount!.profile!.nickname,
      //   email: user.kakaoAccount!.email,
      //   photoUrl: user.kakaoAccount!.profile!.profileImageUrl,
      //   accessToken: token,
      //   loginType: 'kakao',
      //   createdAt: Timestamp.now().toDate(),
      // );

      final fcmToken = await FirebaseMessaging.instance.getToken();

      userModel.value = UserModel(
        uid: '',
        id: '',
        displayName: user.kakaoAccount!.profile!.nickname,
        email: user.kakaoAccount!.email,
        point: '0',
        accessToken: token,
        refreshToken: '',
        fcmToken: fcmToken,
        photoUrl: user.kakaoAccount!.profile!.profileImageUrl,
        loginType: 'kakao',
        createdAt: Timestamp.now().toDate(),
        updatedAt: Timestamp.now().toDate(),
      );

      _logger.i(
          'signInWithKakao: ${user.kakaoAccount!.profile!.nickname} ${user.kakaoAccount!.email} ${user.kakaoAccount!.profile!.profileImageUrl}, $token');

      // 회원정보가 존재하는지 여부 확인
      await UserStore.to.checkUserExist(userModel.value.email!);

      _clickType.value = 'kakao';

      // 로그인 리다이렉트
      await checkLoginRedirect();
    } catch (e) {
      _logger.e('kakao login error $e');
    }
  }

  /// 로그아웃
  Future<void> logout() async {
    try {
      // _logger.d('loginController > ${UserStore.to.userProfile.toJson()}');

      if (UserStore.to.getLoginType() == 'google') {
        await auth.signOut();
        await GoogleSignIn().signOut();
        UserStore.to.removeSharedPref();
        UserStore.to.setLoginStatus(false);

        HomeController.to.moveToPage(0);
        await Get.offAllNamed(AppRoutes.home);

      } else {
        // 카카오 로그아웃
        var logout = await kakao.UserApi.instance.logout();
        _logger.d('logout ::: $logout');
        // await kakao.UserApi.instance.unlink();

        UserStore.to.removeSharedPref();
        UserStore.to.setLoginStatus(false);
        UserStore.to.setLoginType('');

        HomeController.to.moveToPage(0);
        await Get.offAllNamed(AppRoutes.home);

      }

    } catch (e) {
      _logger.e('signOut error: $e');
    }
  }

  Future<void> temp() async {
    try {
      var type = await UserStore.to.getLoginType();
      _logger.e(type);
    } catch (e) {
      _logger.e('signOut error: $e');
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
          _logger.w('userModel: ${userModel.value.toString()}');

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
          //       _logger.d('doc: ${doc.data()}');
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
      _logger.e('withdrawal error: $e');
    }
  }

  // 이메일 주소 마스킹
  String maskEmail(String email) {
    String maskedEmail = email.replaceAll(RegExp(r'(?<=.{3}).(?=[^@]*?.@)'), '*');
    return maskedEmail;
  }

}
