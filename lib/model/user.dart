import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vendor/model/product.dart';

class AppUser {
  String id;
  String name;
  DateTime dateOfBirth;
  String email;
  String? phoneNumber;
  String role;
  List<String> privileges;

  AppUser({
    required this.id,
    required this.name,
    required this.dateOfBirth,
    this.phoneNumber,
    required this.email,
    required this.role,
    required this.privileges
  });

  factory AppUser.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() as Map<String, dynamic>;
    switch (data['role']) {
      case 'vendor':
        return Vendor.fromMap(doc.id, data);
      case 'moderator':
        return Organizer.fromMap(doc.id, data);
      case 'admin':
        return Admin.fromMap(doc.id, data);
      default:
        return NormalUser.fromMap(doc.id, data);
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone_number': phoneNumber,
      'privileges': privileges,
      'date_of_birth': dateOfBirth.toIso8601String(),
      'role': role,
    };
  }
}

class NormalUser extends AppUser {
  List<String> favorite_vendors;

  NormalUser({
    required String id,
    required String name,
    required DateTime dateOfBirth,
    String? phoneNumber,
    required String email,
    this.favorite_vendors = const [],
    required super.privileges
  }) : super(
            id: id,
            name: name,
            email: email,
            phoneNumber: phoneNumber,
            dateOfBirth: dateOfBirth,
            role: 'normal_user');

  factory NormalUser.fromMap(String id, Map<String, dynamic> data) {
    return NormalUser(
      id: id,
      name: data['name'],
      email: data['email'],
      phoneNumber: data['phoneNumber'],
      privileges: data['privileges'] as List<String>,
      dateOfBirth: (data['date_of_birth'] as Timestamp).toDate(),
      favorite_vendors: List<String>.from(data['favorite_events'] ?? []),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map.addAll({'favorite_vendors': favorite_vendors});
    return map;
  }
}

class Vendor extends AppUser {
  String businessName;
  String logoUrl;
  String? slogan;
  List<Product> products;

  Vendor({
    required String id,
    required String name,
    required DateTime dateOfBirth,
    required String email,
    String? phoneNumber,
    required this.businessName,
    this.logoUrl = '',
    this.slogan,
    required super.privileges,
    required this.products,
  }) : super(
            id: id,
            name: name,
            email: email,
            phoneNumber: phoneNumber,
            dateOfBirth: dateOfBirth,
            role: 'vendor',);

  factory Vendor.fromMap(String id, Map<String, dynamic> data) {
    return Vendor(
      id: id,
      name: data['name'] ?? '',
      dateOfBirth: data['date_of_birth'],
      email: data['email'],
      phoneNumber: data['phone_number'],
      businessName: data['business_name'] ?? '',
      privileges: data['privileges'],
      logoUrl: data['logo_url'] ?? '',
      products: (data['products'] as List<Map<String,dynamic>>).map((product) => Product.fromMap(product)).toList(),
      slogan: data['slogan'] ?? '',
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map.addAll(
        {'business_name': businessName, 'logo_url': logoUrl, 'slogan': slogan, 'products': products.map((product) => product.toMap()).toList()});
    return map;
  }
}

class Organizer extends AppUser {
  List<String> managedEvents;

  Organizer({
    required String id,
    required String name,
    required DateTime dateOfBirth,
    String? phoneNumber,
    required String email,
    this.managedEvents = const [],
    super.privileges = const ['canScheduleEvents'],
  }) : super(
            id: id,
            name: name,
            phoneNumber: phoneNumber,
            email: email,
            dateOfBirth: dateOfBirth,
            role: 'organizer');

  factory Organizer.fromMap(String id, Map<String, dynamic> data) {
    return Organizer(
      id: id,
      name: data['name'],
      email: data['email'],
      phoneNumber: data['phone_number'],
      dateOfBirth: (data['date_of_birth'] as Timestamp).toDate(),
      privileges: List<String>.from(data['privileges'] ?? []),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map.addAll(
        {'business_name': managedEvents});
    return map;
  }
}

class Admin extends AppUser {

  Admin({
    required String id,
    required String name,
    required String email,
    String? phoneNumber,
    required DateTime dateOfBirth,
    super.privileges = const ['admin'],
  }) : super(
            id: id,
            name: name,
            email: email,
            phoneNumber: phoneNumber,
            dateOfBirth: dateOfBirth,
            role: 'admin');

  factory Admin.fromMap(String id, Map<String, dynamic> data) {
    return Admin(
      id: id,
      name: data['name'],
      email: data['email'],
      phoneNumber: data['phone_number'],
      privileges: data['privileges'],
      dateOfBirth: (data['date_of_birth'] as Timestamp).toDate(),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    return map;
  }
}
