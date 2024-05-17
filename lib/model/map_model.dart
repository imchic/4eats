
class MapModel {
  final String? name;
  final String? tel;
  final String? status;
  final String? category;
  final String? address;
  final String? roadAddress;
  final String? x;
  final String? y;
  final String? thumbnail;
  final String? distance;
  final List<String>? menuInfo;
  final List<String>? contextInfo;
  bool? isItemSelect = false;
  bool? isContain = false;

  MapModel({
    this.name,
    this.tel,
    this.status,
    this.category,
    this.address,
    this.roadAddress,
    this.x,
    this.y,
    this.thumbnail,
    this.distance,
    this.menuInfo,
    this.contextInfo,
    this.isItemSelect = false,
    this.isContain = false,
  });

  factory MapModel.fromJson(Map<String, dynamic> json) {
    return MapModel(
      name: json['name'],
      tel: json['tel'],
      status: json['status'],
      category: json['category'],
      address: json['address'],
      roadAddress: json['roadAddress'],
      x: json['x'],
      y: json['y'],
      thumbnail: json['thumbnail'],
      distance: json['distance'],
      menuInfo: json['menuInfo'],
      contextInfo: json['context'],
      isItemSelect: false,
      isContain: false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'tel': tel,
      'status': status,
      'category': category,
      'address': address,
      'roadAddress': roadAddress,
      'x': x,
      'y': y,
      'thumbnail': thumbnail,
      'distance': distance,
      'menuInfo': menuInfo,
      'contextInfo': contextInfo,
      'isItemSelect': isItemSelect,
      'isContain': isContain,
    };
  }

  @override
  String toString() {
    return toJson().toString().replaceAll(',', ',\n');
  }


}
