import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class DescriptionText extends StatefulWidget {
  final String text;

  const DescriptionText({super.key, required this.text});

  @override
  _DescriptionTextState createState() => _DescriptionTextState();
}

class _DescriptionTextState extends State<DescriptionText> {
  late String firstHalf;
  late String secondHalf;

  bool flag = true;

  @override
  void initState() {
    super.initState();

    if (widget.text.length > 50) {
      firstHalf = widget.text.substring(0, 50);
      secondHalf = widget.text.substring(50, widget.text.length);
      flag = true;
    } else {
      firstHalf = widget.text;
      secondHalf = "";
      flag = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 10.h, left: 4.w),
      child: secondHalf.isEmpty
          ? Text(
              firstHalf,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.white,
              ),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                InkWell(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: Get.width * 0.7,
                        child: Text(
                          flag ? (firstHalf + "...") : (firstHalf + secondHalf),
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Container(
                        child: Text(
                          flag ? "더보기" : "접기",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.tertiary,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    setState(() {
                      flag = !flag;
                    });
                  },
                ),
              ],
            ),
    );
  }
}
