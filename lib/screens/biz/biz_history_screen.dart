import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';

import 'biz_controller.dart';

class BizHistoryScreen extends GetView<BizController> {
  const BizHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('내역'),
      ),
      body: Center(
        child: Text('내역')
      ),
    );
  }
}
