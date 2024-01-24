import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CustomUser {
  final String uid;
  final String email;
  final String username;
  final String hashedPassword;
  final String currency;

  CustomUser({
    required this.uid,
    required this.email,
    required this.username,
    required this.hashedPassword,
    required this.currency,
  });

  factory CustomUser.fromFirebaseUser(
      User user, String username, String currency) {
    return CustomUser(
      uid: user.uid,
      email: user.email!,
      username: username,
      hashedPassword: generateHashedPassword(user.uid, user.email!),
      currency: currency,
    );
  }

  Future<void> saveUserToFirestore() async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'username': username,
        'email': email,
        'hashedPassword': hashedPassword,
        'currency': currency
      });
    } catch (e) {
      print('Error saving user to Firestore: $e');
    }
  }

  static String generateHashedPassword(String uid, String email) {
    return 'hash_function_result';
  }
}
