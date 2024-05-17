import 'package:get/get.dart';
import 'package:logger/logger.dart';

class AppLog extends GetxController {
  static AppLog get to => Get.find();

  final logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: false,
    )
  );

  void i(String message) {
    logger.i(message);
  }

  void d(String message) {
    logger.d(message);
  }

  void e(String message) {
    logger.e(message);
  }

  void w(String message) {
    logger.w(message);
  }

  void v(String message) {
    logger.v(message);
  }

  void wtf(String message) {
    logger.wtf(message);
  }

}