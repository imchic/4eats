import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:foreats/utils/toast_controller.dart';
import 'package:foreats/utils/logger.dart';
import 'package:get/get.dart';

import '../../model/biz_model.dart';

class BizController extends GetxController {
  static BizController get to => Get.find();

  final _auth = FirebaseAuth.instance;

  var removeTarget = ['전체', '생활', '음악', '주유상품권', '마트상품권', '용역서비스', '올레', '3사 통합데이터 상품', '기타상품권', '백화점상품권', '생활/가전/디지털', '마트', '외식'];

  final _logger = AppLog.to;
  final Dio _dio = Dio();

  RxInt currentPage = 1.obs;
  RxInt totalPage = 0.obs;
  RxList<BizModel> bizList = <BizModel>[].obs;
  RxList<BizModel> bizSelectList = <BizModel>[].obs;
  Rx<BizModel> bizDetail = BizModel().obs;
  RxList<String> brandNameList = <String>[].obs;
  RxList<String> brandIconList = <String>[].obs;
  RxList<String> goodTypeList = <String>[].obs;

  RxBool isAll = true.obs;
  RxInt isGoodTypeSelectIndex = 0.obs;

  RxBool isSent = false.obs;
  RxBool isVerify = false.obs;
  RxString verificationId = ''.obs;

  @override
  onInit() async {
    super.onInit();
    await fetchBizApiGoodsList(currentPage.value);
    await fetchBrandList();
    isSent.value = false;
  }

  // 페이지 변경
  Future<void> moveToGoodsPage(int index) async {
    currentPage.value = index;
    bizList.clear();
    _logger.i('currentIndex: $currentPage');
    await fetchBizApiGoodsList(index);
  }

  // 상품 정보 리스트 조회
  Future<void> fetchBizApiGoodsList(index) async {
    bizList.clear();

    try {
      final response = await _dio
          .post(
            'https://bizapi.giftishow.com/bizApi/goods',
            queryParameters: {
              'api_code': '0101',
              'custom_auth_code': 'REAL809d908417d047959d1e172c867c215d',
              'custom_auth_token': '/p4gxutM0PPdKpthDoY18w==',
              'dev_yn': 'N',
              'start': index.toString(),
              'size': '100000',
            },
            options: Options(
              headers: {
                'Content-Type': 'application/json',
                'api_code': '0101',
                'custom_auth_code': 'REAL809d908417d047959d1e172c867c215d',
                'custom_auth_token': '/p4gxutM0PPdKpthDoY18w==',
                'dev_flag': 'N',
              },
            ),
            onSendProgress: (int sent, int total) {},
            onReceiveProgress: (int received, int total) {},
          )
          .timeout(const Duration(seconds: 10));

      response.data['result']['goodsList'].forEach((element) {
        var model = BizModel.fromJson(element);
        bizList.add(model);
      });

      // sort by salePrice
      bizList.sort((a, b) => a.salePrice!.compareTo(b.salePrice!));

      bizList.sort((a, b) => a.goodsTypeDtlNm!.compareTo(b.goodsTypeDtlNm!));

      // 만원이상 제거
      bizList.removeWhere((element) => int.parse(element.salePrice!) >= 10000);

      // 특수 카테고리 제거
      bizList.removeWhere((element) => removeTarget.contains(element.goodsTypeDtlNm));

      isAll.value = true;
    } catch (e) {
      _logger.e(e.toString());
    }
  }

  // 브랜드 정보 조회
  Future<void> fetchBrandList() async {
    // 브랜드 취합
    try {
      brandNameList.clear();
      brandIconList.clear();
      goodTypeList.clear();

      brandNameList = bizList.map((e) => e.brandName!).toSet().toList().obs;
      brandIconList = bizList.map((e) => e.brandIconImg!).toSet().toList().obs;
      goodTypeList = bizList.map((e) => e.goodsTypeDtlNm!).toSet().toList().obs;

      goodTypeList.removeWhere((element) => removeTarget.contains(element));

      // 전체 추가
      brandNameList.insert(0, '전체');
      brandIconList.insert(0, '');
      goodTypeList.insert(0, '전체');

      _logger.d('goodTypeList: $goodTypeList');
    } catch (e) {
      _logger.e(e.toString());
    }
  }

  // 브랜드 선택 조회
  Future<void> fetchBrandSelectList(String category) async {
    try {
      // 기존 데이터 내에서 일치하는 브랜드만 재 배열
      bizSelectList.clear();

      if (category == '전체') {
        isAll.value = true;
        return;
      }

      for (var element in bizList) {
        if (element.goodsTypeDtlNm == category) {
          bizSelectList.add(element);
        }
      }

      isAll.value = false;
    } catch (e) {
      _logger.e(e.toString());
    }
  }

