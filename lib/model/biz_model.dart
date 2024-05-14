class BizModel {

  String? code;
  String? message;
  String? listNum;
  String? goodsCode;
  String? goodsNo;
  String? goodsName;
  String? brandCode;
  String? brandName;
  String? content;
  String? contentAddDesc;
  String? discountRate;
  String? goodstypeNm;
  String? goodsImgS;
  String? goodsImgB;
  String? goodsDescImgWeb;
  String? brandIconImg;
  String? mmsGoodsImg;
  String? discountPrice;
  String? realPrice;
  String? salePrice;
  String? srchKeyword;
  String? validPrdTypeCd;
  String? limitday;
  String? validPrdDay;
  String? endDate;
  String? goodsComId;
  String? goodsComName;
  String? affiliateId;
  String? affiliate;
  String? exhGenderCd;
  String? exhAgeCd;
  String? mmsReserveFlag;
  String? goodsStateCd;
  String? mmsBarcdCreateYn;
  String? rmCntFlag;
  String? saleDateFlagCd;
  String? goodsTypeDtlNm;
  String? category1Seq;
  String? saleDateFlag;
  String? rmIdBuyCntFlagCd;

  BizModel({
    this.code,
    this.message,
    this.listNum,
    this.goodsCode,
    this.goodsNo,
    this.goodsName,
    this.brandCode,
    this.brandName,
    this.content,
    this.contentAddDesc,
    this.discountRate,
    this.goodstypeNm,
    this.goodsImgS,
    this.goodsImgB,
    this.goodsDescImgWeb,
    this.brandIconImg,
    this.mmsGoodsImg,
    this.discountPrice,
    this.realPrice,
    this.salePrice,
    this.srchKeyword,
    this.validPrdTypeCd,
    this.limitday,
    this.validPrdDay,
    this.endDate,
    this.goodsComId,
    this.goodsComName,
    this.affiliateId,
    this.affiliate,
    this.exhGenderCd,
    this.exhAgeCd,
    this.mmsReserveFlag,
    this.goodsStateCd,
    this.mmsBarcdCreateYn,
    this.rmCntFlag,
    this.saleDateFlagCd,
    this.goodsTypeDtlNm,
    this.category1Seq,
    this.saleDateFlag,
    this.rmIdBuyCntFlagCd,
  });

  factory BizModel.fromJson(Map<String, dynamic> json) => BizModel(
    code: json["code"],
    message: json["message"],
    listNum: json["listNum"],
    goodsCode: json["goodsCode"],
    goodsNo: json["goodsNo"].toString(),
    goodsName: json["goodsName"],
    brandCode: json["brandCode"],
    brandName: json["brandName"],
    content: json["content"],
    contentAddDesc: json["contentAddDesc"],
    discountRate: json["discountRate"].toString(),
    goodstypeNm: json["goodstypeNm"],
    goodsImgS: json["goodsImgS"],
    goodsImgB: json["goodsImgB"],
    goodsDescImgWeb: json["goodsDescImgWeb"],
    brandIconImg: json["brandIconImg"],
    mmsGoodsImg: json["mmsGoodsImg"],
    discountPrice: json["discountPrice"].toString(),
    realPrice: json["realPrice"].toString(),
    salePrice: json["salePrice"].toString(),
    srchKeyword: json["srchKeyword"],
    validPrdTypeCd: json["validPrdTypeCd"],
    limitday: json["limitday"],
    validPrdDay: json["validPrdDay"],
    endDate: json["endDate"],
    goodsComId: json["goodsComId"],
    goodsComName: json["goodsComName"],
    affiliateId: json["affiliateId"],
    affiliate: json["affiliate"],
    exhGenderCd: json["exhGenderCd"],
    exhAgeCd: json["exhAgeCd"],
    mmsReserveFlag: json["mmsReserveFlag"],
    goodsStateCd: json["goodsStateCd"],
    mmsBarcdCreateYn: json["mmsBarcdCreateYn"],
    rmCntFlag: json["rmCntFlag"],
    saleDateFlagCd: json["saleDateFlagCd"],
    goodsTypeDtlNm: json["goodsTypeDtlNm"],
    category1Seq: json["category1Seq"].toString(),
    saleDateFlag: json["saleDateFlag"],
    rmIdBuyCntFlagCd: json["rmIdBuyCntFlagCd"],
  );

  Map<String, dynamic> toJson() => {
    "code": code,
    "message": message,
    "listNum": listNum,
    "goodsCode": goodsCode,
    "goodsNo": goodsNo,
    "goodsName": goodsName,
    "brandCode": brandCode,
    "brandName": brandName,
    "content": content,
    "contentAddDesc": contentAddDesc,
    "discountRate": discountRate,
    "goodstypeNm": goodstypeNm,
    "goodsImgS": goodsImgS,
    "goodsImgB": goodsImgB,
    "goodsDescImgWeb": goodsDescImgWeb,
    "brandIconImg": brandIconImg,
    "mmsGoodsImg": mmsGoodsImg,
    "discountPrice": discountPrice,
    "realPrice": realPrice,
    "salePrice": salePrice,
    "srchKeyword": srchKeyword,
    "validPrdTypeCd": validPrdTypeCd,
    "limitday": limitday,
    "validPrdDay": validPrdDay,
    "endDate": endDate,
    "goodsComId": goodsComId,
    "goodsComName": goodsComName,
    "affiliateId": affiliateId,
    "affiliate": affiliate,
    "exhGenderCd": exhGenderCd,
    "exhAgeCd": exhAgeCd,
    "mmsReserveFlag": mmsReserveFlag,
    "goodsStateCd": goodsStateCd,
    "mmsBarcdCreateYn": mmsBarcdCreateYn,
    "rmCntFlag": rmCntFlag,
    "saleDateFlagCd": saleDateFlagCd,
    "goodsTypeDtlNm": goodsTypeDtlNm,
    "category1Seq": category1Seq,
    "saleDateFlag": saleDateFlag,
    "rmIdBuyCntFlagCd": rmIdBuyCntFlagCd,
  };



}