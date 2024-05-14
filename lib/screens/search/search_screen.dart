import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foreats/screens/search/search_keyword_controller.dart';
import 'package:get/get.dart';

import '../../model/feed_model.dart';
import '../../utils/app_routes.dart';
import '../../utils/colors.dart';
import '../feed/feed_controller.dart';

class SearchKeywordScreen extends GetView<SearchKeywordController> {

  const SearchKeywordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    // 검색결과 창
    return Column(
      children: [
        _buildSearchBar(),
        SizedBox(height: 10.h),
        _bestKeywordTextView(),
        _buildBestKeyword(),
        SizedBox(height: 10.h),
        _buildRecentKeywordTextView(),
        Obx(() => controller.searchRecentKeywords.isEmpty
            ? Container(
                padding: EdgeInsets.only(left: 20.w, right: 20.w),
                height: 30.h,
                alignment: Alignment.centerLeft,
                child: Text('최근 검색어가 없습니다.',
                    style: TextStyle(fontSize: 13.sp, color: gray500)),
              )
            : _buildRecentKeyword()),
        SizedBox(height: 10.h),
        _searchResultTextView(),
        Obx(() => controller.searchResults.isEmpty
            ? Container(
                padding: EdgeInsets.only(left: 20.w, right: 20.w),
                height: 30.h,
                alignment: Alignment.centerLeft,
                child: Text('검색결과가 없습니다.',
                    style: TextStyle(fontSize: 13.sp, color: gray500)),
              )
            : _buildSearchResults(context)),
      ],
    );
  }

  Widget _bestKeywordTextView() {
    return Container(
      padding: EdgeInsets.only(left: 20.w, right: 20.w),
      height: 30.h,
      alignment: Alignment.centerLeft,
      child: Text('인기검색', style: TextStyle(fontSize: 12.sp)),
    );
  }

  Widget _buildBestKeyword() {
    return Container(
      padding: EdgeInsets.only(left: 10.w, right: 20.w),
      child: SizedBox(
        height: 20.h,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: controller.searchBestKeywords.length,
          itemBuilder: (context, index) {
            return InkWell(
                onTap: () {
                  controller.search(controller.searchBestKeywords[index]);
                  controller.addRecentKeyword(controller.searchBestKeywords[index]);
                },
                child: _searchBestKeyword(controller.searchBestKeywords[index]));
          },
        ),
      ),
    );
  }

  // 인기검색 키워드
  Widget _searchBestKeyword(String value) {
    return Container(
      width: 50.w,
      height: 20.h,
      margin: EdgeInsets.only(right: 2.w, left: 10.w),
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 5.h),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(value, style: TextStyle(fontSize: 10.sp)),
    );
  }

  Widget _buildRecentKeywordTextView() {
    return Container(
      padding: EdgeInsets.only(left: 20.w, right: 20.w),
      height: 30.h,
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          Text('최근검색', style: TextStyle(fontSize: 12.sp)),
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
    return Container(
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
                  },
                  decoration: InputDecoration(
                    hintText: '검색어를 입력하세요',
                    hintStyle: TextStyle(fontSize: 13.sp),
                    border: InputBorder.none,
                  ),
                ),
              ),
              // InkWell(
              //   onTap: () {
              //     controller.search(controller.searchController.text);
              //   },
              //   child: Text('검색', style: TextStyle(fontSize: 13.sp)),
              // ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _searchResultTextView() {
    return Container(
      padding: EdgeInsets.only(left: 20.w, right: 20.w),
      height: 30.h,
      alignment: Alignment.centerLeft,
      child: Text('검색결과', style: TextStyle(fontSize: 12.sp)),
    );
  }

  // 검색결과 창
  Widget _buildSearchResults(BuildContext context) {
    return Column(
      children: List.generate(
        controller.searchResults.length,
        (index) => InkWell(
          onTap: () {
            controller.addRecentKeyword(controller.searchResults[index]);
          },
          child: InkWell(
              onTap: () async {
                //FeedController.to.search(controller.searchResults[index]);

                await FirebaseFirestore.instance
                    .collection('feeds')
                    .where('storeName', isEqualTo: controller.searchResults[index])
                    .get()
                    .then((value) {
                  if (value.docs.isNotEmpty) {

                    var model = FeedModel.fromJson(value.docs[0].data());

                    Get.toNamed(AppRoutes.feedDetail, arguments: {
                      'detailFeed': model,
                    });
                  }
                });

              },
              child:
                  _searchResultItem(context, controller.searchResults[index])),
        ),
      ),
    );
  }

  // 검색결과 아이템
  Widget _searchResultItem(BuildContext context, String value) {
    return Container(
      padding: EdgeInsets.only(left: 20.w, right: 20.w),
      height: 30.h,
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.search, size: 20.sp, color: gray500),
              SizedBox(width: 10.w),
              Text(
                value,
                style: TextStyle(fontSize: 13.sp),
              ),
            ],
          ),
          Icon(Icons.arrow_forward_ios, size: 15.sp, color: gray500),
        ],
      ),
    );
  }

}
