import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

import '../model/map_model.dart';

class MapBottomSheet extends GetWidget {
  final MapModel mapModel;

  const MapBottomSheet({super.key, required this.mapModel});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: // circle in cached networkimage,
                CachedNetworkImage(
              imageUrl: mapModel.thumbnail ?? '',
              imageBuilder: (context, imageProvider) => Container(
                width: 60.w,
                height: 60.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              placeholder: (context, url) => CircularProgressIndicator(),
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),
            title: Text(mapModel.name ?? '',
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis),
            subtitle: Text(mapModel.category ?? '',
                style: TextStyle(fontSize: 16),
                overflow: TextOverflow.ellipsis),
            trailing: Text(
              '${mapModel.distance}m',
              style: TextStyle(fontSize: 14),
            ),
          ),
          SizedBox(height: 10.h),
          ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 20.w),
            minVerticalPadding: 10,
            horizontalTitleGap: 10,
            leading: const Icon(Icons.location_on, color: Colors.red),
            title: Text(mapModel.roadAddress ?? '',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis),
            subtitle: Text(mapModel.address ?? '',
                style: TextStyle(fontSize: 12.sp),
                overflow: TextOverflow.ellipsis),
          ),
          // 상세페이지 진입
          Center(
            child: TextButton(
              onPressed: () {
                // _logger.d('상세페이지 진입');
                // Get.toNamed(AppRoutes.store, arguments: mapModel);
              },
              child: Text('이 가게가 궁금해요!'),
            ),
          ),
        ],
      ),
    );
  }
}
