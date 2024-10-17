import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vendor/model/user.dart';

class Event {
  final String id;
  final String name;
  final DateTime date;
  final String location;
  final String description;
  final List<Vendor> registeredVendors;

  Event({
    required this.id,
    required this.name,
    required this.date,
    required this.location,
    required this.description,
    this.registeredVendors = const [],
  });

  // Convert Firestore data to Event object
  factory Event.fromMap(String id, Map<String, dynamic> data) {
    List<Vendor> vendors = (data['registered_vendors'] as List<dynamic>?)
            ?.map((vendorData) => Vendor.fromMap(vendorData['id'], vendorData))
            .toList() ??
        [];

    return Event(
      id: id,
      name: data['name'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      location: data['location'] ?? '',
      description: data['description'] ?? '',
      registeredVendors: vendors,
    );
  }

  // Convert Event object to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'date': Timestamp.fromDate(date),
      'location': location,
      'description': description,
      'registered_vendors':
          registeredVendors.map((vendor) => vendor.toMap()).toList(),
    };
  }
}
