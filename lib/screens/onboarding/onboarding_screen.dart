import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

import '../../utils/app_routes.dart';
import '../../utils/colors.dart';
import '../login/user_store.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  int pageLength = 3;
  int currentIndexPage = 0;

  var isSkip = false;
  var isDone = false;

  // List<String> images = [
  //   'assets/images/ic_poeat_logo.png',
  //   'assets/images/ic_poeat_logo.png',
  //   'assets/images/ic_poeat_logo.png',
  // ];

  List<String> images = [
    'assets/lottie/empty_video.json',
    'assets/lottie/gift.json',
    'assets/lottie/communication.json',
  ];

  List<String> titles = [
    '나만의 꿀 맛집 공유',
    '입소문을 내고 받는 쏠쏠한 보상',
    '사장님과 소통하여 맛집 만들기',
  ];

  List<String> descriptions = [
    '혼자만 알고 있는 맛을 \n${AppRoutes.baseAppName}에 담아보세요',
    '서포터즈 활동으로\n${AppRoutes.baseAppName}을 알리고 보상을\n받아보세요',
    '새로운 사람들과\n${AppRoutes.baseAppName}에서 소통해보세요'
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body:
      Stack(
        children: [
          PageView.builder(
            itemCount: pageLength,
            onPageChanged: (value) {
              setState(() {
                currentIndexPage = value;
              });
            },
            itemBuilder: (context, index) {
              return buildOnboardingPage(
                  images[index], titles[index], descriptions[index]);
            },
          ),
          Positioned(
            bottom: 50.h,
            left: 0,
            right: 0,
            child: buildDot(),
          ),
          SizedBox(height: 10.h),
          Positioned(
              bottom: 34.h,
              left: 20.w,
              right: 20.w,
              child: currentIndexPage == 2 ? _btnSkip() : Container()),
        ],
      ),
    );
  }

  Widget _btnSkip() {
    return GestureDetector(
      onTap: () {
        setState(() {
          UserStore.to.checkFirstAppOpen();
        });
      },
      child: Container(
        width: 353.w,
        height: 50.h,
        padding: EdgeInsets.all(15.r),
        decoration: ShapeDecoration(
          color: Theme.of(context).colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              //tr('onboarding_next'),
              '시작하기',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                height: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDot() {
    return DotsIndicator(
      dotsCount: pageLength,
      position: currentIndexPage.toInt(),
      decorator: DotsDecorator(
        size: Size.square(9.0.w),
        activeSize: Size(60.0.w, 5.h),
        activeShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0.r)),
        color: gray300,
        activeColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  /// 온보딩 페이지
  Widget buildOnboardingPage(
      String backgroundImage, String title, String description) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
          // background
          Center(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Lottie.asset(
                backgroundImage,
                width: 200.w,
                height: 200.h,
              )
              // child: Image.asset(
              //   backgroundImage,
              //   fit: BoxFit.cover,
              // ),
            ),
          ),
          Column(
            // 좌측 정렬
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 280.w,
                height: 200.h,
                margin: EdgeInsets.only(top: 111.h, left: 60.w, right: 60.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        height: 0,
                        letterSpacing: -0.26,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Container(
                      width: 280.w,
                      height: 100.h,
                      margin: EdgeInsets.only(left: 0.w, right: 0.w),
                      child: Text(
                        description,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: gray700,
                          fontSize: 26.sp,
                          fontWeight: FontWeight.w600,
                          height: 1.25,
                          letterSpacing: -0.46,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
