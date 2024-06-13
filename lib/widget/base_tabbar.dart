import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../utils/colors.dart';

class BaseTabBar extends StatefulWidget {

  final List<Tab> tabItems;
  final TabController controller;

  const BaseTabBar({super.key, required this.tabItems, required this.controller});

  @override
  State<BaseTabBar> createState() => _BaseTabBarState();
}

class _BaseTabBarState extends State<BaseTabBar> {

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: widget.controller,
      tabs: widget.tabItems,
      labelColor: Theme.of(context).colorScheme.primary,
      indicatorSize: TabBarIndicatorSize.tab,
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(
          width: 1,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      indicatorPadding: EdgeInsets.symmetric(horizontal: 30.w),
      unselectedLabelColor: textUnselected  ,
      labelStyle: TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w400,
      ),
    );
  }

}