import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

import '../../model/biz_model.dart';
import '../login/user_store.dart';

class BizController extends GetxController {
  static BizController get to => Get.find();

  var removeTarget = ['전체', '생활', '음악', '주유상품권', '마트상품권', '용역서비스', '올레', '3사 통합데이터 상품', '기타상품권', '백화점상품권', '생활/가전/디지털', '마트', '외식'];

  final _logger = Logger();
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

  @override
  onInit() async {
    super.onInit();
    await fetchBizApiGoodsList(currentPage.value);
    await fetchBrandList();
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
      _logger.e(e);
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
      _logger.e(e);
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
      _logger.e(e);
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
      _logger.e(e);
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
      _logger.e(e);
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
      _logger.e(e);
    }
  }

  // 금액 3자리 콤마
  numberFormat(int number) {
    return number.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
  }
}
