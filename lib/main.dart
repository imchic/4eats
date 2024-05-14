import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foreats/screens/login/user_store.dart';
import 'package:foreats/screens/map/location_service.dart';
import 'package:foreats/utils/app_routes.dart';
import 'package:foreats/utils/colors.dart';
import 'package:foreats/utils/firebase_message.dart';
import 'package:get/get.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';

import 'firebase_options.dart';

Future<void> onBackgroundHandler(RemoteMessage message) async {
  print('onBackgroundHandler message = $message');
}

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // firebase store
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(onBackgroundHandler);
  await FirebaseMessageApi().initNotifications();

  // 가로모드 대응
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  KakaoSdk.init(nativeAppKey: 'd00ccef3ef78e88b2fadabeba96a69b6');

  Get.put(UserStore());
  Get.put(LocationService());

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [
    SystemUiOverlay.top,
    SystemUiOverlay.bottom,
  ]);

  // systemOverlayStyle
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
  ));

  // 스플래시 화면을 보여주기 위해 5초간 대기
  await initialization();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: lightColorScheme,
          fontFamily: 'Pretendard',
          useMaterial3: false,
        ),
        darkTheme: ThemeData(
          colorScheme: darkColorScheme,
          fontFamily: 'Pretendard',
          useMaterial3: false,
        ),
        themeMode: ThemeMode.system,
        initialRoute: AppRoutes.landing,
        getPages: AppRoutes.routes,
        //defaultTransition: Transition.fadeIn,
      ),
    );
  }
}

Future initialization() async {
  await Future.delayed(const Duration(seconds: 1));
  FlutterNativeSplash.remove();
}
