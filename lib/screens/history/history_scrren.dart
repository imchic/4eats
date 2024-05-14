import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../../utils/colors.dart';
import '../../widget/base_tabbar.dart';
import 'history_controller.dart';

class HistoryScreen extends GetView<HistoryController> {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Column(
        children: [
          //const BaseAppBar(title: '히스토리'),
          Expanded(
            child: _tabBar(context),
          ),
        ],
      ),
    );
  }

  Widget _tabBar(BuildContext context) {
    return Container(
      width: 1.sw,
      margin: EdgeInsets.only(top: 44.h),
      child: Column(
        children: [
          BaseTabBar(
            controller: controller.tabController,
            tabItems: controller.tabs,
          ),
          Expanded(
            child: TabBarView(
              controller: controller.tabController,
              children: [
                _buildHistoryRecentContainer(context),
                _buildHistoryLikeContainer(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 최근 본
  Widget _buildHistoryRecentContainer(BuildContext context) {
    return Obx(() {
      return controller.history.isNotEmpty
          ? RefreshIndicator(
              onRefresh: () async {
                //await controller.fetchHistory();
              },
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.only(left: 20.w, top: 20.h),
                          child: Text(
                            '최근 본 동영상',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onBackground,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              height: 0,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(right: 20.w, top: 20.h),
                        child: TextButton(
                          onPressed: () {
                            Get.dialog(
                              AlertDialog(
                                title: const Text('히스토리 삭제'),
                                content: const Text('모든 히스토리를 삭제하시겠습니까?'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Get.back();
                                    },
                                    child: const Text('취소'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      //controller.removeHistoryAll();
                                      Get.back();
                                    },
                                    child: const Text('확인'),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: Text(
                            '모두 삭제',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onBackground,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w400,
                              height: 0,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  /*Expanded(
              child: ListView.builder(
                itemCount: controller.history.length,
                itemBuilder: (context, i) {
                  return FutureBuilder(
                    future: controller.getThumbnail(controller.history[i].videoUrl ?? ''),
                    builder: (context, snapshot) {
                      if(snapshot.hasData) {
                        return _buildHistoryItem(context, i);
                      } else {
                        return Container();
                      }
                    },
                  );
                },
              ),
            ),*/
                ],
              ),
            )
          : _buildEmptyHistoryContainer(context);
    });
  }

  // 최근 본 빈 페이지
  Widget _buildEmptyHistoryContainer(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Lottie.asset(
                  'assets/lottie/no_history.json',
                  width: 200.w,
                  height: 200.w,
                  fit: BoxFit.cover,
                ),
                SizedBox(height: 20.h),
                Text(
                  '히스토리가 없습니다',
                  style: TextStyle(
                    color: gray500,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    height: 0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 좋아요
  Widget _buildHistoryLikeContainer(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Lottie.asset(
                  'assets/lottie/no_like.json',
                  width: 200.w,
                  height: 200.w,
                  fit: BoxFit.cover,
                ),
                SizedBox(height: 20.h),
                Text(
                  '좋아요한 동영상이 없습니다',
                  style: TextStyle(
                    color: gray500,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    height: 0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

}
