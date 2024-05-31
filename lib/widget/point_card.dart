import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:googleapis/chat/v1.dart';

import '../screens/biz/biz_controller.dart';
import '../screens/login/user_store.dart';
import '../utils/text_style.dart';

class PointCard {

  Widget buildPointCard(BuildContext context) {
    return Container(
      width: 0.9.sw,
      height: 50.h,
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
           Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
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
                      style: TextStyleUtils.bodyTextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700)),
                ],
              ),
              Text(
                  '${BizController.to.numberFormat(int.parse(UserStore.to.user.value.point ?? '0'))}P',
                  style: TextStyleUtils.bodyTextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 10.sp,
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
                Text('적립 / 사용내역',
                    style: TextStyleUtils.bodyTextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700)),
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
    );
  }

}