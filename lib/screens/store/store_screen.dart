import 'package:flutter/material.dart';
import 'package:foreats/screens/store/store_controller.dart';
import 'package:get/get.dart';

class StoreScreen extends GetView<StoreController> {
  const StoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Store'),
      ),
      body: const Center(
        child: Text('Store'),
      ),
    );
  }
}