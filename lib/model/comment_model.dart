import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {

  String? commentId;
  String? userId;
  String? userName;
  String? comment;
  // date
  DateTime? createdAt;
  DateTime? updatedAt;
  String? feedId;
  String? replyCount;
  String? likeCount;
  String? userPhotoUrl;
  List<String>? likeUserIds;

  CommentModel({
    this.commentId,
    this.userId,
    this.userName,
    this.comment,
    this.createdAt,
    this.updatedAt,
    this.feedId,
    this.replyCount,
    this.likeCount,
    this.userPhotoUrl,
    this.likeUserIds,
  });

  CommentModel.fromJson(Map<String, dynamic> json) {
    commentId = json['commentId'];
    userId = json['userId'];
    userName = json['userName'];
    comment = json['comment'];
    createdAt = Timestamp.fromDate(json['createdAt'].toDate()).toDate();
    //updatedAt = Timestamp.fromDate(json['updatedAt'].toDate()).toDate();
    feedId = json['feedId'];
    replyCount = json['replyCount'].toString();
    likeCount = json['likeCount'].toString();
    userPhotoUrl = json['userPhotoUrl'];
    likeUserIds = List<String>.from(json['likeUserIds']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['commentId'] = commentId;
    data['userId'] = userId;
    data['userName'] = userName;
    data['comment'] = comment;
    data['createdAt'] = createdAt;
    //data['updatedAt'] = updatedAt;
    data['feedId'] = feedId;
    data['replyCount'] = replyCount;
    data['likeCount'] = likeCount;
    data['userPhotoUrl'] = userPhotoUrl;
    data['likeUserIds'] = likeUserIds;
    return data;
  }

  @override
  String toString() {
    return 'CommentModel{commentId: $commentId, userId: $userId, userName: $userName, comment: $comment, createdAt: $createdAt, updatedAt: $updatedAt, feedId: $feedId, replyCount: $replyCount, likeCount: $likeCount, userPhotoUrl: $userPhotoUrl}';
  }

}