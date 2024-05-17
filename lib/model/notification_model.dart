class NotificationModel {
  String? title;
  String? body;
  String? imageUrl;
  String? deepLink;

  NotificationModel({
    this.title,
    this.body,
    this.imageUrl,
    this.deepLink,
  });

  NotificationModel.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    body = json['body'];
    imageUrl = json['imageUrl'];
    deepLink = json['deepLink'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['body'] = body;
    data['imageUrl'] = imageUrl;
    data['deepLink'] = deepLink;
    return data;
  }

  @override
  String toString() {
    return toJson().toString().replaceAll(",", ",\n");
  }

}