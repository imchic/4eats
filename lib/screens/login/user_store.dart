import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../model/user_model.dart';
import '../../utils/app_routes.dart';

class UserStore extends GetxController {
  static UserStore get to => Get.find();

  final Future<SharedPreferences> prefs = SharedPreferences.getInstance();
  final _logger = Logger();

  final _userProfile = UserModel().obs;
  UserModel get userProfile => _userProfile.value;
  set userProfile(UserModel value) => _userProfile.value = value;

  final isFirstAppOpen = false.obs;

  bool get firstAppOpen => isFirstAppOpen.value;

  set firstAppOpen(bool value) => isFirstAppOpen.value = value;

  // 로그인 상태
  final _isLoggedIn = false.obs;
  bool get isLoggedIn => _isLoggedIn.value;

  set isLoggedIn(bool value) => _isLoggedIn.value = value;

  RxBool isExist = false.obs;

  RxString id = ''.obs;
  RxString loginType = ''.obs;
  RxString photoUrl = ''.obs;
  RxString displayName = ''.obs;
  RxString emailAddress = ''.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    await checkLogin();
  }

  /// 최초 앱 실행 여부
  checkFirstAppOpen() async {
    try {
      prefs.then((SharedPreferences prefs) {
        final bool? isFirstAppOpen = prefs.getBool('isFirstAppOpen');
        if (isFirstAppOpen == null) {
          this.isFirstAppOpen.value = true;
          prefs.setBool('isFirstAppOpen', true);
        } else {
          this.isFirstAppOpen.value = false;
        }
        _logger.w('최초 앱 실행 여부: $isFirstAppOpen');
        _moveToNextScreen();
      });
    } catch (e) {
      _logger.e('checkFirstAppOpen error: $e');
    }
  }

  /// 다음 화면으로 이동
  _moveToNextScreen() {
    if (firstAppOpen) {
      Get.offAndToNamed(AppRoutes.home);
    } else {
      _logger.i('_moveToNextScreen > isLoggedIn: $isLoggedIn');
      Get.offAndToNamed(AppRoutes.home);
    }
  }

  /// 로그인 상태 저장
  setLoginStatus(bool value) {
    try {
      prefs.then((SharedPreferences prefs) {
        final isLogin = prefs.getBool('isLogin');
        if (isLogin == null) {
          prefs.setBool('isLogin', value);
        } else {
          prefs.setBool('isLogin', value);
        }
        isLoggedIn = value;
        _logger.i('로그인 상태: $isLoggedIn');
      });
    } catch (e) {
      _logger.e('setLoginStatus error: $e');
    }
  }

  /// [FirebaseFirestore] 로그인 사용자 정보 저장

  /// 회원정보가 있는지 확인
  Future<void> checkUserExist(String email) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> result = await FirebaseFirestore
          .instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      result.docs.forEach((doc) {
        _logger.i('checkUserExist > doc: ${doc.data()}');
        userProfile = UserModel.fromJson(doc.data());
      });

      // _logger.i('checkUserExist > userProfile: ${userProfile.toJson()}');
      // _logger.i('checkUserExist > result: ${result.docs.isNotEmpty}');

      isExist.value = result.docs.isNotEmpty;
      _logger.i('checkUserExist > isExist: $isExist');

    } catch (e) {
      _logger.e('checkUserExist error: $e');
    }
  }

  /// [FirebaseFirestore] 로그인 사용자 정보 저장
  setFirebaseUser(UserModel userModel) async {
    try {

      // 이메일이 존재할 경우
      if (userModel.email != null) {
        final QuerySnapshot<Map<String, dynamic>> result =
            await FirebaseFirestore.instance
                .collection('users')
                .where('email', isEqualTo: userModel.email)
                .get();

        // 사용자 정보가 존재하지 않을 경우
        if (result.docs.isEmpty) {
          _logger.i('setFirebaseUser > userModel: ${userModel.toJson()}');

          await FirebaseFirestore.instance
              .collection('users')
              .add(userModel.toJson());
          UserStore.to.setSharedPref(userModel);
          UserStore.to.setLoginStatus(true);
          UserStore.to.getUserProfile();


          Get.offAndToNamed(AppRoutes.home);
        }
      }
    } catch (e) {
      _logger.e('setFirebaseUser error: $e');
    }
  }

  /// [FirebaseFirestore] 사용자 정보 가져오기
  ///
  /// 사용자 정보를 가져와서 [UserModel]에 저장
  Future<void> getUserProfile() async {
    try {
      // shared
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      id.value = prefs.getString('id') ?? '';
      displayName.value = prefs.getString('nickname') ?? '';
      photoUrl.value = prefs.getString('profileImage') ?? '';
      emailAddress.value = prefs.getString('email') ?? '';
      loginType.value = prefs.getString('loginType') ?? '';

      userProfile = UserModel(
        id: id.value,
        displayName: displayName.value,
        photoUrl: photoUrl.value,
        email: emailAddress.value,
        loginType: loginType.value,
      );

      //_logger.i('getUserProfile > user: ${userProfile.toJson()}');

    } catch (e) {
      _logger.e('getUserProfile error: $e');
    }
  }

  /// 로그인 상태 확인
  checkLogin() async {
    try {
      prefs.then((SharedPreferences prefs) {
        final bool? isLogin = prefs.getBool('isLogin');
        if (isLogin == null) {
          isLoggedIn = false;
        } else {
          isLoggedIn = isLogin;
        }
        _logger.i('로그인 상태 확인: $isLogin');
      });
    } catch (e) {
      _logger.e('checkLogin error: $e');
    }
  }

  /// 사용자 정보 삭제
  removeSharedPref() async {
    prefs.then((SharedPreferences prefs) {
      prefs.remove('accessToken');
      prefs.remove('uid');
      prefs.remove('id');
      prefs.remove('email');
      prefs.remove('nickname');
      prefs.remove('profileImage');
      prefs.remove('loginType');
    });
  }

  /// 사용자 정보 저장
  setSharedPref(UserModel userModel) async {
    prefs.then((SharedPreferences prefs) {
      prefs.setString('accessToken', userModel.accessToken ?? '');
      prefs.setString('uid', userModel.uid ?? '');
      prefs.setString('email', userModel.email ?? '');
      prefs.setString('id', userModel.id ?? '');
      prefs.setString('nickname', userModel.displayName ?? '');
      prefs.setString('profileImage', userModel.photoUrl ?? '');
      prefs.setString('loginType', userModel.loginType ?? '');
    });
    userProfile = userModel;
  }

  /// 닉네임 가져오기
  Future<String> getPhotoUrl() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? profileImage = prefs.getString('profileImage');
    photoUrl.value = profileImage ?? '';
    return profileImage ?? '';
  }

  /// 아이디 가져오기
  Future<String> getId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? id = prefs.getString('id');
    this.id.value = id ?? '';
    return id ?? '';
  }

  /// 로그인 타입 저장
  Future<void> setLoginType(String s) async {
    prefs.then((SharedPreferences prefs) {
      prefs.setString('loginType', s);
    });
  }

  /// 로그인 유형
  Future<String> getLoginType() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? type = prefs.getString('loginType');
    _logger.d('getLoginType: $type');
    loginType.value = type ?? '';
    return type ?? '';
  }
}
