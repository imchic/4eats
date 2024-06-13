import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foreats/widget/point_card.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

import '../../model/biz_model.dart';
import '../../utils/colors.dart';
import '../../widget/base_appbar.dart';
import '../login/user_store.dart';
import 'biz_controller.dart';

class BizScreen extends GetView<BizController> {
  BizScreen({super.key});

  final _logger = Logger();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: BaseAppBar(
          title: '포인트몰',
          notification: true,
        ),
        body: Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
          child: Column(
            children: [
              Obx(
                () => UserStore.to.isLoginCheck == false
                    ? Center(
                        child: Text(
                          '로그인이 필요한 서비스입니다',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Get.isDarkMode
                                ? Theme.of(context).colorScheme.onSurface
                                : Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      )
                    : Container(
                        width: 1.sw,
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 5.h),
                        child: Row(
                          children: [
                            Text(
                              '안녕하세요,',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onBackground,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(width: 5.w),
                            Text(
                              UserStore.to.user.value.nickname ?? '',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              '님',
                              style: TextStyle(
                                color:
                                    Theme.of(context).colorScheme.onBackground,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
              SizedBox(height: 10.h),
              // card
              PointCard().buildPointCard(context),
              SizedBox(height: 10.h),
              Obx(
                () => controller.bizList.isEmpty &&
                        controller.brandNameList.isNotEmpty
                    ? Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(gray300),
                        ),
                      )
                    : _buildBizListCategoryList(context),
              ),
              SizedBox(height: 10.h),
              Obx(
                () => controller.bizList.isEmpty &&
                        controller.brandNameList.isNotEmpty
                    ? Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(gray300),
                        ),
                      )
                    : _buildBizListApiList(context),
              ),
            ],
          ),
        ));
  }

  // 브랜드 리스트
  /*_buildBizListBrandList(BuildContext context) {
    return Container(
      width: 1.sw,
      height: 30.h,
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: controller.brandNameList.length,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () async {
              await controller
                  .fetchBrandSelectList(controller.brandNameList[index]);
            },
            child: Container(
              //width: 120.w,
              height: 30.h,
              alignment: Alignment.center,
              margin: EdgeInsets.only(right: 5.w),
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.background,
                borderRadius: BorderRadius.circular(5.r),
                shape: BoxShape.rectangle,
                border: Border.all(
                  color: gray300,
                  width: 1.w,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CachedNetworkImage(
                    imageUrl: controller.brandIconList[index],
                    width: 20.w,
                    height: 20.h,
                    errorWidget: (context, url, error) => Icon(
                      Icons.all_inclusive,
                      color: gray500,
                      size: 20,
                    ),
                    placeholder: (context, url) => CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(gray300),
                    ),
                  ),
                  SizedBox(width: 5.w),
                  Text(
                    controller.brandNameList[index],
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      color: gray600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }*/

  // 브랜드 취합
  _buildBizListCategoryList(BuildContext context) {
    return Container(
      width: 1.sw,
      height: 30.h,
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: controller.goodTypeList.length,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () async {
              await controller.fetchGoodsTypeSelectList(
                  controller.goodTypeList[index], index);
            },
            child: Obx(
              () => Container(
                alignment: Alignment.center,
                margin: EdgeInsets.only(right: 5.w),
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: controller.isGoodTypeSelectIndex.value == index
                      ? Get.isDarkMode
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.secondary
                      : Get.isDarkMode
                          ? Theme.of(context).colorScheme.surface
                          : gray500,
                  borderRadius: BorderRadius.circular(20.r),
                  shape: BoxShape.rectangle,
                  border: Border.all(
                    color: controller.isGoodTypeSelectIndex.value == index
                        ? Theme.of(context).colorScheme.secondary
                        : Theme.of(context).scaffoldBackgroundColor,
                    width: 1.w,
                  ),
                ),
                child: Text(
                  controller.goodTypeList[index],
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w400,
                    color: controller.isGoodTypeSelectIndex.value == index
                        ? Get.isDarkMode
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.onSecondary
                        : Get.isDarkMode
                            ? Theme.of(context).colorScheme.onSurface
                            : Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // 상품 리스트
  _buildBizListApiList(BuildContext context) {
    return Obx(
      () => Expanded(
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
          ),
          itemCount: controller.isAll.value
              ? controller.bizList.length
              : controller.bizSelectList.length,
          itemBuilder: (context, index) {
            return controller.isAll.value
                ? _buildBizListApiItem(context, controller.bizList[index])
                : _buildBizListApiItem(context, controller.bizSelectList[index]);
          },
        ),
      ),
    );
  }

  // 상품 리스트 아이템
  _buildBizListApiItem(BuildContext context, BizModel bizModel) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            //print('model: ${model.toJson()}');
            controller.bizDetail.value = bizModel;

            _logger.d('bizModel: ${bizModel.toJson()}');

            Get.toNamed('/biz/detail', arguments: {
              'goods_code': bizModel.goodsCode,
            });
          },
          child: Stack(
            children: [
              Container(
                width: 0.4.sw,
                height: 0.4.sw,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.background,
                  borderRadius: BorderRadius.circular(10.r),
                  shape: BoxShape.rectangle,
                  boxShadow: [
                    BoxShadow(
                      color: gray300,
                      offset: Offset(0, 2),
                      blurRadius: 2,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.r),
                  child: CachedNetworkImage(
                    imageUrl: bizModel.goodsImgS!,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 5.h),
        Text(bizModel.brandName ?? '',
            style: TextStyle(
                fontSize: 10.sp, fontWeight: FontWeight.w500, color: Get.isDarkMode ? Colors.white : gray600)),
        SizedBox(height: 2.5.h),
        Container(
          alignment: Alignment.center,
          child: Text(bizModel.goodsName ?? '',
              style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: Get.isDarkMode ? gray200 : gray800
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center),
        ),
        SizedBox(height: 2.5.h),
        Text('${controller.numberFormat(int.parse(bizModel.salePrice!))}원',
            style: TextStyle(
                fontSize: 10.sp,
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600)),
        /*Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/lottie/point_light.json',
              width: 24.w,
              height: 24.h,
            ),
            SizedBox(width: 5.w),
            Text('${controller.numberFormat(int.parse(bizModel.salePrice!))}원',
                style: TextStyle(
                    fontSize: 10.sp,
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600)),
          ],
        )*/
      ],
    );
  }

/*_pageNumber(BuildContext context) {
    return Obx(
      () => Container(
        // width: 200.w,
        height: 40.h,
        padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 5.h),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          //itemCount: controller.totalPage.value,
          itemCount: controller.bizList.length,
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () {
                controller.currentPage.value = index + 1;
                controller.fetchBizApiGoodsList(index + 1);
              },
              child: Container(
                width: 40.w,
                height: 40.h,
                alignment: Alignment.center,
                margin: EdgeInsets.only(right: 5.w),
                decoration: BoxDecoration(
                  color: controller.currentPage.value == index + 1
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.background,
                  borderRadius: BorderRadius.circular(5.r),
                  shape: BoxShape.rectangle,
                ),
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: controller.currentPage.value == index + 1
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.onBackground,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }*/
}
