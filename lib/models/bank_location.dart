import 'package:geolocator/geolocator.dart';

class BankLocation {
  final int id;
  final String name;
  final String type; // 'bank' or 'atm'
  final double latitude;
  final double longitude;
  final String address;
  final String? bankName;
  final List<String>? services;
  final String? workingHours;
  final String? phoneNumber;

  BankLocation({
    required this.id,
    required this.name,
    required this.type,
    required this.latitude,
    required this.longitude,
    required this.address,
    this.bankName,
    this.services,
    this.workingHours,
    this.phoneNumber,
  });

  factory BankLocation.fromJson(Map<String, dynamic> json) {
    return BankLocation(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      address: json['address'],
      bankName: json['bank_name'],
      services: json['services']?.cast<String>(),
      workingHours: json['working_hours'],
      phoneNumber: json['phone_number'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'bank_name': bankName,
      'services': services?.join(','),
      'working_hours': workingHours,
      'phone_number': phoneNumber,
    };
  }

  double distanceFrom(double userLat, double userLng) {
    return Geolocator.distanceBetween(userLat, userLng, latitude, longitude);
  }
}
