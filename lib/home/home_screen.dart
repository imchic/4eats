import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../screens/feed/feed_controller.dart';
import '../screens/login/user_store.dart';
import '../utils/app_routes.dart';
import '../widget/fade_indexed_stack.dart';
import '../widget/login_bottomsheet.dart';
import 'home_controller.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    final theme = Theme.of(context);
    return Scaffold(
        body: Obx(
          () => FadeIndexedStack(
            index: HomeController.to.currentIndex,
            children: HomeController.to.screens,
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (UserStore.to.isLoginCheck.value == false) {
              Get.bottomSheet(
                const LoginBottomSheet(),
              ).whenComplete(() {
                HomeController.to.moveToPage(0);
                FeedController.to.allPause();
              });
              return;
            } else {
              FeedController.to.allPause();
              Get.toNamed(AppRoutes.upload);
            }
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Image.asset(
            'assets/images/ic_feed_upload.png',
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: Obx(() => BottomNavigationBar(
              currentIndex: HomeController.to.currentIndex,
              onTap: (value) => {HomeController.to.moveToPage(value)},
              type: BottomNavigationBarType.fixed,
              backgroundColor: theme.colorScheme.background,
              selectedItemColor: theme.colorScheme.primary,
              unselectedItemColor: theme.colorScheme.onBackground.withOpacity(0.5),
              selectedLabelStyle: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w300,
                height: 1.25.h,
              ),
              items: [
                BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                    'assets/images/ic_video.svg',
                    colorFilter: ColorFilter.mode(
                      selectedVectorColor(0),
                      BlendMode.srcIn,
                    ),
                  ),
                  label: '피드',
                ),
                BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                    'assets/images/ic_square.svg',
                    colorFilter: ColorFilter.mode(
                      selectedVectorColor(1),
                      BlendMode.srcIn,
                    ),
                  ),
                  label: '라운지',
                ),
                BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                    'assets/images/ic_cart.svg',
                    colorFilter: ColorFilter.mode(
                      selectedVectorColor(2),
                      BlendMode.srcIn,
                    ),
                  ),
                  label: '포인트몰',
                ),
                BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                    'assets/images/ic_user.svg',
                    colorFilter: ColorFilter.mode(
                      selectedVectorColor(3),
                      BlendMode.srcIn,
                    ),
                  ),
                  label: '마이페이지',
                ),
              ],
            )));
  }

  Color selectedVectorColor(int index) {
    if (HomeController.to.currentIndex == index) {
      return Get.theme.colorScheme.primary;
    } else {
      return Get.theme.colorScheme.onBackground.withOpacity(0.25);
    }
  }
}
