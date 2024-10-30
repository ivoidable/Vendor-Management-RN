import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vendor/helper/database.dart';
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
  final String organizerId;
  final String name;
  final DateTime date;
  final int maxVendors;
  final double vendorFee;
  final double attendeeFee;
  final String location;
  final String description;
  final List<Activity> tags;
  List<Question> questions;
  List<String> appliedVendorsId;
  List<String> registeredVendorsId;
  CollectionReference? applicationsCollection; // Nullable
  List<String> images;

  Event({
    required this.id,
    required this.name,
    required this.date,
    required this.organizerId,
    required this.vendorFee,
    required this.attendeeFee,
    required this.maxVendors,
    required this.location,
    required this.description,
    required this.tags,
    required this.appliedVendorsId,
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
      date: (data['date'] as Timestamp).toDate(),
      location: data['location'] ?? '',
      maxVendors: data['max_vendors'] ?? 0,
      vendorFee: data['vendor_fee'],
      tags: tags,
      registeredVendorsId: List<String>.from(data['registered_vendors']),
      attendeeFee: data['attendee_fee'],
      organizerId: data['organizer_id'],
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
      'date': Timestamp.fromDate(date),
      'location': location,
      'description': description,
      'images': images.toList(),
      'vendor_fee': vendorFee,
      'attendee_fee': attendeeFee,
      'tags': tags.map((tag) => tag.name).toList(),
      'applied_vendors': appliedVendorsId,
      'organizer_id': organizerId,
      'max_vendors': maxVendors,
      'questions': questions.map((question) => question.toMap()).toList(),
      'registered_vendors': registeredVendorsId,
      // No need to store the path since it's a known subcollection path
    };
  }
}
