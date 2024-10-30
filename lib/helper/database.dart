import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:vendor/main.dart';
import 'package:vendor/model/event.dart';
import 'package:vendor/model/user.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void createEvent(Event event) {
    var doc = _db.collection('events').doc();
    event.id = doc.id;
    doc.set(event.toMap());
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

  Future<bool> applyForEvent(String eventId, Application application) async {
    // Check if not applied already

    var eventDoc = await _db.collection('events').doc(eventId).get();
    var event =
        Event.fromMap(eventDoc.id, eventDoc.data() as Map<String, dynamic>);
    if (event.appliedVendorsId.contains(application.vendorId)) {
      return false;
    } else {
      var doc = _db
          .collection('events')
          .doc(eventId)
          .collection('applications')
          .doc();
      application.id = doc.id;
      doc.set(application.toMap());
      event.appliedVendorsId.add(application.vendorId);
      _db.collection('events').doc(eventId).update(event.toMap());
      return true;
    }
  }

  void addProduct(Vendor user) {
    var doc = _db.collection('users').doc();
    user.id = doc.id;
    doc.update(user.toMap());
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
    List<Event> events = (await (await _db.collection('events').where(
                  'tags',
                  arrayContainsAny:
                      vendor.activities.map((toElement) => toElement.name),
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

  // UPDATE an event
  Future<void> updateEvent(Event event) async {
    await _db.collection('events').doc(event.id).update(event.toMap());
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
      'registered_vendors': FieldValue.arrayUnion([vendorId]),
    });
    await _db
        .collection('events')
        .doc(eventId)
        .collection('applications')
        .doc(appId)
        .delete();
  }

  Future<void> declineApplication(
      String eventId, String vendorId, String appId) async {
    // TODO: Notify User About Decline
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
            managedEvents: [],
            phoneNumber: "",
          );
          break;
        default:
          newUser = Vendor(
            id: uid,
            name: name,
            email: email,
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
