import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  String id;
  String name;
  DateTime dateOfBirth;
  String role;

  AppUser({
    required this.id,
    required this.name,
    required this.dateOfBirth,
    required this.role,
  });

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    switch (data['role']) {
      case 'vendor':
        return Vendor.fromMap(doc.id, data);
      case 'moderator':
        return Moderator.fromMap(doc.id, data);
      case 'admin':
        return Admin.fromMap(doc.id, data);
      default:
        return NormalUser.fromMap(doc.id, data);
    }
  }
}

class NormalUser extends AppUser {
  List<String> favoriteEvents;

  NormalUser({
    required String id,
    required String name,
    required DateTime dateOfBirth,
    this.favoriteEvents = const [],
  }) : super(id: id, name: name, dateOfBirth: dateOfBirth, role: 'normal_user');

  factory NormalUser.fromMap(String id, Map<String, dynamic> data) {
    return NormalUser(
      id: id,
      name: data['name'],
      dateOfBirth: (data['date_of_birth'] as Timestamp).toDate(),
      favoriteEvents: List<String>.from(data['favorite_events'] ?? []),
    );
  }
  
}

class Vendor extends AppUser {
  String businessName;
  String logoUrl;
  String? slogan;
  List<String> products;

  Vendor({
    required String id,
    required String name,
    required DateTime dateOfBirth,
    required this.businessName,
    this.logoUrl = '',
    this.slogan,
    this.products = const [],
  }) : super(id: id,name: name, dateOfBirth: dateOfBirth, role: 'vendor');

  factory Vendor.fromMap(String id, Map<String, dynamic> data) {
    return Vendor(
      id: id,
      name: data['name'] ?? '',
      dateOfBirth: data['date_of_birth'],
      businessName: data['business_name'] ?? '',
      logoUrl: data['logo_url'] ?? '',
      slogan: data['slogan'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'business_name': businessName,
      'logo_url': logoUrl,
      'slogan': slogan,
    };
  }
}

class Moderator extends AppUser {
  List<String> managedEvents;
  List<String> privileges;

  Moderator({
    required String id,
    required String name,
    required DateTime dateOfBirth,
    this.managedEvents = const [],
    this.privileges = const [],
  }) : super(id: id, name: name, dateOfBirth: dateOfBirth, role: 'moderator');

  factory Moderator.fromMap(String id, Map<String, dynamic> data) {
    return Moderator(
      id: id,
      name: data['name'],
      dateOfBirth: (data['date_of_birth'] as Timestamp).toDate(),
      privileges: List<String>.from(data['privileges'] ?? []),
    );
  }
}

class Admin extends AppUser {
  List<String> privileges;

  Admin({
    required String id,
    required String name,
    required DateTime dateOfBirth,
    this.privileges = const ['full_control'],
  }) : super(id: id, name: name, dateOfBirth: dateOfBirth, role: 'admin');

  factory Admin.fromMap(String id, Map<String, dynamic> data) {
    return Admin(
      id: id,
      name: data['name'],
      dateOfBirth: (data['date_of_birth'] as Timestamp).toDate(),
    );
  }
}
