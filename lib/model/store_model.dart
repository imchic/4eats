import 'package:google_maps_flutter/google_maps_flutter.dart';

class StoreModel {
  final String name;
  final String category;
  final String address;
  final String roadAddress;
  final String? x;
  final String? y;
  final String thumbnail;
  final String distance;

  StoreModel({
    required this.name,
    required this.category,
    required this.address,
    required this.roadAddress,
    required this.x,
    required this.y,
    required this.thumbnail,
    required this.distance,
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    return StoreModel(
      name: json['name'],
      category: json['category'],
      address: json['address'],
      roadAddress: json['roadAddress'],
      x: double.parse(json['x'].toString()).toString(),
      y: double.parse(json['y'].toString()).toString(),
      thumbnail: json['thumbnail'],
      distance: json['distance'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category,
      'address': address,
      'roadAddress': roadAddress,
      'x': x,
      'y': y,
      'thumbnail': thumbnail,
      'distance': distance,
    };
  }

  @override
  String toString() {
    return toJson().toString().replaceAll(',', ',\n');
  }



}