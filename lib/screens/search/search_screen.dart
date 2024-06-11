import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foreats/model/feed_model.dart';
import 'package:foreats/utils/dialog_util.dart';
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
    return Obx(
      () =>
          // 검색창
          Column(
        children: [
          _buildSearchBar(),
          // 인기검색 키워드
          searchTextView('인기검색'),
          Container(
            height: 40.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: controller.searchBestKeywords.length,
              itemBuilder: (context, index) {
                return _searchBestKeyword(controller.searchBestKeywords[index]);
              },
            ),
          ),
          // 최근검색 키워드
          searchTextView('최근검색'),
          Container(
            height: 200.h,
            child: ListView.separated(
              padding: EdgeInsets.only(top: 20.h),
              scrollDirection: Axis.vertical,
              itemCount: controller.searchRecentKeywords.length,
              itemBuilder: (context, index) {
                return _searchRecentKeyword(
                    controller.searchRecentKeywords[index]);
              },
              separatorBuilder: (context, index) {
                return Divider(height: 10.h, color: gray200);
              },
            ),
          ),
          // 검색결과
          searchTextView('검색결과'),
          Expanded(
            child: _buildSearchResults(context),
          ),
        ],
      ),
    );
  }

  /// 인기검색 키워드 텍스트뷰
  Widget searchTextView(String title) {
    return Container(
      margin: EdgeInsets.only(top: 20.h),
      padding: EdgeInsets.only(left: 20.w, right: 20.w),
      alignment: Alignment.centerLeft,
      child: Text(title,
          style: TextStyleUtils.bodyTextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
          )),
    );
  }

  /// 검색창
  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.only(top: 64.h),
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
                    hintStyle:
                        TextStyle(fontSize: 13.sp, color: gray500, height: 1.4),
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

  /// 인기검색 키워드

  /// 인기검색 키워드
  Widget _searchBestKeyword(String value) {
    return Container(
      margin: EdgeInsets.only(left: 20.w, top: 10.h, bottom: 10.h),
      padding: EdgeInsets.only(left: 10.w, right: 10.w),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Theme.of(Get.context!).colorScheme.primary,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(value,
          style: TextStyle(
              fontSize: 10.sp,
              color: Colors.white,
              fontWeight: FontWeight.bold)),
    );
  }

  /// 최근검색 키워드
  Widget _buildRecentKeyword() {
    return ListView.separated(
        itemBuilder: (context, index) {
          return _searchRecentKeyword(controller.searchRecentKeywords[index]);
        },
        separatorBuilder: (context, index) {
          return Divider(height: 10.h, color: gray200);
        },
        itemCount: controller.searchRecentKeywords.length,
        shrinkWrap: true);
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

  /// 검색결과 텍스트뷰
  Widget _searchResultTextView() {
    return Container(
      padding: EdgeInsets.only(left: 20.w, right: 20.w),
      alignment: Alignment.centerLeft,
      child: Text('검색결과',
          style: TextStyleUtils.bodyTextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
          )),
    );
  }

  /// 검색결과 창
  Widget _buildSearchResults(BuildContext context) {
    return ListView.separated(
        itemBuilder: (context, index) {
          return _searchResultItem(context, controller.searchResults[index]);
        },
        separatorBuilder: (context, index) {
          return Divider(height: 10.h, color: gray200);
        },
        padding: EdgeInsets.only(top: 20.h),
        itemCount: controller.searchResults.length,
        shrinkWrap: true
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