  // 카테고리 선택 조회
  Future<void> fetchGoodsTypeSelectList(String goodsType, int selectIndex) async {
    try {
      // 기존 데이터 내에서 일치하는 브랜드만 재 배열
      bizSelectList.clear();

      if (goodsType == '전체') {
        isAll.value = true;
        isGoodTypeSelectIndex.value = 0;
        return;
      }

      for (var element in bizList) {
        if (element.goodsTypeDtlNm == goodsType) {
          bizSelectList.add(element);
          isGoodTypeSelectIndex.value = selectIndex;
        }
      }

      isAll.value = false;
      isGoodTypeSelectIndex.value = selectIndex;

    } catch (e) {
      _logger.e(e.toString());
    }
  }

  Future<void> fetchDetailApiGoodsList(goodsCode) async {
    try {
      final response = await _dio.post(
        'https://bizapi.giftishow.com/bizApi/goods',
        queryParameters: {
          'api_code': '0101',
          'custom_auth_code': 'REAL809d908417d047959d1e172c867c215d',
          'custom_auth_token': '/p4gxutM0PPdKpthDoY18w==',
          'dev_yn': 'N',
          'start': '1',
          'size': '20',
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'api_code': '0101',
            'custom_auth_code': 'REAL809d908417d047959d1e172c867c215d',
            'custom_auth_token': '/p4gxutM0PPdKpthDoY18w==',
            'dev_flag': 'N',
          },
        ),
        onSendProgress: (int sent, int total) {
          // _logger.i('sent: $sent, total: $total');
        },
        onReceiveProgress: (int received, int total) {
          // _logger.i('received: $received, total: $total');
        },
      ).timeout(const Duration(seconds: 10));
      //_logger.i('response: ${response.data['result']['listNum']}');

      //totalPage.value = (response.data['result']['listNum'] / 20).ceil();

      response.data['result']['goodsList'].forEach((element) {
        var model = BizModel.fromJson(element);
        _logger.i('model: ${model.limitday}');
        bizList.add(model);
      });
    } catch (e) {
      _logger.e(e.toString());
    }
  }

  Future<void> fetchBizApiGoodsDetail(String goodsCode) async {
    try {
      final response = await _dio.post(
        'https://bizapi.giftishow.com/bizApi/goods/$goodsCode',
        queryParameters: {
          'api_code': '0111',
          'custom_auth_code': 'REAL809d908417d047959d1e172c867c215d',
          'custom_auth_token': '/p4gxutM0PPdKpthDoY18w==',
          'dev_yn': 'N',
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'api_code': '0111',
            'custom_auth_code': 'REAL809d908417d047959d1e172c867c215d',
            'custom_auth_token': '/p4gxutM0PPdKpthDoY18w==',
            'dev_flag': 'N',
          },
        ),
        onSendProgress: (int sent, int total) {
          // _logger.i('sent: $sent, total: $total');
        },
        onReceiveProgress: (int received, int total) {
          // _logger.i('received: $received, total: $total');
        },
      ).timeout(const Duration(seconds: 10));

      _logger.i('response: ${response.data['result']}');

    } catch (e) {
      _logger.e(e.toString());
    }
  }

  // 금액 3자리 콤마
  numberFormat(int number) {
    return number.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
  }

  /// 전화번호 인증
  Future<void> verifyPhoneNumber(String tellNum) async {
    try {

      isSent.value = false;
      isVerify.value = false;

      var phoneNumber = '+82${tellNum.substring(1)}';

      _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          _logger.e(e.toString());
        },
        codeSent: (String verificationId, int? resendToken) {
          _logger.i('verificationId: $verificationId');
          _logger.i('resendToken: $resendToken');
          isVerify.value = true;
          this.verificationId.value = verificationId;
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _logger.i('verificationId: $verificationId');
        },
      );

      isSent.value = true;

    } catch (e) {
      _logger.e(e.toString());
    }
  }

  // 인증번호 확인
  Future<void> verifyCode(String code) async {
    try {

      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId.value,
        smsCode: code,
      );

      // 인증번호 확인
      await _auth.signInWithCredential(credential).then((value) {
        _logger.i('value: $value');
        // if(value.user != null) {
        //   GlobalToastController.to.showToast('인증되었습니다.');
        //   isVerify.value = false;
        // } else {
        //   GlobalToastController.to.showToast('인증번호가 일치하지 않습니다.');
        //   isVerify.value = true;
        // }
        try {
          if (value.user != null) {
            ToastController.to.showToast('인증되었습니다.');
            isVerify.value = false;
            Get.back();
          } else {
            ToastController.to.showToast('인증번호가 일치하지 않습니다.');
            isVerify.value = true;
          }
        } catch (e) {
          if (e is FirebaseAuthException) {
            ToastController.to.showToast('인증번호가 일치하지 않습니다.');
            isVerify.value = true;
          } else {
            _logger.e(e.toString());
          }
        }
      });

    } catch (e) {
      _logger.e(e.toString());
    }
  }

}
