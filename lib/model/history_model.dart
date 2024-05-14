class HistoryModel {
  String? displayName;
  String? videoUrl;
  String? photoUrl;
  String? title;
  String? rating;
  String? like;
  String? point;
  DateTime? createdAt;

  HistoryModel({
    this.displayName,
    this.videoUrl,
    this.photoUrl,
    this.title,
    this.rating,
    this.like,
    this.point,
    this.createdAt,
  });

  factory HistoryModel.fromJson(Map<String, dynamic> json) => HistoryModel(
    displayName: json["displayName"],
    videoUrl: json["videoUrl"],
    photoUrl: json["photoUrl"],
    title: json["title"],
    rating: json["rating"],
    like: json["like"],
    point: json["point"],
    createdAt: json["createdAt"],
  );

  Map<String, dynamic> toJson() => {
    "displayName": displayName,
    "videoUrl": videoUrl,
    "photoUrl": photoUrl,
    "title": title,
    "rating": rating,
    "like": like,
    "point": point,
    "createdAt": createdAt,
  };

  HistoryModel.fromMap(Map<String, dynamic> map) {
    displayName = map['displayName'];
    videoUrl = map['videoUrl'];
    photoUrl = map['photoUrl'];
    title = map['title'];
    rating = map['rating'];
    like = map['like'];
    point = map['point'];
    createdAt = map['createdAt'].toDate();
  }

  Map<String, dynamic> toMap() {
    return {
      'displayName': displayName,
      'videoUrl': videoUrl,
      'photoUrl': photoUrl,
      'title': title,
      'rating': rating,
      'like': like,
      'point': point,
      'createdAt': createdAt,
    };
  }

  DateTime parseDate(dynamic date) {
    if (date is DateTime) {
      return date;
    } else if (date is String) {
      return DateTime.parse(date);
    } else if (date is int) {
      return DateTime.fromMillisecondsSinceEpoch(date);
    } else {
      throw Exception('date type is not supported');
    }
  }

  @override
  String toString() {
    return 'HistoryModel(displayName: $displayName, videoUrl: $videoUrl, photoUrl: $photoUrl, title: $title, rating: $rating, like: $like, point: $point, createdAt: $createdAt)';
  }
}