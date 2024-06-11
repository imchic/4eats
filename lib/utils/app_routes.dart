import 'package:foreats/screens/notification/notifications_screen.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';

import '../home/home_binding.dart';
import '../home/home_screen.dart';
import '../screens/biz/biz_detail_screen.dart';
import '../screens/biz/biz_history_screen.dart';
import '../screens/biz/biz_screen.dart';
import '../screens/feed/feed_detail_binding.dart';
import '../screens/feed/feed_detail_screen.dart';
import '../screens/feed/feed_screen.dart';
import '../screens/landing/landing_screen.dart';
import '../screens/landing/splash_screen.dart';
import '../screens/login/login_binding.dart';
import '../screens/login/login_screen.dart';
import '../screens/lounge/loungefeed_screen.dart';
import '../screens/signin/register_birthday_screen.dart';
import '../screens/signin/register_gender_screen.dart';
import '../screens/signin/register_id_screen.dart';
import '../screens/signin/register_nickname_screen.dart';
import '../screens/lounge/lounge_screen.dart';
import '../screens/map/map_binding.dart';
import '../screens/map/map_screen.dart';
import '../screens/onboarding/onboarding_middleware.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/search/search_binding.dart';
import '../screens/search/search_screen.dart';
import '../screens/setting/setting_screen.dart';
import '../screens/store/store_binding.dart';
import '../screens/store/store_screen.dart';
import '../screens/upload/upload_done_screen.dart';
import '../screens/upload/upload_preview_screen.dart';
import '../screens/upload/upload_register_screen.dart';
import '../screens/upload/upload_screen.dart';
import '../users/user_profile_screen.dart';

class AppRoutes {

  // app name
  static const String baseAppName = '포잇';

  static const String temp = '/temp';
  static const String home = '/';
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String landing = '/landing';
  static const String login = '/login';
  static const String feed = '/feed';
  static const String history = '/history';
  static const String feedDetail = '/feed/detail';
  static const String lounge = '/lounge';
  static const String loungeFeed = '/loungeFeed';
  static const String upload = '/upload';
  static const String uploadRegister = '/uploadRegister';
  static const String uploadPreview = '/uploadPreview';
  static const String uploadDone = '/uploadDone';
  static const String following = '/following';
  static const String my = '/my';
  static const String settings = '/settings';
  static const String map = '/map';
  static const String notification = '/notification';
  static const String registerNickname = '/registerNickname';
  static const String registerId = '/registerId';
  static const String registerGender = '/registerGender';
  static const String registerBirth = '/registerBirth';
  static const String search = '/search';
  static const String changePassword = '/changePassword';
  static const String deleteAccount = '/deleteAccount';
  static const String notice = '/notice';
  static const String noticeDetail = '/noticeDetail';
  static const String store = '/store';
  static const String biz = '/biz';
  static const String bizDetail = '/biz/detail';
  static const String bizHistory = '/bizHistory';
  static const String userProfile = '/userProfile';

  static final routes = [
    GetPage(name: home, page: () => HomeScreen(), binding: HomeBinding()),
    GetPage(name: landing, page: () => LandingScreen()),
    GetPage(name: splash, page: () => SplashScreen()),
    GetPage(name: onboarding, page: () => OnBoardingScreen(), middlewares: [OnBoardingMiddleware(),]),
    GetPage(name: login, page: () => LoginScreen(), binding: LoginBinding()),
    GetPage(name: registerNickname, page: () => RegisterNicknameScreen()),
    GetPage(name: registerId, page: () => RegisterIdScreen()),
    GetPage(name: registerGender, page: () => RegisterGenderScreen()),
    GetPage(name: registerBirth, page: () => RegisterBirthScreen()),
    GetPage(name: feed, page: () => FeedScreen()),
    GetPage(name: feedDetail, page: () => FeedDetailScreen(), binding: FeedDetailBinding()),
    GetPage(name: lounge, page: () => LoungeScreen()),
    GetPage(name: loungeFeed, page: () => LoungeFeedScreen()),
    GetPage(name: upload, page: () => UploadScreen()),
    GetPage(name: uploadPreview, page: () => UploadPreviewScreen()),
    GetPage(name: uploadRegister, page: () => UploadRegisterScreen()),
    GetPage(name: uploadDone, page: () => UploadDoneScreen()),
    GetPage(name: settings, page: () => SettingScreen()),
    GetPage(name: map, page: () => MapScreen(), binding: MapBinding()),
    GetPage(name: notification, page: () => NotificationsScreen()),
    GetPage(name: search, page: () => SearchKeywordScreen(), binding: SearchBinding()),
    GetPage(name: store, page: () => StoreScreen(), binding: StoreBinding()),
    GetPage(name: biz, page: () => BizScreen()),
    GetPage(name: bizDetail, page: () => BizDetailScreen()),
    GetPage(name: bizHistory, page: () => BizHistoryScreen()),
    GetPage(name: userProfile, page: () => UserProfileScreen()),
  ];
}
