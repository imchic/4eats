

import 'comment_model.dart';

class FeedModel {
  String? seq;
  String? description;
  String? storeName;
  String? storeAddress;
  String? storeType;
  String? storeMenuInfo;
  String? storeContext;
  String? storeLngLat;
  List<String>? videoUrls;
  List<String>? thumbnailUrls;
  String? createdAt;
  String? updatedAt;
  String? uid;
  String? userid;
  String? userNickname;
  String? userProfilePhoto;
  String? userFcmToken;
  int? likeCount;
  int? bookmarkCount;
  int? point;
  List<String>? hashTags;
  List<List<CommentModel>>? comments;
  bool isLike = false;
  bool isBookmark = false;
  int? commentCount;

  FeedModel({
    this.seq,
    this.description,
    this.storeName,
    this.storeAddress,
    this.storeType,
    this.storeMenuInfo,
    this.storeContext,
    this.storeLngLat,
    this.videoUrls,
    this.thumbnailUrls,
    this.createdAt,
    this.updatedAt,
    this.uid,
    this.userid,
    this.userNickname,
    this.userProfilePhoto,
    this.userFcmToken,
    this.likeCount = 0,
    this.bookmarkCount = 0,
    this.point = 0,
    this.hashTags,
    this.comments,
    this.isBookmark = false,
    this.isLike = false,
    this.commentCount = 0,
  });

  factory FeedModel.fromJson(Map<String, dynamic> json) => FeedModel(
        seq: json["seq"],
        description: json["description"],
        storeName: json["storeName"],
        storeAddress: json["storeAddress"],
        storeType: json["storeType"],
        storeMenuInfo: json["storeMenuInfo"],
        storeContext: json["storeContext"],
        storeLngLat: json["storeLngLat"],
        videoUrls: List<String>.from(json["videoUrls"].map((x) => x)),
        thumbnailUrls: List<String>.from(json["thumbnailUrls"].map((x) => x)),
        createdAt: json["createdAt"],
        updatedAt: json["updatedAt"],
        uid: json["uid"],
        userid: json["userid"],
        userNickname: json["userNickname"],
        userProfilePhoto: json["userProfilePhoto"],
        userFcmToken: json["userFcmToken"],
        likeCount: json["likeCount"],
        bookmarkCount: json["bookmarkCount"],
        point: json["point"],
        hashTags: List<String>.from(json["hashTags"].map((x) => x)),
        isBookmark: json["isBookmark"],
        isLike: json["isLike"],
        comments: List<List<CommentModel>>.from(json["comments"].map((x) => List<CommentModel>.from(x.map((x) => CommentModel.fromJson(x))))),
        commentCount: json["commentCount"],
      );

  Map<String, dynamic> toJson() => {
        "seq": seq,
        "description": description,
        "storeName": storeName,
        "storeAddress": storeAddress,
        "storeType": storeType,
        "storeMenuInfo": storeMenuInfo,
        "storeContext": storeContext,
        "storeLngLat": storeLngLat,
        "videoUrls": List<dynamic>.from(videoUrls!.map((x) => x)),
        "thumbnailUrls": List<dynamic>.from(thumbnailUrls!.map((x) => x)),
        "createdAt": createdAt,
        "updatedAt": updatedAt,
        "uid": uid,
        "userid": userid,
        "userNickname": userNickname,
        "userProfilePhoto": userProfilePhoto,
        "userFcmToken": userFcmToken,
        "likeCount": likeCount,
        "bookmarkCount": bookmarkCount,
        "point": point,
        "hashTags": List<dynamic>.from(hashTags!.map((x) => x)),
        "isBookmark": isBookmark,
        "isLike": isLike,
        "comments": List<dynamic>.from(comments!.map((x) => List<dynamic>.from(x.map((x) => x.toJson())))),
        "commentCount": commentCount,
      };

  // tostring
  @override
  String toString() {
    return toJson().toString().replaceAll(",", ",\n");
  }

}
