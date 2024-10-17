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
  Future<Map<String, dynamic>?> getUser(String uid) async {
    DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
    return doc.exists ? doc.data() as Map<String, dynamic> : null;
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
  Future<User?> signUp(String email, String password) async {
    UserCredential result = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return result.user;
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
