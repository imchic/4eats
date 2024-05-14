import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foreats/screens/upload/upload_controller.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logger/logger.dart';

import '../../utils/colors.dart';
import '../../utils/global_toast_controller.dart';
import '../../widget/base_appbar.dart';
import '../map/map_controller.dart';

class UploadRegisterScreen extends GetView<UploadController> {

  UploadRegisterScreen({super.key});

  final _logger = Logger();

  @override
  Widget build(BuildContext context) {

    Get.put(GlobalToastController());
    Get.put(UploadController());
    Get.put(MapController());

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      resizeToAvoidBottomInset: false,
      appBar: BaseAppBar(
        title: '동영상 업로드',
        leading: true,
      ),
      body: _uploadRegisterBody(context),
    );
  }

  Widget _uploadRegisterBody(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: Get.height * 0.75,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _storeNameInput(context),
                _storeAddressInput(context),
                _storeMap(context),
                _storeVideoDescriptionInput(context),
                _storeHashTagHorizontalList(context)
              ],
            ),
          ),
        ),
        _uploadRegisterBottom(context),
      ],
    );
  }

  Widget _uploadRegisterBottom(BuildContext context) {
    return InkWell(
      onTap: () {
        controller.uploadVideo();
      },
      child: Container(
        width: 350.w,
        margin: EdgeInsets.symmetric(horizontal: 20.w),
        padding:
            EdgeInsets.only(top: 15.h, bottom: 15.h, left: 15.w, right: 15.w),
        decoration: ShapeDecoration(
          color: Theme.of(context).colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '업로드',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                height: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 업로드 썸네일 뷰
  /*_uploadThumbnailView() {
    return Container(
      width: 350.w,
      height: 200.h,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: FutureBuilder<Uint8List>(
                future: controller.getThumbnail(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Image.memory(
                      snapshot.data!,
                      fit: BoxFit.cover,
                    );
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }*/

  // 가게명 입력
  Widget _storeNameInput(BuildContext context) {
    return Obx(
      () => Container(
        margin: EdgeInsets.only(top: 10.h),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '가게명',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                height: 0.09,
              ),
            ),
            SizedBox(height: 8.h),
            // 자동완성 오버레이사용해서 구현
            Stack(
              children: [
                TextField(
                  controller: controller.storeNameController,
                  decoration: InputDecoration(
                    hintText: '가게명을 입력해주세요',
                    hintStyle: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: const BorderSide(
                        color: Color(0xFFF0F0F0),
                      ),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 10.h,
                      horizontal: 14.w,
                    ),
                  ),
                  onChanged: (value) async {
                    controller.storeName = controller.storeNameController.text;
                    await controller.onPlaceSearchChanged(value);
                  },
                ),
                if (MapController.to.storeList.isNotEmpty)
                  Container(
                    //height: 200.h,
                    width: Get.width,
                    height: MapController.to.storeList.length > 3 ? 200.h : MapController.to.storeList.length * 60.h,
                    margin: EdgeInsets.only(top: 40.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 1,
                          blurRadius: 7,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ListView.builder(
                      itemCount: MapController.to.storeList.length,
                      controller: MapController.to.scrollController,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            controller.storeNameController.text = MapController.to.storeList[index].name.toString();
                            MapController.to.searchAddress.value = MapController.to.storeList[index].address.toString();
                            MapController.to.storeCategory.value = MapController.to.storeList[index].category.toString();
                            MapController.to.storeMenuInfo.value = MapController.to.storeList[index].menuInfo.toString();
                            MapController.to.storeContext.value = MapController.to.storeList[index].contextInfo.toString();
                            MapController.to.currentLocation.value = LatLng(double.parse(MapController.to.storeList[index].y.toString()), double.parse(MapController.to.storeList[index].x.toString()),);
                            MapController.to.moveToCurrentLocation(
                              LatLng(double.parse(MapController.to.storeList[index].y.toString()), double.parse(MapController.to.storeList[index].x.toString())),
                            );

                            // 드롭박스 닫기
                            MapController.to.storeList.clear();
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              vertical: 10.h,
                              horizontal: 14.w,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 200.w,
                                  child: Text(
                                    MapController.to.storeList[index].name
                                        .toString(),
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(height: 2.5.h),
                                Text(
                                  MapController.to.storeList[index].category
                                      .toString(),
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    color: CupertinoDynamicColor.resolve(
                                      CupertinoColors.systemBlue,
                                      context,
                                    ),
                                    fontWeight: FontWeight.w400,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 5.h),
                                Text(
                                  MapController.to.storeList[index].address
                                      .toString(),
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    color: gray500,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            )
          ],
        ),
      ),
    );
  }

  // 가게주소 입력
  Widget _storeAddressInput(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '가게주소',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  height: 0.09,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Obx(
            () => InkWell(
              onTap: () {
                //Get.toNamed(AppRoutes.map);
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  vertical: 10.h,
                  horizontal: 14.w,
                ),
                decoration: ShapeDecoration(
                  color: gray100,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      MapController.to.searchAddress.value,
                      style: TextStyle(
                        color: gray600,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 14.r,
                      color: gray500,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 가게 지도
  Widget _storeMap(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '지도',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              height: 0.09,
            ),
          ),
          SizedBox(height: 8.h),
          Container(
            width: Get.width,
            height: 80.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.r),
              color: Colors.grey,
            ),
            child: Obx(
              () => GoogleMap(
                onMapCreated: MapController.to.onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: MapController.to.currentLocation.value,
                  zoom: 15,
                ),
                markers: Set<Marker>.of(MapController.to.markers),
                onCameraMove: MapController.to.onCameraMove,
                myLocationEnabled: true,
                zoomControlsEnabled: false,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 가게 동영상 제목 입력
  /*Widget _storeVideoTitleInput(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '동영상 제목',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              height: 0.09,
            ),
          ),
          SizedBox(height: 8.h),
          TextField(
            controller: controller.storeVideoTitleController,
            decoration: InputDecoration(
              hintText: '동영상 제목을 입력해주세요',
              hintStyle: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: const BorderSide(
                  color: Color(0xFFF0F0F0),
                ),
              ),
              contentPadding: EdgeInsets.symmetric(
                vertical: 10.h,
                horizontal: 14.w,
              ),
            ),
            onChanged: (value) {
              controller.uploadTitle.value = value;
            },
          ),
        ],
      ),
    );
  }*/

  // 가게 동영상 설명 입력
  Widget _storeVideoDescriptionInput(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '내용',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              height: 0.09,
            ),
          ),
          SizedBox(height: 8.h),
          TextField(
            controller: controller.storeDescriptionController,
            scrollPadding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            maxLines: 5,
            decoration: InputDecoration(
              hintText: '동영상 설명을 입력해주세요',
              hintStyle: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: const BorderSide(
                  color: Color(0xFFF0F0F0),
                ),
              ),
              contentPadding: EdgeInsets.symmetric(
                vertical: 10.h,
                horizontal: 14.w,
              ),
            ),
            onChanged: (value) {
              controller.storeDescription =
                  controller.storeDescriptionController.text;
            },
            onTap: () {
              controller.storeDescriptionController.text = '';
            },
          ),
        ],
      ),
    );
  }

  // 해시태그 리스트
  Widget _storeHashTagHorizontalList(BuildContext context) {
    return Obx(
      () => Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '해시태그',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                height: 0.09,
              ),
            ),
            SizedBox(height: 8.h),
            SizedBox(
              height: 30.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: controller.hashtagList.length,
                itemBuilder: (context, index) {
                  return Obx(
                    () => GestureDetector(
                      onTap: () {
                        controller.addHashtag(controller.hashtagList[index]);
                      },
                      child: Container(
                        margin: EdgeInsets.only(right: 10.w),
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        decoration: ShapeDecoration(
                          // 선택된 아이템만 색상 변경
                          color: controller.selectedHashtagStringList
                                  .contains(controller.hashtagList[index])
                              ? Theme.of(context).colorScheme.tertiary
                              : gray100,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              controller.hashtagList[index],
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w600,
                                color: controller.selectedHashtagStringList
                                        .contains(controller.hashtagList[index])
                                    ? Colors.white
                                    : gray600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 해시태그 입력 다이얼로그
  /*Widget _hashtagInputDialog(BuildContext context) {
    return AlertDialog(
      title: const Text('해시태그 입력'),
      content: TextField(
        controller: controller.hashtagController,
        decoration: const InputDecoration(
          hintText: '해시태그를 입력해주세요',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Get.back();
          },
          child: const Text('취소'),
        ),
        TextButton(
          onPressed: () {
            controller.addHashtag(
              controller.hashtagController.text,
            );
            Get.back();
          },
          child: const Text('확인'),
        ),
      ],
    );
  }*/

  leadingOnPressed() {
    Get.back();
  }
}
