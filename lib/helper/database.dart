import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vendor/model/event.dart';
import 'package:vendor/model/user.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> createEvent(Event event) async {
    await _db.collection('events').doc(event.id).set(event.toMap());
  }

  // READ an event by ID
  Future<Event?> getEvent(String eventId) async {
    DocumentSnapshot doc = await _db.collection('events').doc(eventId).get();
    if (!doc.exists) return null;
    return Event.fromMap(doc.id, doc.data() as Map<String, dynamic>);
  }

  Future<List<Event>> getAllEvents() async {
    List<Event> events =
        (await _db.collection('events').get()).docs.map((elem) {
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
  Future<void> registerVendorForEvent(String eventId, Vendor vendor) async {
    await _db.collection('events').doc(eventId).update({
      'registered_vendors': FieldValue.arrayUnion([vendor.toMap()]),
    });
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
        case 'vendor':
          newUser = Vendor(
            id: uid,
            name: name,
            email: email,
            dateOfBirth: dateOfBirth,
            businessName: businessName ?? '',
            logoUrl: logoUrl ?? '',
          );
          break;
        default:
          newUser = NormalUser(
            id: uid,
            name: name,
            email: email,
            dateOfBirth: dateOfBirth,
          );
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
    UserCredential result = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return result.user;
  }

  // Authentication - Sign Out User
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
