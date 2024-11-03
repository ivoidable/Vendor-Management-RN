import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';
import 'package:vendor/model/user.dart';

enum Activity {
  food,
  accessories,
  entertainment,
  clothing,
  decor,
  miscellaneous,
}

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
  List<Question> questions;

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
    List<Question> questions = (data['questions'] as List<dynamic>)
        .map((question) => Question.fromMap(question))
        .toList();
    return Application(
      id: id,
      vendorId: data['vendor_id'] ?? '',
      vendor: Vendor.fromMap(
          data['vendor_id'], data['vendor'] as Map<String, dynamic>),
      eventId: data['event_id'] ?? '',
      applicationDate: (data['application_date'] as Timestamp).toDate(),
      questions: questions,
      approved: Approval.fromMap(data['approved']),
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
      'questions': questions.map((que) => que.toMap()).toList(),
      'approved': approved.toMap(),
    };
  }
}

class Question {
  String question;
  String answer;
  Question({
    required this.question,
    required this.answer,
  });
  factory Question.fromMap(Map<String, dynamic> data) {
    return Question(
      question: data['question'],
      answer: data['answer'],
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'answer': answer,
    };
  }
}

class Event {
  String id;
  String organizerId;
  String name;
  DateTime startDate;
  DateTime endDate;
  int maxVendors;
  double vendorFee;
  double attendeeFee;
  String location;
  LatLng latlng;
  String description;
  bool isOneDay;
  List<Activity> tags;
  List<Question> questions;
  List<String> appliedVendorsId;
  List<String> registeredVendorsId;
  List<String> declinedVendorsId;
  CollectionReference? applicationsCollection; // Nullable
  List<String> images;

  Event({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.organizerId,
    required this.vendorFee,
    required this.attendeeFee,
    required this.maxVendors,
    required this.isOneDay,
    required this.location,
    required this.description,
    required this.tags,
    required this.latlng,
    required this.appliedVendorsId,
    required this.declinedVendorsId,
    required this.registeredVendorsId,
    required this.images,
    required this.questions,
    this.applicationsCollection,
  });

  // Convert Firestore data to Event object
  factory Event.fromMap(String id, Map<String, dynamic> data) {
    List<Question> questions = (data['questions'] as List<dynamic>)
        .map((question) => Question.fromMap(question))
        .toList();

    List<Activity> tags = (data['tags'] as List<dynamic>)
            .map((tag) =>
                Activity.values.firstWhere((element) => element.name == tag))
            .toList() ??
        [];

    // Reinitialize the subcollection reference if it exists
    CollectionReference? collectionRef =
        FirebaseFirestore.instance.collection('events/$id/applications');

    return Event(
      id: id,
      name: data['name'] ?? '',
      startDate: (data['start_date'] as Timestamp).toDate(),
      endDate: (data['end_date'] as Timestamp).toDate(),
      location: data['location'] ?? '',
      maxVendors: data['max_vendors'] ?? 0,
      tags: tags,
      isOneDay: data['is_one_day'] ?? false,
      latlng: LatLng(data['lat'] ?? 0.0, data['lng'] ?? 0.0),
      registeredVendorsId: List<String>.from(data['registered_vendors']),
      attendeeFee: double.parse(data['attendee_fee'].toString()),
      vendorFee: double.parse(data['vendor_fee'].toString()),
      organizerId: data['organizer_id'],
      declinedVendorsId: List<String>.from(data['declined_vendors']),
      appliedVendorsId: List<String>.from(data['applied_vendors']),
      images: (data['images'] as List<dynamic>)
          .map((stri) => stri.toString())
          .toList(),
      applicationsCollection: collectionRef,
      description: data['description'] ?? '',
      questions: questions,
    );
  }

  // Convert Event object to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'start_date': Timestamp.fromDate(startDate),
      'end_date': Timestamp.fromDate(endDate),
      'location': location,
      'description': description,
      'images': images.toList(),
      'vendor_fee': vendorFee,
      'attendee_fee': attendeeFee,
      'lat': latlng.latitude,
      'lng': latlng.longitude,
      'is_one_day': isOneDay,
      'tags': tags.map((tag) => tag.name).toList(),
      'applied_vendors': appliedVendorsId,
      'organizer_id': organizerId,
      'declined_vendors': declinedVendorsId,
      'max_vendors': maxVendors,
      'questions': questions.map((question) => question.toMap()).toList(),
      'registered_vendors': registeredVendorsId,
      // No need to store the path since it's a known subcollection path
    };
  }
}
