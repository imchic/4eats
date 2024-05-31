import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foreats/model/feed_model.dart';
import 'package:foreats/utils/text_style.dart';

import 'package:get/get.dart';

import '../../utils/app_routes.dart';
import '../../utils/colors.dart';
import '../feed/feed_controller.dart';
import 'search_keyword_controller.dart';

class SearchKeywordScreen extends GetView<SearchKeywordController> {

  const SearchKeywordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Obx(() =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSearchBar(),
          SizedBox(height: 10.h),
          _bestKeywordTextView(),
          _buildBestKeyword(),
          SizedBox(height: 10.h),
          _buildRecentKeywordTextView(),
          _buildRecentKeyword(),
          SizedBox(height: 10.h),
          _searchResultTextView(),
          Expanded(
            child: _buildSearchResults(context),
          ),
        ],
      ),
    );
  }

  /// 인기검색 키워드 텍스트뷰
  Widget _bestKeywordTextView() {
    return Container(
      padding: EdgeInsets.only(left: 20.w, right: 20.w),
      height: 30.h,
      alignment: Alignment.centerLeft,
      child: Text(
          '인기검색',
          style: TextStyleUtils.bodyTextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
          )
      ),
    );
  }

  /// 인기검색 키워드
  Widget _buildBestKeyword() {
    return Container(
      padding: EdgeInsets.only(left: 10.w, right: 20.w),
      child: SizedBox(
        height: 20.h,
        child: FutureBuilder(
          future: controller.getBestKeywords(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: controller.searchBestKeywords.length,
                itemBuilder: (context, index) {
                  return _searchBestKeyword(controller.searchBestKeywords[index]);
                },
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }

  /// 인기검색 키워드
  Widget _searchBestKeyword(String value) {
    return Container(
      margin: EdgeInsets.only(right: 2.w, left: 10.w),
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 5.h),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        //color: Theme.of(Get.context!).colorScheme.primary.withOpacity(0.75),
        gradient: LinearGradient(
          colors: [
            Theme.of(Get.context!).colorScheme.primary.withOpacity(0.75),
            Theme.of(Get.context!).colorScheme.secondary.withOpacity(0.75),
          ],
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
        ),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(value, style: TextStyle(fontSize: 10.sp, color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }

  /// 최근검색 키워드 텍스트뷰
  Widget _buildRecentKeywordTextView() {
    return Container(
      padding: EdgeInsets.only(left: 20.w, right: 20.w),
      height: 30.h,
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          Text('최근검색', style: TextStyleUtils.bodyTextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
          )),
          Spacer(),
          InkWell(
              onTap: () {
                controller.clearRecentKeywords();
              },
              child: Text(
                '전체삭제',
                style: TextStyle(fontSize: 12.sp, color: Colors.red),
              )),
        ],
      ),
    );
  }

  /// 최근검색 키워드
  Widget _buildRecentKeyword() {
    return Column(
      children: List.generate(
        controller.searchRecentKeywords.length,
        (index) => InkWell(
          onTap: () {
            controller.addRecentKeyword(controller.searchRecentKeywords[index]);
          },
          child: _searchRecentKeyword(controller.searchRecentKeywords[index]),
        ),
      ),
    );
  }

  // 최근검색 키워드
  Widget _searchRecentKeyword(String value) {
    return InkWell(
      onTap: () {
        controller.searchController.text = value;
        controller.search(value);
      },
      child: Container(
        padding: EdgeInsets.only(left: 20.w, right: 20.w),
        height: 30.h,
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            Icon(Icons.access_time, size: 15.sp, color: gray500),
            SizedBox(width: 10.w),
            Text(value, style: TextStyle(fontSize: 13.sp)),
            Spacer(),
            InkWell(
              onTap: () {
                controller.removeRecentKeyword(value);
              },
              child: Icon(Icons.close, size: 15.sp, color: gray500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.only(top: 44.h),
      padding: EdgeInsets.only(left: 20.w, right: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              InkWell(
                onTap: () {
                  FeedController.to.recentPlay();
                  Get.back(
                    closeOverlays: true,
                    result: 'search',
                  );
                },
                child: Icon(Icons.arrow_back_ios, size: 14.sp),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: TextField(
                  controller: controller.searchController,
                  onChanged: (value) {
                    controller.search(value);
                  },
                  onSubmitted: (value) {
                    controller.addRecentKeyword(value);
                    controller.saveBestKeywords(value);
                  },
                  decoration: InputDecoration(
                    hintText: '검색어를 입력하세요',
                    hintStyle: TextStyle(fontSize: 13.sp, color: gray500, height: 1.4),
                    border: InputBorder.none,
                    suffixIcon: InkWell(
                      onTap: () {
                        controller.search(controller.searchController.text);
                        controller.addRecentKeyword(controller.searchController.text);
                        controller.saveBestKeywords(controller.searchController.text);
                      },
                      child: Icon(Icons.search, size: 20.sp),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 검색결과 텍스트뷰
  Widget _searchResultTextView() {
    return Container(
      padding: EdgeInsets.only(left: 20.w, right: 20.w),
      height: 30.h,
      alignment: Alignment.centerLeft,
      child: Text(
          '검색결과',
          style: TextStyleUtils.bodyTextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
          )),
    );
  }

  /// 검색결과 창
  Widget _buildSearchResults(BuildContext context) {
    return Container(
      child: ListView.builder(
        padding: EdgeInsets.only(top: 10.h),
        itemCount: controller.searchResults.length,
        itemBuilder: (context, index) {
          return _searchResultItem(context, controller.searchResults[index]);
        },
      ),
    );

  }

  // 검색결과 아이템
  Widget _searchResultItem(BuildContext context, String value) {
    return InkWell(
      onTap: () async {

        controller.addRecentKeyword(value);
        controller.saveBestKeywords(value);

        FeedController.to.feedList.forEach((element) {
          if (element.storeName == value) {
            var model = FeedModel.fromJson(element.toJson());
            Get.toNamed(AppRoutes.feedDetail, arguments: {
              'detailFeed': model,
            });
          }
        });

      },
      child: Container(
        padding: EdgeInsets.only(left: 20.w, right: 20.w),
        height: 30.h,
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            Icon(Icons.search, size: 15.sp, color: gray500),
            SizedBox(width: 10.w),
            Text(value, style: TextStyle(fontSize: 13.sp)),
          ],
        ),
      ),
    );
  }

}
