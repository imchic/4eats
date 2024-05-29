import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {

  String? uid;
  String? id;
  String? nickname;
  String? displayName;
  String? birthdate; // yyyyMMdd
  String? calculateBirthdate; // 만나이
  String? gender;
  String? email;
  String? point = '0';
  String? accessToken;
  String? refreshToken;
  String? fcmToken;
  String? profileImage;
  String? loginType;
  DateTime? createdAt;
  DateTime? updatedAt;

  UserModel({
    this.uid,
    this.id,
    this.nickname,
    this.displayName,
    this.birthdate,
    this.calculateBirthdate,
    this.gender,
    this.email,
    this.point,
    this.accessToken,
    this.refreshToken,
    this.fcmToken,
    this.profileImage,
    this.loginType,
    this.createdAt,
    this.updatedAt,
  });

  UserModel.fromJson(Map<String, dynamic> json) {
    uid = json['uid'];
    id = json['id'];
    nickname = json['nickname'];
    displayName = json['displayName'];
    birthdate = json['birthdate'];
    calculateBirthdate = json['calculateBirthdate'];
    gender = json['gender'];
    email = json['email'];
    point = json['point'];
    accessToken = json['accessToken'];
    refreshToken = json['refreshToken'];
    fcmToken = json['fcmToken'];
    profileImage = json['photoUrl'];
    loginType = json['loginType'];
    createdAt = Timestamp.fromDate(json['createdAt'].toDate()).toDate();
    updatedAt = Timestamp.fromDate(json['updatedAt'].toDate()).toDate();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['uid'] = uid;
    data['id'] = id;
    data['nickname'] = nickname;
    data['displayName'] = displayName;
    data['birthdate'] = birthdate;
    data['calculateBirthdate'] = calculateBirthdate;
    data['gender'] = gender;
    data['email'] = email;
    data['point'] = point;
    data['accessToken'] = accessToken;
    data['refreshToken'] = refreshToken;
    data['fcmToken'] = fcmToken;
    data['photoUrl'] = profileImage;
    data['loginType'] = loginType;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    return data;
  }

  // toString()

  @override
  String toString() {
    // 콤마를 엔터로 치환
    return toJson().toString().replaceAll(',', ',\n');
  }

}