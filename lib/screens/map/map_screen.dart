import 'package:cached_network_image/cached_network_image.dart';
import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foreats/utils/logger.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logger/logger.dart';
import 'package:widget_marker_google_map/widget_marker_google_map.dart';

import '../../utils/colors.dart';
import '../../widget/animatet_search_bar.dart';
import '../../widget/base_appbar.dart';
import '../feed/feed_controller.dart';
import 'map_controller.dart';

class MapScreen extends GetView<MapController> {
  final _logger = Logger();

  MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(AppLog());
    // get arguments
    final args = Get.arguments;
    if (args != null) {
      var lonlat = args['lonlat'].toString().split(',');
      // replace
      lonlat[0] = lonlat[0].replaceAll('[', '');
      lonlat[1] = lonlat[1].replaceAll(']', '');

      controller.currentLocation.value = LatLng(
        double.parse(lonlat.first),
        double.parse(lonlat.last),
      );

      Future.delayed(Duration(milliseconds: 500), () {
        controller.moveToCurrentLocation(
            LatLng(
              double.parse(lonlat.first),
              double.parse(lonlat.last),
            )
        );
      });

    }

    FeedController.to.allPause();
    //controller.fetchSearchPlace('맛집');

    return _buildScaffold(context);
  }

  Widget _buildScaffold(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(
        title: '지도',
        leading: true,
        callback: () {
          FeedController.to.recentPlay();
          Get.back();
        },
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            _buildMap(context),
          ],
        ),
        // CustomInfoWindow(
        //   controller: controller.customInfoWindowController,
        //   width: 150.w,
        //   height: 40.h,
        //   offset: 10.w,
        // ),
        _searchBar(context),
        _storeList(context),
      ],
    );
  }

  Widget _buildMap(BuildContext context) {
    return Expanded(
      child: Obx(
        () => WidgetMarkerGoogleMap(
          onMapCreated: controller.onMapCreated,
          initialCameraPosition: CameraPosition(
            target: controller.currentLocation.value,
            zoom: 15,
          ),
          //widgetMarkers: controller.widgetMarkers.isNotEmpty ? controller.widgetMarkers : [],
          widgetMarkers: [
            for (var store in controller.storeList)
              WidgetMarker(
                markerId: store.name ?? '0',
                position: LatLng(
                  double.parse(store.y ?? '0.0'),
                  double.parse(store.x ?? '0.0'),
                ),
                onTap: () {
                  controller.onMarkerTapped(store);
                },
                widget: Container(
                  width: 120.w,
                  height: Get.height * 0.05,
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    //color: Theme.of(context).colorScheme.primary.withOpacity(0.75),
                    color: CupertinoColors.activeBlue.withOpacity(0.75),
                    borderRadius: BorderRadius.circular(10.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.25),
                        spreadRadius: 1,
                        blurRadius: 7.r,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/images/ic_coins.svg',
                        // width: 15.w,
                        // height: 15.h,
                        color: Colors.white,
                      ),
                      SizedBox(width: 5.w),
                      Text(store.totalPoint ?? '0포인트',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1),
                    ],
                  ),
                ),
              ),
          ],
          onCameraMove: controller.onCameraMove,
          onCameraMoveStarted: controller.onCameraMoveStarted,
          onCameraIdle: controller.onCameraIdle,
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          buildingsEnabled: true,
          mapToolbarEnabled: false,
          tiltGesturesEnabled: false,
        ),
      ),
    );
  }

  Widget _searchBar(BuildContext context) {
    return Container(
      height: 40.h,
      margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      child: AnimatedSearchBar(
        width: Get.width * 0.8,
        textController: controller.searchController,
        onSuffixTap: () {
          controller.searchController.clear();
        },
        rtl: false,
        onSubmitted: (String value) async {
          controller.searchPlace.value = value;
          await controller.fetchSearchPlace(value, page: 1);
        },
        onChanged: (String value) {
          //controller.searchController.text = value;
        },
        textInputAction: TextInputAction.search,
        searchBarOpen: (a) {
          a = 50;
        },
        closeSearchOnSuffixTap: true,
      ),
    );
  }

  /// 가게 리스트
  Widget _storeList(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Obx(
        () => controller.storeList.isEmpty
            ? Container()
            : _storeListContainer(context),
      ),
    );
  }

  /// 가게 리스트 컨테이너
  Widget _storeListContainer(BuildContext context) {
    return Column(
      children: [
        Container(
          width: Get.width,
          color: Colors.white,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
            margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '검색결과 ',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(
                        text: '${controller.storeList.length}개',
                        style: TextStyle(
                          color: CupertinoColors.activeBlue,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 10.w),
                InkWell(
                  onTap: () {
                    Get.defaultDialog(
                      title: '필터',
                      content: Column(
                        children: [
                          ListTile(
                            title: Row(
                              children: [
                                Icon(
                                  CupertinoIcons.location,
                                  size: 15.sp,
                                ),
                                SizedBox(width: 5.w),
                                Text('가까운 거리'),
                              ],
                            ),
                            onTap: () {
                              controller.storeList.sort((a, b) {
                                return double.parse(a.distance ?? '0.0')
                                    .compareTo(double.parse(b.distance ?? '0.0'));
                              });
                              Get.back();
                            },
                          ),
                          ListTile(
                            title: Row(
                              children: [
                                Icon(
                                  CupertinoIcons.location_slash,
                                  size: 15.sp,
                                ),
                                SizedBox(width: 5.w),
                                Text('먼 거리'),
                              ],
                            ),
                            onTap: () {
                              controller.storeList.sort((a, b) {
                                return double.parse(b.distance ?? '0.0')
                                    .compareTo(double.parse(a.distance ?? '0.0'));
                              });
                              Get.back();
                            },
                          ),
                        ],
                      ),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.15),
                          spreadRadius: 1,
                          blurRadius: 7.r,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Text(
                          '필터',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 5.w),
                        Icon(
                          CupertinoIcons.slider_horizontal_3,
                          color: Colors.black,
                          size: 15.sp,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // 가게 리스트 아이템
        Container(
          width: Get.width,
          height: Get.height * 0.38,
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          color: Colors.white,
          child: controller.isSearchLoading.value == false ?
          ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: controller.storeList.length,
            controller: controller.scrollController,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  controller.onMarkerTapped(controller.storeList[index]);
                  controller.selectIndex.value = index;
                  _logger.d('selectIndex: ${controller.selectIndex.value}');
                  // show info window
                  controller.showInfoWindow(
                    controller.storeList[index].x,
                    controller.storeList[index].y,
                    controller.storeList[index].name,
                    controller.storeList[index].address,
                  );
                },
                child: Obx(() =>
                  Container(
                    width: Get.width * 0.7,
                    margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.75),
                      border: index == controller.selectIndex.value ? Border.all(
                        color: Theme.of(context).colorScheme.tertiary,
                        width: 2.w,
                      ) : null,
                      // color: index == controller.selectIndex.value ? Theme.of(context).colorScheme.tertiary.withOpacity(0.1) : Colors.white,
                      borderRadius: BorderRadius.circular(10.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.25),
                          spreadRadius: 1,
                          blurRadius: 7.r,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: Get.width * 0.65,
                              height: Get.height * 0.12,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10.r),
                                child: CachedNetworkImage(
                                  imageUrl: controller.storeList[index].thumbnail ?? '',
                                  placeholder: (context, url) => Container(
                                      width: 40.w,
                                      height: 40.h,
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            gray200,
                                          ),
                                        ),
                                      )),
                                  errorWidget: (context, url, error) =>
                                      Container(
                                        width: 40.w,
                                        height: 40.h,
                                        child: Center(
                                          child: Icon(
                                            CupertinoIcons.xmark_circle_fill,
                                            color: gray400,
                                            size: 40.sp,
                                          ),
                                        ),
                                      ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            SizedBox(height: 10.h),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: Get.width * 0.6,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: Get.width * 0.4,
                                        child: Text(
                                          controller.storeList[index].name ?? '',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 11.sp,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      // status
                                      Container(
                                        child: Text(
                                          controller.storeList[index].status ?? '',
                                          style: TextStyle(
                                            color: CupertinoColors.activeBlue,
                                            fontSize: 10.sp,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                SizedBox(height: 5.h),
                                Text(
                                  controller.storeList[index].category ?? '',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                SizedBox(height: 10.h),
                                Container(
                                  width: Get.width * 0.6,
                                  height: 10.h,
                                  child: Text(
                                    controller.storeList[index].roadAddress ?? '',
                                    style: TextStyle(
                                      color: gray500,
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(height: 5.h),
                                Container(
                                  width: Get.width * 0.6,
                                  height: 10.h,
                                  child: Text(
                                    controller.storeList[index].address ?? '',
                                    style: TextStyle(
                                      color: gray500,
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  controller.storeList[index].tel ?? '',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        // 메뉴
                        Container(
                          width: Get.width * 0.6,
                          margin: EdgeInsets.only(left: 10.w),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: controller.storeList[index].menuInfo?.map((e) {
                                return Container(
                                  margin: EdgeInsets.only(right: 5.w),
                                  padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.secondary,
                                    borderRadius: BorderRadius.circular(5.r),
                                  ),
                                  child: Text(
                                    e,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                );
                              })?.toList() ?? [],
                            ),
                          ),
                        ),
                        // 거리
                        Container(
                          margin: EdgeInsets.only(top: 10.h, bottom: 5.h, right: 10.w, left: 10.w),
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '현재위치에서 ',
                                  style: TextStyle(
                                    color: gray700,
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                TextSpan(
                                  text: controller.convertKmToMeter(
                                      double.parse(controller.storeList[index].distance ?? '0.0')
                                  ),
                                  style: TextStyle(
                                    color: CupertinoColors.activeBlue,
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ) : Center(
            child: CircularProgressIndicator(),
          )
        ),
      ],
    );
  }
}
