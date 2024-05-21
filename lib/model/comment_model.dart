import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {

  String? commentId;
  String? userId;
  String? userName;
  String? userNickname;
  String? comment;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? feedId;
  String? replyCount;
  String? likeCount;
  String? userPhotoUrl;
  List<String>? likeUserIds;
  List<CommentModel>? replyCommentList;
  bool isReply = false;

  CommentModel({
    this.commentId,
    this.userId,
    this.userName,
    this.userNickname,
    this.comment,
    this.createdAt,
    this.updatedAt,
    this.feedId,
    this.replyCount,
    this.likeCount,
    this.userPhotoUrl,
    this.likeUserIds,
    this.replyCommentList,
    this.isReply = false,
  });

  CommentModel.fromJson(Map<String, dynamic> json) {
    commentId = json['commentId'];
    userId = json['userId'];
    userName = json['userName'];
    userNickname = json['userNickname'];
    comment = json['comment'];
    createdAt = Timestamp.fromDate(json['createdAt'].toDate()).toDate();
    //updatedAt = Timestamp.fromDate(json['updatedAt'].toDate()).toDate();
    feedId = json['feedId'];
    replyCount = json['replyCount'].toString();
    likeCount = json['likeCount'].toString();
    userPhotoUrl = json['userPhotoUrl'];
    likeUserIds = List<String>.from(json['likeUserIds']);
    if (json['replyCommentList'] != null) {
      replyCommentList = <CommentModel>[];
      json['replyCommentList'].forEach((v) {
        replyCommentList!.add(CommentModel.fromJson(v));
      });
    }
    isReply = json['isReply'];
  }

  // from map
  CommentModel.fromMap(Map<Object, dynamic> map) {
    commentId = map['commentId'];
    userId = map['userId'];
    userName = map['userName'];
    userNickname = map['userNickname'];
    comment = map['comment'];
    createdAt = map['createdAt'].toDate();
    //updatedAt = map['updatedAt'].toDate();
    feedId = map['feedId'];
    replyCount = map['replyCount'].toString();
    likeCount = map['likeCount'].toString();
    userPhotoUrl = map['userPhotoUrl'];
    likeUserIds = List<String>.from(map['likeUserIds']);
    if (map['replyCommentList'] != null) {
      replyCommentList = <CommentModel>[];
      map['replyCommentList'].forEach((v) {
        replyCommentList!.add(CommentModel.fromMap(v));
      });
    }
    isReply = map['isReply'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['commentId'] = commentId;
    data['userId'] = userId;
    data['userName'] = userName;
    data['userNickname'] = userNickname;
    data['comment'] = comment;
    data['createdAt'] = createdAt;
    //data['updatedAt'] = updatedAt;
    data['feedId'] = feedId;
    data['replyCount'] = replyCount;
    data['likeCount'] = likeCount;
    data['userPhotoUrl'] = userPhotoUrl;
    data['likeUserIds'] = likeUserIds;
    if (replyCommentList != null) {
      data['replyCommentList'] = replyCommentList!.map((v) => v.toJson()).toList();
    }
    data['isReply'] = isReply;
    return data;
  }

  @override
  String toString() {
    return toJson().toString().replaceAll(",", ",\n");
  }

}