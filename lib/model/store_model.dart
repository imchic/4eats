import 'package:google_maps_flutter/google_maps_flutter.dart';

class StoreModel {
  final String name;
  final String category;
  final String address;
  final String roadAddress;
  final LatLng latLng;
  final String thumbnail;
  final String distance;

  StoreModel({
    required this.name,
    required this.category,
    required this.address,
    required this.roadAddress,
    required this.latLng,
    required this.thumbnail,
    required this.distance,
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    return StoreModel(
      name: json['name'],
      category: json['category'],
      address: json['address'],
      roadAddress: json['roadAddress'],
      latLng: LatLng(json['latLng']['latitude'], json['latLng']['longitude']),
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
      'latLng': {'latitude': latLng.latitude, 'longitude': latLng.longitude},
      'thumbnail': thumbnail,
      'distance': distance,
    };
  }

  @override
  String toString() {
    return 'StoreModel(name: $name, category: $category, address: $address, roadAddress: $roadAddress, latLng: $latLng, thumbnail: $thumbnail, distance: $distance)';
  }



}