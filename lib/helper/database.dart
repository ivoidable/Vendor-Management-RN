import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vendor/main.dart';
import 'package:vendor/model/event.dart';
import 'package:vendor/model/product.dart';
import 'package:vendor/model/review.dart';
import 'package:vendor/model/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;

  String constructFCMPayload(String? token) {
    return jsonEncode({
      'token': token,
      'notification': {
        'via': 'FlutterFire Cloud Messaging!!!',
      },
      'notification': {
        'title': 'Hello FlutterFire!',
        'body': 'This notification (#) was created via FCM!',
      },
    });
  }

  Future<void> sendNotification(
      List<String> tokens, String title, String message) async {
    const serverKey =
        'AIzaSyBqZY9YGYb9cvB5Ub8DCtEp4AVo06EH9bM'; // Replace with your Firebase server key
    final url = Uri.parse('https://fcm.googleapis.com/fcm/send');

    final payload = {
      'registration_ids': tokens,
      'notification': {
        'title': title,
        'body': message,
      },
      'priority': 'high',
    };

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'key=$serverKey',
    };

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200) {
      print('Notification sent successfully');
    } else {
      print('Failed to send notification: ${response.body}');
    }
  }

  Future<bool> createEvent(Event event, List<String> images) async {
    try {
      var doc = _db.collection('events').doc();
      event.id = doc.id;
      for (int i = 0; i < images.length; i++) {
                            var result = await DatabaseService()
                                .uploadEventImageAndGetUrl(
                                    XFile(images[i]),
                                    doc.id, i.toString(),);

                            if (result != null) {
                              event.images.add(result);
                            }
                          }
      doc.set(event.toMap());
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Stream<Event?> getRegisteredVendorsStream(String eventId) {
    return _db.collection('events').doc(eventId).snapshots().map((event) {
      if (event.exists && event.data() != null) {
        return Event.fromMap(event.id, event.data()!);
      }
    });
  }

  Future<String?> uploadReviewImageAndGetUrl(
      XFile imageFile, String reviewId) async {
    try {
      final storageRef =
          FirebaseStorage.instance.ref().child('$reviewId/image');
      await storageRef.putFile(File(imageFile.path));

      print("File uploaded successfully!");
      return storageRef.getDownloadURL();
    } catch (e) {
      print("Error uploading file: $e");
      return null;
    }
  }

  void reviewOrganizer(Review review, String organizerId, XFile image) async {
    // Add the review to the organizer's reviews collection
    var doc =
        _db.collection('users').doc(organizerId).collection('reviews').doc();
    review.id = doc.id;
    String? url = await uploadReviewImageAndGetUrl(
      image,
      review.id,
    );

    if (url != null) {
      review.imagesUrls.add(url);
    }
    doc.set(review.toMap());
  }

  Future<List<Vendor>> getRegisteredVendorsQuery(String eventId) async {
    Event? event =
        await _db.collection('events').doc(eventId).get().then((event) {
      return Event.fromMap(event.id, event.data()!);
    });

    var doc = (await _db
        .collection('users')
        .where('id', whereIn: event!.registeredVendorsId)
        .get());

    List<Vendor> vends = doc.docs
        .map((vendor) => Vendor.fromMap(vendor.id, vendor.data()))
        .toList();
    return vends;
  }

  Future<void> uploadLogo(XFile imageFile, String userId) async {
    try {
      // Get the file extension from the XFile's mime type
      String extension = imageFile.mimeType?.split('/').last ?? 'jpg';

      // Create a reference to the Firebase Storage location
      final storageRef =
          FirebaseStorage.instance.ref().child('$userId/logo/image.$extension');

      // Upload the file
      await storageRef.putFile(File(imageFile.path));
      updateUser(userId, {
        'logo_url': await storageRef.getDownloadURL(),
      });

      print("File uploaded successfully!");
    } catch (e) {
      print("Error uploading file: $e");
    }
  }

  Future<String?> getLogoUrl(String userId) async {
    try {
      // Define the path to the user's logo image
      final ref = FirebaseStorage.instance.ref('$userId/logo/image.png');

      // Try to get the download URL for a .png file
      try {
        return await ref.getDownloadURL();
      } catch (e) {
        // If .png doesn't exist, check for .jpg instead
        final jpgRef = FirebaseStorage.instance.ref('$userId/logo/image.jpg');
        return await jpgRef.getDownloadURL();
      }
    } catch (e) {
      print("Error retrieving logo URL: $e");
      return null;
    }
  }

  Future<String> uploadProductImage(
      XFile imageFile, String userId, String productId) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('$userId/products/$productId');

      // Upload the file
      await storageRef.putFile(File(imageFile.path));

      print("File uploaded successfully!");
      return storageRef.getDownloadURL();
    } catch (e) {
      print("Error uploading file: $e");
      return "";
    }
  }

  Future<String?> getProductImageUrl(String userId, String productId) async {
    try {
      // Define the path to the user's logo image
      final ref =
          FirebaseStorage.instance.ref('$userId/products/$productId.png');

      // Try to get the download URL for a .png file
      try {
        return await ref.getDownloadURL();
      } catch (e) {
        // If .png doesn't exist, check for .jpg instead
        final jpgRef =
            FirebaseStorage.instance.ref('$userId/products/$productId.jpg');
        return await jpgRef.getDownloadURL();
      }
    } catch (e) {
      print("Error retrieving logo URL: $e");
      return null;
    }
  }

  Future<List<String>> getVendorProductsImagesUrl(
      String userId, String productId) async {
    List<String> fileUrls = [];
    try {
      // Define the path to the user's logo image
      final ref = FirebaseStorage.instance.ref('$userId/products/');

      final ListResult result = await ref.listAll();

      // Try to get the download URL for a .png file
      for (var item in result.items) {
        final url = await item.getDownloadURL();
        fileUrls.add(url);
      }
    } catch (e) {
      print("Error listing logo URLs: $e");
    }
    return fileUrls;
  }

  Future<String?> uploadEventImageAndGetUrl(
      XFile imageFile, String eventId, String id) async {
    try {
      // Create a reference to the Firebase Storage location
      final storageRef =
          FirebaseStorage.instance.ref('events/$eventId/').child(id);

      // Upload the file
      await storageRef.putFile(File(imageFile.path));

      print("File uploaded successfully!");
      return storageRef.getDownloadURL();
    } catch (e) {
      print("Error uploading file: $e");
    }
  }

  Future<List<String>> getEventImagesUrl(String eventId) async {
    List<String> fileUrls = [];
    try {
      // Define the path to the user's logo image
      final ref = FirebaseStorage.instance.ref('events/$eventId/');

      final ListResult result = await ref.listAll();

      // Try to get the download URL for a .png file
      for (var item in result.items) {
        final url = await item.getDownloadURL();
        fileUrls.add(url);
      }
    } catch (e) {
      print("Error listing logo URLs: $e");
    }
    return fileUrls;
  }

  Future<Application?> getApplication(String uid, String eventId) async {
    var doc = await _db
        .collection('events')
        .doc(eventId)
        .collection('applications')
        .doc(uid)
        .get();
    if (doc.exists) {
      return Application.fromMap(doc.id, doc.data()!);
    } else {
      return null;
    }
  }

  Future<List<Application>> getApplications(String id) async {
    List<Application> applis = (await _db
            .collection('events')
            .doc(id)
            .collection('applications')
            .get()
            .then((doc) {
      return doc.docs
          .map((doc) => Application.fromMap(doc.id, doc.data()))
          .toList();
    }))
        .toList();
    return applis;
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getApplicationsQuery(
      String id) async {
    var applis =
        await _db.collection('events').doc(id).collection('applications').get();
    print(id);
    return applis;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getApplicationsStream(String id) {
    var applis = _db
        .collection('events')
        .doc(id)
        .collection('applications')
        .get()
        .asStream();
    return applis;
  }

  Future<int> getAppliedVendorsCount(String eventId) async {
    var count = await _db
        .collection('events')
        .doc(eventId)
        .collection('applications').count().get();
    return count.count ?? 0;
  }

  Future<bool> applyForEvent(String eventId, Application application) async {
    // Check if not applied already
    var appDoc = await _db.collection('events').doc(eventId).collection('applications').doc(application.id).get();
    if (appDoc.exists) {
      return false;
    } else {
      var doc = _db
          .collection('events')
          .doc(eventId)
          .collection('applications')
          .doc(application.id);
      doc.set(application.toMap());
      return true;
    }
  }

  void addProduct(String uid, Product product) {
    getUser(uid).then((user) {
      if (user != null) {
        var vend = Vendor.fromMap(uid, user.data()!);
        vend.products.add(product);
        updateUser(uid, vend.toMap());
      }
    });
  }

  void removeProduct(String uid, String productName) {
    getUser(uid).then((user) {
      if (user != null) {
        var vend = Vendor.fromMap(uid, user.data()!);
        vend.products
            .removeWhere((product) => product.productName == productName);
        updateUser(uid, vend.toMap());
      }
    });
  }

  // READ an event by ID
  Future<Event?> getEvent(String eventId) async {
    DocumentSnapshot doc = await _db.collection('events').doc(eventId).get();
    if (!doc.exists) return null;
    return Event.fromMap(doc.id, doc.data() as Map<String, dynamic>);
  }

  Future<List<Event>> getAllEventsVendor() async {
    Vendor vendor =
        Vendor.fromMap(_auth.currentUser!.uid, authController.appUser);
    print(vendor.activities);
    List<Event> events = (await (await _db.collection('events').where(
                  'tags',
                  arrayContainsAny:
                      vendor.activities.map((toElement) => toElement.name).toList(),
                ))
            .get())
        .docs
        .map((elem) {
      return Event.fromMap(elem.id, elem.data());
    }).toList();
    return events;
    // return Event.fromMap(doc.id, doc.data() as Map<String, dynamic>);
  }

  void scheduleEvent(Organizer organizer, Event event) {
    if (organizer.privileges.contains('schedule_event')) {
      _db.collection('events').add(event.toMap());
    }
  }

  Future<List<Event>> getScheduledEvents(Organizer organizer) async {
    List<Event> events = (await _db
            .collection('events')
            .where('organizer_id', isEqualTo: organizer.id)
            .get())
        .docs
        .map((elem) {
      return Event.fromMap(elem.id, elem.data());
    }).toList();
    return events;
    // return Event.fromMap(doc.id, doc.data() as Map<String, dynamic>);
  }

  Future<List<Vendor>> getAllVendors() async {
    List<Vendor> vendors =
        (await _db.collection('users').get()).docs.where((doc) {
      return doc.data()["role"] == "vendor";
    }).map((elem) {
      return Vendor.fromMap(elem.id, elem.data());
    }).toList();
    return vendors;
  }

  Future<List<Event>> getAllOrganizedEventsHistory(String organizerUid) async {
    List<Event> events = (await _db
            .collection('events')
            .where('organizer_id', isEqualTo: organizerUid)
            .get())
        .docs
        .map((elem) {
      return Event.fromMap(elem.id, elem.data());
    }).toList();
    List<Event?> eventsNew = events
        .map((event) {
          if (event.endDate.isBefore(DateTime.now())) {
            return event;
          }
        })
        .where((event) => event != null)
        .toList();

    List<Event> eventsOld = eventsNew.map((event) => event!).toList();
    return eventsOld;
  }

  Future<List<Event>> getAllRegisteredEvents(String uid) async {
    List<Event> events = (await _db
            .collection('events')
            .where('registered_vendors', arrayContains: uid)
            .get())
        .docs
        .map((elem) {
      return Event.fromMap(elem.id, elem.data());
    }).toList();
    List<Event?> eventsNew = events
        .map((event) {
          if (event.endDate.isAfter(DateTime.now())) {
            return event;
          }
        })
        .where((event) => event != null)
        .toList();

    List<Event> eventsOld = eventsNew.map((event) => event!).toList();
    return eventsOld;
  }

  Future<List<Event>> getAllRegisteredEventsHistory(String uid) async {
    List<Event> events = (await _db
            .collection('events')
            .where('registered_vendors', arrayContains: uid)
            .get())
        .docs
        .map((elem) {
      return Event.fromMap(elem.id, elem.data());
    }).toList();
    List<Event?> eventsNew = events
        .map((event) {
          if (event.endDate.isBefore(DateTime.now())) {
            return event;
          }
        })
        .where((event) => event != null)
        .toList();

    List<Event> eventsOld = eventsNew.map((event) => event!).toList();
    return eventsOld;
  }

  Future<List<Event>> getAllOrganizedEventsActive(String organizerUid) async {
    List<Event> events = (await _db
            .collection('events')
            .where('organizer_id', isEqualTo: organizerUid)
            .get())
        .docs
        .map((elem) {
      return Event.fromMap(elem.id, elem.data());
    }).toList();
    List<Event> eventsNew = events
        .map((event) {
          if (event.endDate.isBefore(DateTime.now())) {
            return event;
          }
        })
        .where((event) => event != null)
        .toList()
        .map((event) => event!)
        .toList();
    return eventsNew;
  }

  // UPDATE an event
  Future<void> updateEvent(Event event) async {
    if (!event.endDate.isBefore(DateTime.now())) {
      await _db.collection('events').doc(event.id).update(event.toMap());
    }
  }

  // DELETE an event
  Future<void> deleteEvent(String eventId) async {
    await _db.collection('events').doc(eventId).delete();
  }

  // REGISTER a vendor for an event
  Future<void> registerVendorForEvent(
      String eventId, String vendorId, String appId) async {
    //TODO: Notify User About Registration
    await _db.collection('events').doc(eventId).update({
      'applied_vendors': FieldValue.arrayRemove([vendorId]),
      'registered_vendors': FieldValue.arrayUnion([vendorId]),
    });
    await _db
        .collection('events')
        .doc(eventId)
        .collection('applications')
        .doc(appId)
        .delete();
  }

  Future<void> addOrganizerFeedback(Review review) async {
    var doc = (await _db
        .collection('users')
        .doc(review.organizerId)
        .collection('reviews')
        .doc());
    review.id = doc.id;
    doc.set(review.toMap());
  }

  Future<List<Review>> getOrganizerFeedback(String organizerId) async {
    List<Review> reviews = (await _db
            .collection('users')
            .doc(organizerId)
            .collection('reviews')
            .get())
        .docs
        .map((doc) {
      return Review.fromMap(doc.data());
    }).toList();
    return reviews;
  }

  Future<void> declineApplication(
      String eventId, String vendorId, String appId) async {
    // TODO: Notify User About Decline
    await _db.collection('events').doc(eventId).update({
      'applied_vendors': FieldValue.arrayRemove([vendorId]),
      'declined_vendors': FieldValue.arrayUnion([vendorId]),
    });
    await _db
        .collection('events')
        .doc(eventId)
        .collection('applications')
        .doc(appId)
        .delete();
  }

  // REMOVE a vendor from an event
  Future<void> removeVendorFromEvent(String eventId, Vendor vendor) async {
    await _db.collection('events').doc(eventId).update({
      'registered_vendors': FieldValue.arrayRemove([vendor.toMap()]),
    });
  }

  // CREATE a new user with role-based data
  Future<void> createUser(String uid, Map<String, dynamic> userData) async {
    await _db.collection('users').doc(uid).set(userData);
  }

  // READ user data from Firestore
  Future<DocumentSnapshot<Map<String, dynamic>>?> getUser(String uid) async {
    DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
    return doc.exists ? doc as DocumentSnapshot<Map<String, dynamic>> : null;
  }

  // UPDATE user data
  Future<void> updateUser(String uid, Map<String, dynamic> newData) async {
    await _db.collection('users').doc(uid).update(newData);
  }

  // DELETE a user from Firestore and Authentication
  Future<void> deleteUser(String uid) async {
    await _db.collection('users').doc(uid).delete();
    await _auth.currentUser?.delete(); // Auth deletion
  }

  // Create new assistant for vendor
  Future<void> createAssistant(String vendorId, Assistant assistant) async {
    var doc = (await _db
        .collection('users')
        .doc(vendorId)
        .collection('assistants')
        .doc());
    assistant.id = doc.id;
    doc.set(assistant.toMap());
  }

  Future<void> removeAssistant(String vendorId, String assistantId) async {
    await _db
        .collection('users')
        .doc(vendorId)
        .collection('assistants')
        .doc(assistantId)
        .delete();
  }

  Future<void> updateAssistant(String vendorId, Assistant assistant) async {
    await _db
        .collection('users')
        .doc(vendorId)
        .collection('assistants')
        .doc(assistant.id)
        .update(assistant.toMap());
  }

  Future<List<Assistant>> getAssistants(String vendorId) async {
    List<Assistant> assistants = (await _db
            .collection('users')
            .doc(vendorId)
            .collection('assistants')
            .get())
        .docs
        .map((doc) {
      return Assistant.fromMap(doc.id, doc.data());
    }).toList();
    return assistants;
  }

  Future<Assistant?> getAssistantById(
      String vendorId, String assistantId) async {
    DocumentSnapshot<Map<String, dynamic>> doc = await _db
        .collection('users')
        .doc(vendorId)
        .collection('assistants')
        .doc(assistantId)
        .get();
    if (doc.data() != null) {
      return Assistant.fromMap(doc.id, doc.data()!);
    } else {
      return null;
    }
  }

  // Authentication - Sign Up User with Email & Password
  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    required DateTime dateOfBirth,
    required String role, // 'Admin', 'Moderator', 'Vendor', 'User'
    String? businessName, // Only needed for Vendor
    String? logoUrl, // Only needed for Vendor
  }) async {
    try {
      // Create the user with Firebase Authentication
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Get the generated UID
      String uid = userCredential.user!.uid;

      // Create the appropriate user object based on the role
      AppUser newUser;
      switch (role) {
        case 'organizer':
          newUser = Organizer(
            id: uid,
            name: name,
            email: email,
            dateOfBirth: dateOfBirth,
            privileges: [],
            phoneNumber: "",
          );
          break;
        default:
          newUser = Vendor(
            id: uid,
            name: name,
            email: email,
            facebookUrl: '',
            instagramUrl: '',
            dateOfBirth: dateOfBirth,
            activities: [],
            businessName: businessName ?? '',
            logoUrl: logoUrl ?? '',
            privileges: [],
            products: [],
            phoneNumber: "",
            slogan: "",
          );
          break;
      }

      // Save the user object to Firestore under 'users/{uid}'
      await _db.collection('users').doc(uid).set(newUser.toMap());
    } catch (e) {
      print('Error signing up: $e');
      rethrow; // Handle errors as needed
    }
  }

  // Authentication - Sign In User with Email & Password
  Future<User?> signIn(String email, String password) async {
    // Check if email and password are valid
    if (email.isEmpty || password.isEmpty) {
      Get.snackbar('Error', 'Email or Password can not be empty!');
    }

    // Check if email is valid
    if (!GetUtils.isEmail(email)) {
      Get.snackbar('Error', 'Email is not valid!');
    }

    // Check if password is valid
    if (password.length < 6) {
      Get.snackbar('Error', 'Password must be at least 6 characters!');
    }

    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        Get.snackbar('Error', 'No user found for that email.');
      } else if (e.code == 'wrong-password') {
        Get.snackbar('Error', 'Wrong password provided for that user.');
      } else if (e.code == 'invalid-email') {
        Get.snackbar('Error', 'Email is not valid!');
      } else if (e.code == 'email-already-in-use') {
        Get.snackbar('Error', 'The account already exists for that email.');
      }
      return null;
    }
  }

  // Authentication - Sign Out User
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
