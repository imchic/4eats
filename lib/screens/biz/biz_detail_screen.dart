import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foreats/widget/biz_tell_bottomsheet.dart';
import 'package:get/get.dart';

import '../../utils/colors.dart';
import '../../utils/logger.dart';
import '../../widget/base_appbar.dart';
import 'biz_controller.dart';

class BizDetailScreen extends GetView<BizController> {
  const BizDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: BaseAppBar(
        title: '상세보기',
        leading: true,
      ),
      body: _buildBizDetail(context),
    );
  }

  _buildBizDetail(BuildContext context) {
    return Column(
      children: [
        FutureBuilder(
          future: BizController.to.fetchBizApiGoodsDetail(Get.arguments['goods_code']),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else {
              return Obx(() {
                return Column(
                  children: [
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.all(10),
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
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
                                imageUrl:
                                    controller.bizDetail.value.goodsImgS ?? '',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(height: 10.h),
                          // 브랜드명
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10.r),
                                child: Container(
                                  width: 0.1.sw,
                                  height: 0.1.sw,
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
                                      imageUrl: controller.bizDetail.value.brandIconImg ?? '',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              Text('${controller.bizDetail.value.brandName}',
                                  style: TextStyle(
                                      fontSize: 12.sp,
                                      color: gray600,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                          SizedBox(height: 5.h),
                          // 상품명
                          Text('${controller.bizDetail.value.goodsName}',
                              style: TextStyle(
                                  fontSize: 13.sp,
                                  color: gray800,
                                  fontWeight: FontWeight.w600)),

                          SizedBox(height: 30.h),
                          // 교환처 & 유효기간 & 유의사항
                          Container(
                            width: 0.85.sw,
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              children: [
                                // 교환처
                                Divider(
                                  height: 1,
                                  color: gray300,
                                ),
                                SizedBox(height: 10.h),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    // 2:8 text
                                    Text(
                                      '교환처',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: gray600,
                                      ),
                                    ),
                                    Text(
                                      '${controller.bizDetail.value.affiliate}',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: gray800,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10.h),
                                Divider(
                                  height: 1,
                                  color: gray300,
                                ),
                                SizedBox(height: 10.h),
                                // 유효기간
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '유효기간',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: gray600,
                                      ),
                                    ),
                                    Text(
                                      // yyyy-MM-dd
                                      '${convertDate(controller.bizDetail.value.validPrdDay ?? '')}',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: gray800,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10.h),
                                Divider(
                                  height: 1,
                                  color: gray300,
                                ),
                                SizedBox(height: 10.h),
                                // 유의사항
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '유의사항',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: gray600,
                                      ),
                                    ),
                                    SizedBox(height: 10.h),
                                    // scrollable text
                                    SizedBox(
                                      height: 0.18.sh,
                                      child: SingleChildScrollView(
                                        child: Text(
                                          '${controller.bizDetail.value.content}',
                                          style: TextStyle(
                                            fontSize: 10.sp,
                                            color: gray800,
                                            height: 1.5,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {

                        // 파이어베이스 전화번호 연결
                        Get.bottomSheet(
                          BizTellBottomSheet()
                        );
                        //controller.verifyPhoneNumber('+821081312826');

                      },
                      child: Container(
                        width: 350.w,
                        height: 50.h,
                        margin: EdgeInsets.only(bottom: 34.h, top: 20.h, left: 20.w, right: 20.w),
                        padding: EdgeInsets.all(15.r),
                        decoration: ShapeDecoration(
                          color: Theme.of(context).colorScheme.secondary,
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
                              '확인',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                height: 0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                );
              });
            }
          },
        ),
      ],
    );
  }

  convertDate(String date) {

    // yyyy-MM-dd로 만들기
    return '${date.substring(0, 4)}-${date.substring(4, 6)}-${date.substring(6, 8)}';

  }

}
