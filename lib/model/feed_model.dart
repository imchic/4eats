

import 'comment_model.dart';

class FeedModel {
  String? seq;
  String? description;
  String? storeName;
  String? storeAddress;
  String? storeType;
  String? storeMenuInfo;
  String? storeContext;
  String? storeLontlat;
  List<String>? videoUrls;
  List<String>? videoPaths;
  List<String>? thumbnailUrls;
  String? createdAt;
  String? updatedAt;
  String? uid;
  String? userid;
  String? usernickname;
  String? profilePhoto;
  int? likeCount;
  int? bookmarkCount;
  int? point;
  List<String>? hashTags;
  List<List<CommentModel>>? comments;
  bool isLike = false;
  bool isBookmark = false;

  FeedModel({
    this.seq,
    this.description,
    this.storeName,
    this.storeAddress,
    this.storeType,
    this.storeMenuInfo,
    this.storeContext,
    this.storeLontlat,
    this.videoUrls,
    this.videoPaths,
    this.thumbnailUrls,
    this.createdAt,
    this.updatedAt,
    this.uid,
    this.userid,
    this.usernickname,
    this.profilePhoto,
    this.likeCount = 0,
    this.bookmarkCount = 0,
    this.point = 0,
    this.hashTags,
    this.comments,
    this.isBookmark = false,
    this.isLike = false,
  });

  factory FeedModel.fromJson(Map<String, dynamic> json) => FeedModel(
        seq: json["seq"],
        description: json["description"],
        storeName: json["storeName"],
        storeAddress: json["storeAddress"],
        storeType: json["storeType"],
        storeMenuInfo: json["storeMenuInfo"],
        storeContext: json["storeContext"],
        storeLontlat: json["storeLontlat"],
        videoUrls: List<String>.from(json["videoUrls"].map((x) => x)),
        videoPaths: List<String>.from(json["videoPaths"].map((x) => x)),
        thumbnailUrls: List<String>.from(json["thumbnailUrls"].map((x) => x)),
        createdAt: json["createdAt"],
        updatedAt: json["updatedAt"],
        uid: json["uid"],
        userid: json["userid"],
        usernickname: json["usernickname"],
        profilePhoto: json["profilePhoto"],
        likeCount: json["likeCount"],
        bookmarkCount: json["bookmarkCount"],
        point: json["point"],
        hashTags: List<String>.from(json["hashTags"].map((x) => x)),
        isBookmark: json["isBookmark"],
        isLike: json["isLike"],
      );

  Map<String, dynamic> toJson() => {
        "seq": seq,
        "description": description,
        "storeName": storeName,
        "storeAddress": storeAddress,
        "storeType": storeType,
        "storeMenuInfo": storeMenuInfo,
        "storeContext": storeContext,
        "storeLontlat": storeLontlat,
        "videoUrls": List<dynamic>.from(videoUrls!.map((x) => x)),
        "videoPaths": List<dynamic>.from(videoPaths!.map((x) => x)),
        "thumbnailUrls": List<dynamic>.from(thumbnailUrls!.map((x) => x)),
        "createdAt": createdAt,
        "updatedAt": updatedAt,
        "uid": uid,
        "userid": userid,
        "usernickname": usernickname,
        "profilePhoto": profilePhoto,
        "likeCount": likeCount,
        "bookmarkCount": bookmarkCount,
        "point": point,
        "hashTags": List<dynamic>.from(hashTags!.map((x) => x)),
        "isBookmark": isBookmark,
        "isLike": isLike,
      };

  // tostring
  @override
  String toString() {
    return toJson().toString().replaceAll(",", ",\n");
  }

}
