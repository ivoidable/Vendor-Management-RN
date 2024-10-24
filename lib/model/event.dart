import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vendor/model/user.dart';

class Application {
  String id;
  String vendorId;
  String eventId;
  DateTime applicationDate;
  List<Map<String, dynamic>> questions;

  Application({
    required this.id,
    required this.vendorId,
    required this.eventId,
    required this.applicationDate,
    required this.questions,
  });

  factory Application.fromMap(String id, Map<String, dynamic> data) {
    return Application(
      id: id,
      vendorId: data['name'] ?? '',
      eventId: data['event_id'] ?? '',
      applicationDate: (data['application_date'] as Timestamp).toDate(),
      questions: data['questions'],
    );
  }

  // Convert Event object to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vendor_id': vendorId,
      'event_id': eventId,
      'application_date': Timestamp.fromDate(applicationDate),
      'questions': questions,
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
