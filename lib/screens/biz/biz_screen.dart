import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:lottie/lottie.dart';

import '../../model/biz_model.dart';
import '../../utils/app_routes.dart';
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
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: BaseAppBar(
          title: '포인트몰',
        ),
        body: Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
          child: Column(
            children: [
              Obx(
                () => UserStore.to.id.value.isEmpty
                    ? Center(
                        child: Text(
                          '로그인이 필요한 서비스입니다',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: gray600,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      )
                    : Container(
                        width: 1.sw,
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 5.h),
                        child: RichText(
                          text: TextSpan(
                            text: '안녕하세요, ',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: gray600,
                              fontWeight: FontWeight.w700,
                            ),
                            children: [
                              TextSpan(
                                text: UserStore.to.userProfile.id ?? '',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              TextSpan(
                                text: '님',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: gray600,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
              SizedBox(height: 10.h),
              // card
              Container(
                width: 0.9.sw,
                height: 50.h,
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      // Theme.of(context).colorScheme.primary,
                      // Theme.of(context).colorScheme.secondary,
                      // Theme.of(context).colorScheme.secondary,
                      Color(0xff536DFE),
                      Color(0xff6A3DE8),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(5.r),
                  shape: BoxShape.rectangle,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SvgPicture.asset(
                              'assets/images/ic_payment_card.svg',
                              width: 20.w,
                              height: 20.h,
                              colorFilter: ColorFilter.mode(
                                Theme.of(context).colorScheme.onPrimary,
                                BlendMode.srcIn,
                              ),
                            ),
                            SizedBox(width: 5.w),
                            Text('누적포인트',
                                style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                    fontWeight: FontWeight.w800)),
                          ],
                        ),
                        Text(
                            '${controller.numberFormat(int.parse(UserStore.to.userProfile.point ?? '0'))}P',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                    // 누적 사용내역
                    Container(
                      width: double.infinity,
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () {
                              _logger.d('적립 / 사용내역');
                              Get.toNamed(AppRoutes.bizHistory);
                            },
                            child: Text('적립 / 사용내역',
                                style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                    fontSize: 10.sp,
                                    // underscore
                                    decoration: TextDecoration.underline,
                                    fontWeight: FontWeight.w700)),
                          ),
                          SizedBox(width: 10.w),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: Theme.of(context).colorScheme.onPrimary,
                            size: 10.sp,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
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
                  color: Theme.of(context).colorScheme.background,
                  borderRadius: BorderRadius.circular(20.r),
                  shape: BoxShape.rectangle,
                  border: Border.all(
                    color: controller.isGoodTypeSelectIndex.value == index
                        ? Theme.of(context).colorScheme.primary
                        : gray300,
                    width: 1.w,
                  ),
                ),
                child: Text(
                  controller.goodTypeList[index],
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onBackground,
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
                : _buildBizListApiItem(
                    context, controller.bizSelectList[index]);
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
              /*Positioned(
                top: 5.h,
                left: 5.w,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                  child: CachedNetworkImage(
                    imageUrl: bizModel.brandIconImg!,
                    width: 16.w,
                    height: 16.h,
                    errorWidget: (context, url, error) => Icon(
                      Icons.all_inclusive,
                      color: gray500,
                      size: 20,
                    ),
                    placeholder: (context, url) => CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(gray300),
                    ),
                  ),
                ),
              ),*/
            ],
          ),
        ),
        SizedBox(height: 5.h),
        Text(bizModel.brandName ?? '',
            style: TextStyle(
                fontSize: 10.sp, fontWeight: FontWeight.w500, color: gray600)),
        SizedBox(height: 2.5.h),
        Container(
          alignment: Alignment.center,
          child: Text(bizModel.goodsName ?? '',
              style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onBackground),
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
