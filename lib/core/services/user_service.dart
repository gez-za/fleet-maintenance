import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final CollectionReference users =
  FirebaseFirestore.instance.collection('users');

  // ➕ CREATE USER PROFILE (après login/register)
  Future<void> createUserProfile({
    required String name,
    required String email,
    required String role,
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    await users.doc(user.uid).set({
      'uid': user.uid,
      'name': name,
      'email': email,
      'role': role,
      'createdAt': Timestamp.now(),
    });
  }

  // 👤 GET USER DATA
  Future<DocumentSnapshot> getUser(String uid) async {
    return await users.doc(uid).get();
  }

  // 🎭 GET ROLE
  Future<String> getUserRole(String uid) async {
    final doc = await users.doc(uid).get();
    return doc['role'];
  }
}