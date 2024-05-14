import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../model/history_model.dart';

class HistoryController extends GetxController with GetSingleTickerProviderStateMixin {

  static HistoryController get to => Get.find();

  late TabController tabController;
  final List<Tab> tabs = <Tab>[
    const Tab(text: '최근 본'),
    const Tab(text: '좋아요한'),
  ];

  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  final _history = <HistoryModel>[].obs;
  List<HistoryModel> get history => _history;

  final RxList<String> _thumbnails = <String>[].obs;
  List<String> get thumbnails => _thumbnails;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: tabs.length, vsync: this);
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }

}