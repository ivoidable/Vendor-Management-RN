import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vendor/model/user.dart';

class Approval {
  bool? approved;
  Approval({
    required this.approved,
  });
  factory Approval.fromMap(Map<String, dynamic> data) {
    return Approval(approved: data['approved']);
  }
  Map<String, dynamic> toMap() {
    return {'approved': approved};
  }
}

class Application {
  String id;
  String vendorId;
  Vendor vendor;
  String eventId;
  DateTime applicationDate;
  Approval approved;
  List<Map<String, dynamic>> questions;

  Application({
    required this.id,
    required this.vendorId,
    required this.vendor,
    required this.eventId,
    required this.applicationDate,
    required this.questions,
    required this.approved,
  });

  factory Application.fromMap(String id, Map<String, dynamic> data) {
    return Application(
      id: id,
      vendorId: data['name'] ?? '',
      vendor: Vendor.fromMap(
          data['vendor_id'], data['vendor'] as Map<String, dynamic>),
      eventId: data['event_id'] ?? '',
      applicationDate: (data['application_date'] as Timestamp).toDate(),
      questions: data['questions'],
      approved: data['approved'],
    );
  }

  // Convert Event object to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vendor_id': vendorId,
      'vendor': vendor.toMap(),
      'event_id': eventId,
      'application_date': Timestamp.fromDate(applicationDate),
      'questions': questions,
      'approved': approved,
    };
  }
}

class Event {
  String id;
  final String organizerId;
  final String name;
  final DateTime date;
  final int maxVendors;
  final String imageUrl;
  final double vendorFee;
  final double attendeeFee;
  final String location;
  final String description;
  List<Map<String, dynamic>> questions;
  List<Vendor> registeredVendors;
  List<Application> applications;

  Event({
    required this.id,
    required this.name,
    required this.date,
    required this.imageUrl,
    required this.organizerId,
    required this.vendorFee,
    required this.attendeeFee,
    required this.maxVendors,
    required this.location,
    required this.description,
    required this.registeredVendors,
    required this.applications,
    required this.questions,
  });

  // Convert Firestore data to Event object
  factory Event.fromMap(String id, Map<String, dynamic> data) {
    List<Vendor> vendors = (data['registered_vendors'] as List<dynamic>?)
            ?.map(
              (vendorData) => Vendor.fromMap(vendorData['id'], vendorData),
            )
            .toList() ??
        [];

    List<Application> applications = (data['applications'] as List<dynamic>?)
            ?.map(
              (application) =>
                  Application.fromMap(application['id'], application),
            )
            .toList() ??
        [];

    return Event(
      id: id,
      name: data['name'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      location: data['location'] ?? '',
      maxVendors: data['max_vendors'] ?? 0,
      vendorFee: data['vendor_fee'],
      attendeeFee: data['attendee_fee'],
      organizerId: data['organizer_id'],
      imageUrl: data['image_url'] ?? '',
      description: data['description'] ?? '',
      registeredVendors: vendors,
      applications: applications,
      questions: data['questions'] as List<Map<String, dynamic>>,
    );
  }

  // Convert Event object to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'date': Timestamp.fromDate(date),
      'location': location,
      'description': description,
      'image_url': imageUrl,
      'vendor_fee': vendorFee,
      'attendee_fee': attendeeFee,
      'organizer_id': organizerId,
      'max_vendors': maxVendors,
      'registered_vendors':
          registeredVendors.map((vendor) => vendor.toMap()).toList(),
      'applications':
          applications.map((application) => application.toMap()).toList(),
    };
  }
}
