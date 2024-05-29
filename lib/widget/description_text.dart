import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class DescriptionText extends StatefulWidget {

  final String text;
  final Color? color;
  final double? fontSize;
  final FontWeight? fontWeight;

  DescriptionText({
    required this.text,
    this.color,
    this.fontSize,
    this.fontWeight,
  });

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
      //margin: EdgeInsets.only(top: 10.h, left: 4.w, bottom: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      child: secondHalf.isEmpty
          ? Text(
              firstHalf,
              style: TextStyle(
                fontSize: widget.fontSize ?? 10.sp,
                color: widget.color ?? Colors.white,
                fontWeight: widget.fontWeight ?? FontWeight.normal,
                height: 1.4,
              ),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // flex
                Text(
                  flag ? (firstHalf + " ...") : (firstHalf + secondHalf),
                  style: TextStyle(
                    fontSize: widget.fontSize ?? 10.sp,
                    color: widget.color ?? Colors.white,
                    fontWeight: widget.fontWeight ?? FontWeight.normal,
                    height: 1.4,
                  ),
                ),
                InkWell(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        flag ? "더보기" : "접기",
                        style: TextStyle(
                          color: Colors.amber,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
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
