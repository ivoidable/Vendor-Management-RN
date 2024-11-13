import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vendor/model/product.dart';

enum Activity {
  food,
  accessories,
  entertainment,
  clothing,
  decor,
  miscellaneous,
}

class AppUser {
  String id;
  String name;
  DateTime dateOfBirth;
  String email;
  String? phoneNumber;
  String role;
  List<String> privileges;

  AppUser(
      {required this.id,
      required this.name,
      required this.dateOfBirth,
      this.phoneNumber,
      required this.email,
      required this.role,
      required this.privileges});

  factory AppUser.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() as Map<String, dynamic>;
    switch (data['role']) {
      case 'organizer':
        return Organizer.fromMap(doc.id, data);
      case 'admin':
        return Admin.fromMap(doc.id, data);
      default:
        return Vendor.fromMap(doc.id, data);
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone_number': phoneNumber,
      'privileges': privileges,
      'date_of_birth': dateOfBirth.toIso8601String(),
      'role': role,
    };
  }
}

class Assistant extends AppUser {
  String masterVendorId;

  Assistant({
    required String id,
    required this.masterVendorId,
    required String name,
    required DateTime dateOfBirth,
    required String email,
    required String phoneNumber,
    required super.privileges,
  }) : super(
          id: id,
          name: name,
          email: email,
          phoneNumber: phoneNumber,
          dateOfBirth: dateOfBirth,
          role: 'assistant',
        );

  factory Assistant.fromMap(String id, Map<String, dynamic> data) {
    return Assistant(
      id: id,
      name: data['name'],
      masterVendorId: data['master_vendor_id'],
      dateOfBirth: DateTime.parse(data['date_of_birth']),
      email: data['email'],
      phoneNumber: data['phone_number'],
      privileges: (data['privileges'] as List<dynamic>)
          .map((strin) => strin.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone_number': phoneNumber,
      'privileges': privileges,
      'date_of_birth': dateOfBirth.toIso8601String(),
      'role': role,
      'master_vendor_id': masterVendorId,
    };
  }
}

class Vendor extends AppUser {
  String businessName;
  String logoUrl;
  String? slogan;
  String? instagramUrl;
  String? facebookUrl;
  List<Activity> activities;
  List<Product> products;

  Vendor({
    required String id,
    required String name,
    required DateTime dateOfBirth,
    required String email,
    required this.activities,
    required this.instagramUrl,
    required this.facebookUrl,
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
          role: 'vendor',
        );

  factory Vendor.fromMap(String id, Map<String, dynamic> data) {
    List<Activity> activities = (data['activities'] as List<dynamic>)
        .map((tag) =>
            Activity.values.firstWhere((element) => element.name == tag))
        .toList();
    return Vendor(
      id: id,
      name: data['name'] ?? '',
      facebookUrl: data['facebook_url'] ?? '',
      instagramUrl: data['instagram_url'] ?? '',
      dateOfBirth: DateTime.parse(data['date_of_birth']),
      email: data['email'] ?? "",
      phoneNumber: data['phone_number'] ?? "",
      activities: activities,
      businessName: data['business_name'] ?? '',
      privileges: (data['privileges'] as List<dynamic>)
          .map((strin) => strin.toString())
          .toList(),
      logoUrl: data['logo_url'] ?? '',
      products: (data['products'] as List<dynamic>)
          .map((product) => Product.fromMap((product)))
          .toList(),
      slogan: data['slogan'] ?? '',
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map.addAll({
      'business_name': businessName,
      'logo_url': logoUrl,
      'slogan': slogan,
      'facebook_url': facebookUrl,
      'instagram_url': instagramUrl,
      'activities': activities.map((tag) => tag.name).toList(),
      'products': products.map((product) => product.toMap()).toList(),
    });
    return map;
  }
}

class Organizer extends AppUser {
  Organizer({
    required String id,
    required String name,
    required DateTime dateOfBirth,
    String? phoneNumber,
    required String email,
    super.privileges = const ['canScheduleEvents'],
  }) : super(
          id: id,
          name: name,
          phoneNumber: phoneNumber,
          email: email,
          dateOfBirth: dateOfBirth,
          role: 'organizer',
        );

  factory Organizer.fromMap(String id, Map<String, dynamic> data) {
    return Organizer(
      id: id,
      name: data['name'],
      email: data['email'],
      phoneNumber: data['phone_number'],
      dateOfBirth: DateTime.parse(data['date_of_birth'] as String),
      privileges: List<String>.from(data['privileges'] ?? []),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
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
