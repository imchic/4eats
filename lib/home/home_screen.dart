
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../screens/feed/feed_controller.dart';
import '../screens/login/user_store.dart';
import '../utils/app_routes.dart';
import '../widget/fade_indexed_stack.dart';
import '../widget/login_bottom_sheet.dart';
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

            if(UserStore.to.isLoggedIn == false){
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
          child: const Icon(Icons.add),
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
              fontWeight: FontWeight.w500,
              height: 1.5.h,
            ),
            items: [
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  'assets/images/ic_home.svg',
                  colorFilter: ColorFilter.mode(
                    selectedVectorColor(0),
                    BlendMode.srcIn,
                  ),
                ),
                label: '피드',
              ),
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  'assets/images/ic_dashboard.svg',
                  colorFilter: ColorFilter.mode(
                    selectedVectorColor(1),
                    BlendMode.srcIn,
                  ),
                ),
                label: '라운지',
              ),
              // BottomNavigationBarItem(
              //   backgroundColor: theme.colorScheme.primary,
              //   icon: SvgPicture.asset(
              //     'assets/images/ic_dollar_coins.svg',
              //     width: 32.w,
              //     height: 32.h,
              //     colorFilter: ColorFilter.mode(
              //       selectedVectorColor('upload', 2),
              //       BlendMode.srcIn,
              //     ),
              //   ),
              //   label: '업로드',
              // ),
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  'assets/images/ic_shopping_cart.svg',
                  colorFilter: ColorFilter.mode(
                    selectedVectorColor(2),
                    BlendMode.srcIn,
                  ),
                ),
                label: '포인트몰',
              ),
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  'assets/images/ic_users.svg',
                  colorFilter: ColorFilter.mode(
                    selectedVectorColor(3),
                    BlendMode.srcIn,
                  ),
                ),
                label: '마이페이지',
              ),
            ],
          ))
        );
        /*bottomNavigationBar: Obx(
          () => Container(
            child: BottomBarInspiredInside(
              backgroundColor: theme.colorScheme.background,
              //backgroundSelected: theme.colorScheme.background,
              color: theme.colorScheme.onBackground.withOpacity(0.5),
              colorSelected: theme.colorScheme.primary,
              indexSelected: HomeController.to.currentIndex,
              // highlightStyle: HighlightStyle(
              //   sizeLarge: true,
              //   background: theme.colorScheme.background,
              //   color: theme.colorScheme.primary,
              //   elevation: 10,
              // ),
              animated: true,
              itemStyle: ItemStyle.circle,
              chipStyle:const ChipStyle(drawHexagon: false, notchSmoothness: NotchSmoothness.defaultEdge),
              onTap: (value) => {
                HomeController.to.moveToPage(value),
              },
              items: [
                TabItem(icon: Icons.smart_display_outlined, title: ''),
                TabItem(icon: Icons.segment_outlined, title: ''),
                TabItem(icon: Icons.cloud_upload, title: ''),
                TabItem(icon: Icons.shopping_cart_outlined, title: ''),
                TabItem(icon: Icons.person_outline, title: ''),
              ],
            ),
          ),
        ));*/
  }

  Color selectedVectorColor(int index) {
    if (HomeController.to.currentIndex == index) {
      return Get.theme.colorScheme.primary;
    } else {
      return Get.theme.colorScheme.onBackground.withOpacity(0.25);
    }
  }
}
